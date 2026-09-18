import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How someone in a connection list is related to the signed-in learner.
enum SocialConnectionKind { friend, incomingRequest, outgoingRequest }

/// A public profile as it stands right now, looked up by uid.
class SocialProfileSummary {
  final String uid;
  final String name;
  final String username;

  const SocialProfileSummary({
    required this.uid,
    required this.name,
    required this.username,
  });
}

/// One row in the followers / following / friends lists.
///
/// Identity is the uid. Usernames change — a friend who renames themselves
/// would otherwise drop out of everyone's list — so the handle shown here is
/// whatever the lookup reports today, not whatever was stored at the time.
class SocialConnection {
  final String uid;
  final String fallbackUsername;
  final String fallbackName;
  final SocialConnectionKind kind;

  const SocialConnection({
    required this.uid,
    required this.fallbackUsername,
    required this.fallbackName,
    required this.kind,
  });

  SocialProfileSummary? _summary(Map<String, SocialProfileSummary> resolved) =>
      uid.isEmpty ? null : resolved[uid];

  String nameOr(Map<String, SocialProfileSummary> resolved) {
    final remote = _summary(resolved)?.name.trim() ?? '';
    if (remote.isNotEmpty) return remote;
    if (fallbackName.trim().isNotEmpty) return fallbackName.trim();
    return fallbackUsername.isEmpty ? 'Speakery Student' : fallbackUsername;
  }

  String handleOr(Map<String, SocialProfileSummary> resolved) {
    final remote = _summary(resolved)?.username.trim() ?? '';
    if (remote.isNotEmpty) return '@$remote';
    return fallbackUsername.isEmpty ? '' : '@$fallbackUsername';
  }

  String initialOr(Map<String, SocialProfileSummary> resolved) {
    final name = nameOr(resolved);
    return name.isEmpty ? 'S' : name.substring(0, 1).toUpperCase();
  }
}

class SocialProfileStore extends ChangeNotifier {
  SocialProfileStore._();

  static final SocialProfileStore instance = SocialProfileStore._();

  static const String _profileKey = 'speakery_social_profile';
  // Bumped when friendships moved from usernames to uids: the old cache
  // holds handles, which are no longer identities.
  static const String _friendsKey = 'speakery_social_friend_uids';
  static const String _incomingKey = 'speakery_social_incoming_requests';
  static const String _outgoingKey = 'speakery_social_outgoing_requests';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loaded = false;
  bool _loading = false;

  String displayName = 'Speakery Learner';
  String username = 'speakerylearner';
  String bio = 'Building fluency one lesson at a time.';

  /// Friend uids. Usernames are mutable, so they cannot be the identity.
  final Set<String> friends = <String>{};
  final List<FriendRequest> incomingRequests = <FriendRequest>[];
  final List<FriendRequest> outgoingRequests = <FriendRequest>[];

  bool get isLoaded => _loaded;
  bool get isLoading => _loading;
  String get handle => '@$username';
  int get friendsCount => friends.length;
  int get followersCount => friends.length + incomingRequests.length;
  int get followingCount => friends.length + outgoingRequests.length;

  List<SocialConnection> get friendConnections => friends
      .map((uid) => SocialConnection(
            uid: uid,
            fallbackUsername: '',
            fallbackName: '',
            kind: SocialConnectionKind.friend,
          ))
      .toList(growable: false);

  /// Friends plus anyone whose request is still waiting on you — the same
  /// people [followersCount] counts.
  List<SocialConnection> get followerConnections => [
        ...friendConnections,
        ...incomingRequests.map((request) => SocialConnection(
              uid: request.userId ?? '',
              fallbackUsername: request.username,
              fallbackName: request.displayName,
              kind: SocialConnectionKind.incomingRequest,
            )),
      ];

  /// Friends plus anyone you have asked and not heard back from.
  List<SocialConnection> get followingConnections => [
        ...friendConnections,
        ...outgoingRequests.map((request) => SocialConnection(
              uid: request.userId ?? '',
              fallbackUsername: request.username,
              fallbackName: request.displayName,
              kind: SocialConnectionKind.outgoingRequest,
            )),
      ];

  /// Reads the current public profile of each uid.
  ///
  /// The lookup is by document id, so a learner who renames themselves still
  /// resolves — which is the whole reason friendships are keyed on uid.
  /// Failures are swallowed: the caller falls back to whatever it already has.
  Future<Map<String, SocialProfileSummary>> profilesFor(
    Iterable<String> uids,
  ) async {
    final wanted =
        uids.where((value) => value.trim().isNotEmpty).toSet().toList();
    final resolved = <String, SocialProfileSummary>{};

    await Future.wait(wanted.map((uid) async {
      try {
        final doc =
            await _firestore.collection('publicProfiles').doc(uid).get();
        final data = doc.data();
        if (data == null) return;
        resolved[uid] = SocialProfileSummary(
          uid: uid,
          name: (data['name'] as String?) ?? '',
          username: (data['usernameLower'] as String?) ??
              (data['username'] as String?) ??
              '',
        );
      } catch (error) {
        debugPrint('Profile lookup failed for $uid: $error');
      }
    }));

    return resolved;
  }

  Future<void> load() async {
    if (_loaded || _loading) return;
    _loading = true;

    try {
      await _loadLocal();
      _seedFromUser();
      notifyListeners();
      try {
        await _loadRemote();
      } catch (error) {
        debugPrint('Social profile remote sync failed: $error');
        await _saveLocal();
      }
    } finally {
      _loaded = true;
      _loading = false;
      notifyListeners();
    }
  }

  /// Wipes everything tied to the signed-in learner.
  ///
  /// The profile is cached locally so it survives a restart; without this the
  /// next account to sign in on the device would inherit the previous one's
  /// name, handle and friend list.
  Future<void> clearForSignOut() async {
    displayName = 'Speakery Learner';
    username = 'speakerylearner';
    bio = 'Building fluency one lesson at a time.';
    friends.clear();
    incomingRequests.clear();
    outgoingRequests.clear();
    _loaded = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_friendsKey);
    await prefs.remove(_incomingKey);
    await prefs.remove(_outgoingKey);

    notifyListeners();
  }

  Future<void> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  }) async {
    final cleanName = displayName.trim();
    final cleanUsername = normalizeUsername(username);
    final cleanBio = bio.trim();

    if (cleanName.length < 2) {
      throw const SocialProfileException('Display name is too short.');
    }
    if (cleanUsername.length < 3) {
      throw const SocialProfileException('Username must be at least 3 chars.');
    }

    this.displayName = cleanName;
    this.username = cleanUsername;
    this.bio = cleanBio.isEmpty ? this.bio : cleanBio;

    await _saveLocal();
    notifyListeners();
    await _saveRemoteProfile();
  }

  Future<void> sendFriendRequest(String rawUsername) async {
    final targetUsername = normalizeUsername(rawUsername);
    if (targetUsername.length < 3) {
      throw const SocialProfileException('Enter a valid username.');
    }
    if (targetUsername == username) {
      throw const SocialProfileException('You cannot add yourself.');
    }
    if (outgoingRequests.any((request) => request.username == targetUsername)) {
      throw const SocialProfileException('Request already sent.');
    }

    FriendRequest request;
    final user = _auth.currentUser;

    if (user == null) {
      request = FriendRequest.local(
        displayName: targetUsername,
        username: targetUsername,
        direction: FriendRequestDirection.outgoing,
      );
    } else {
      await _saveRemoteProfile();
      final target = await _findUserByUsername(targetUsername);
      if (target == null || target.id == user.uid) {
        throw const SocialProfileException(
            'No student found with that username.');
      }
      if (friends.contains(target.id)) {
        throw const SocialProfileException('This student is already a friend.');
      }

      final requestId = '${user.uid}_${target.id}';
      request = FriendRequest(
        id: requestId,
        displayName: (target.data()['name'] as String?) ?? targetUsername,
        username: targetUsername,
        userId: target.id,
        direction: FriendRequestDirection.outgoing,
        isRemote: true,
      );

      await _firestore.collection('friendRequests').doc(requestId).set({
        'fromUid': user.uid,
        'fromName': displayName,
        'fromUsername': username,
        'toUid': target.id,
        'toName': (target.data()['name'] as String?) ?? targetUsername,
        'toUsername': targetUsername,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    outgoingRequests.add(request);
    await _saveLocal();
    notifyListeners();
  }

  Future<void> acceptRequest(FriendRequest request) async {
    incomingRequests.removeWhere((item) => item.id == request.id);

    final friendUid = request.userId;
    // A request made while signed out carries no uid, so there is nothing
    // stable to record; it becomes a friendship once it syncs.
    if (friendUid != null && friendUid.isNotEmpty) {
      friends.add(friendUid);
    }

    final user = _auth.currentUser;
    if (request.isRemote && user != null && friendUid != null) {
      await _firestore.collection('friendRequests').doc(request.id).set({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(user.uid).set({
        'friends': FieldValue.arrayUnion([friendUid]),
      }, SetOptions(merge: true));
    }

    await _saveLocal();
    notifyListeners();
  }

  Future<void> declineRequest(FriendRequest request) async {
    incomingRequests.removeWhere((item) => item.id == request.id);

    if (request.isRemote) {
      await _firestore.collection('friendRequests').doc(request.id).set({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await _saveLocal();
    notifyListeners();
  }

  static String normalizeUsername(String value) {
    final buffer = StringBuffer();
    for (final unit
        in value.toLowerCase().trim().replaceAll('@', '').codeUnits) {
      final isLetter = unit >= 97 && unit <= 122;
      final isDigit = unit >= 48 && unit <= 57;
      final isAllowedSymbol = unit == 95 || unit == 46;
      if (isLetter || isDigit || isAllowedSymbol) {
        buffer.writeCharCode(unit);
      }
    }
    return buffer.toString();
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final profileRaw = prefs.getString(_profileKey);

    if (profileRaw != null) {
      final data = jsonDecode(profileRaw) as Map<String, dynamic>;
      displayName = (data['displayName'] as String?) ?? displayName;
      username = (data['username'] as String?) ?? username;
      bio = (data['bio'] as String?) ?? bio;
    }

    friends
      ..clear()
      ..addAll(prefs.getStringList(_friendsKey) ?? const <String>[]);

    incomingRequests
      ..clear()
      ..addAll(_decodeRequests(
        prefs.getStringList(_incomingKey) ?? const <String>[],
        FriendRequestDirection.incoming,
      ));

    outgoingRequests
      ..clear()
      ..addAll(_decodeRequests(
        prefs.getStringList(_outgoingKey) ?? const <String>[],
        FriendRequestDirection.outgoing,
      ));
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _profileKey,
      jsonEncode({
        'displayName': displayName,
        'username': username,
        'bio': bio,
      }),
    );
    await prefs.setStringList(_friendsKey, friends.toList()..sort());
    await prefs.setStringList(
      _incomingKey,
      incomingRequests.map((request) => jsonEncode(request.toJson())).toList(),
    );
    await prefs.setStringList(
      _outgoingKey,
      outgoingRequests.map((request) => jsonEncode(request.toJson())).toList(),
    );
  }

  void _seedFromUser() {
    final user = _auth.currentUser;
    if (user == null) return;

    final emailPrefix = user.email?.split('@').first;
    if (displayName == 'Speakery Learner' && emailPrefix != null) {
      displayName = emailPrefix;
    }

    if (username == 'speakerylearner') {
      username = normalizeUsername(emailPrefix ?? user.uid.substring(0, 8));
    }
  }

  Future<void> _loadRemote() async {
    final user = _auth.currentUser;
    if (user == null) {
      await _saveLocal();
      return;
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final profileDoc = await userRef.get();
    final remoteData = profileDoc.data();

    if (remoteData != null) {
      displayName = (remoteData['name'] as String?) ?? displayName;
      username = normalizeUsername(
        (remoteData['username'] as String?) ?? username,
      );
      bio = (remoteData['bio'] as String?) ?? bio;
      friends
        ..clear()
        ..addAll((remoteData['friends'] as List<dynamic>? ?? const <dynamic>[])
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty));
    }

    await _saveRemoteProfile();
    await _loadRemoteRequests(user.uid);
    await _reconcileFriends(user.uid);
    await _saveLocal();
    notifyListeners();
  }

  /// Drops friend entries that point at no profile and writes the cleaned list
  /// back.
  ///
  /// Friendships used to be stored as usernames. Those entries survive in old
  /// documents and, read as uids, resolve to nobody — so each account repairs
  /// its own list the first time it signs in after the change. No admin
  /// credentials, no migration window.
  Future<void> _reconcileFriends(String uid) async {
    if (friends.isEmpty) return;

    final profiles = await profilesFor(friends);

    // An empty result means the lookup itself failed — offline, rules, a bad
    // connection. Wiping the list on that would be destructive, so leave it.
    if (profiles.isEmpty) return;

    final valid = friends.where(profiles.containsKey).toSet();
    if (valid.length == friends.length) return;

    debugPrint(
      'Dropping ${friends.length - valid.length} stale friend entry/entries.',
    );
    friends
      ..clear()
      ..addAll(valid);

    await _firestore.collection('users').doc(uid).set(
      {'friends': friends.toList()},
      SetOptions(merge: true),
    );
  }

  Future<void> _saveRemoteProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': displayName,
      'username': username,
      'usernameLower': username,
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection('publicProfiles').doc(user.uid).set({
      'name': displayName,
      'username': username,
      'usernameLower': username,
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadRemoteRequests(String uid) async {
    final incomingSnapshot = await _firestore
        .collection('friendRequests')
        .where('toUid', isEqualTo: uid)
        .get();
    final outgoingSnapshot = await _firestore
        .collection('friendRequests')
        .where('fromUid', isEqualTo: uid)
        .get();

    incomingRequests.clear();
    outgoingRequests.clear();

    for (final doc in incomingSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'pending') {
        incomingRequests.add(FriendRequest.fromRemote(
          id: doc.id,
          data: data,
          direction: FriendRequestDirection.incoming,
        ));
      } else if (data['status'] == 'accepted') {
        final friendUid = (data['fromUid'] as String?)?.trim() ?? '';
        if (friendUid.isNotEmpty) friends.add(friendUid);
      }
    }

    for (final doc in outgoingSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'pending') {
        outgoingRequests.add(FriendRequest.fromRemote(
          id: doc.id,
          data: data,
          direction: FriendRequestDirection.outgoing,
        ));
      } else if (data['status'] == 'accepted') {
        final friendUid = (data['toUid'] as String?)?.trim() ?? '';
        if (friendUid.isNotEmpty) friends.add(friendUid);
      }
    }
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findUserByUsername(
    String username,
  ) async {
    final snapshot = await _firestore
        .collection('publicProfiles')
        .where('usernameLower', isEqualTo: username)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty ? null : snapshot.docs.first;
  }

  List<FriendRequest> _decodeRequests(
    List<String> values,
    FriendRequestDirection direction,
  ) {
    return values.map((value) {
      final data = jsonDecode(value) as Map<String, dynamic>;
      return FriendRequest.fromJson(data, direction);
    }).toList();
  }
}

class SocialProfileException implements Exception {
  const SocialProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum FriendRequestDirection { incoming, outgoing }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.displayName,
    required this.username,
    required this.direction,
    this.userId,
    this.isRemote = false,
  });

  factory FriendRequest.local({
    required String displayName,
    required String username,
    required FriendRequestDirection direction,
  }) {
    return FriendRequest(
      id: '${direction.name}_${DateTime.now().millisecondsSinceEpoch}_$username',
      displayName: displayName,
      username: username,
      direction: direction,
    );
  }

  factory FriendRequest.fromRemote({
    required String id,
    required Map<String, dynamic> data,
    required FriendRequestDirection direction,
  }) {
    final isIncoming = direction == FriendRequestDirection.incoming;
    return FriendRequest(
      id: id,
      displayName: (data[isIncoming ? 'fromName' : 'toName'] as String?) ??
          (data[isIncoming ? 'fromUsername' : 'toUsername'] as String?) ??
          'Speakery Student',
      username: SocialProfileStore.normalizeUsername(
        (data[isIncoming ? 'fromUsername' : 'toUsername'] as String?) ?? '',
      ),
      userId: data[isIncoming ? 'fromUid' : 'toUid'] as String?,
      direction: direction,
      isRemote: true,
    );
  }

  factory FriendRequest.fromJson(
    Map<String, dynamic> data,
    FriendRequestDirection fallbackDirection,
  ) {
    return FriendRequest(
      id: (data['id'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? 'Speakery Student',
      username: SocialProfileStore.normalizeUsername(
        (data['username'] as String?) ?? '',
      ),
      userId: data['userId'] as String?,
      direction: data['direction'] == 'incoming'
          ? FriendRequestDirection.incoming
          : data['direction'] == 'outgoing'
              ? FriendRequestDirection.outgoing
              : fallbackDirection,
      isRemote: data['isRemote'] == true,
    );
  }

  final String id;
  final String displayName;
  final String username;
  final String? userId;
  final FriendRequestDirection direction;
  final bool isRemote;

  String get handle => '@$username';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'username': username,
      'userId': userId,
      'direction': direction.name,
      'isRemote': isRemote,
    };
  }
}
