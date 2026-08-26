import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialProfileStore extends ChangeNotifier {
  SocialProfileStore._();

  static final SocialProfileStore instance = SocialProfileStore._();

  static const String _profileKey = 'speakery_social_profile';
  static const String _friendsKey = 'speakery_social_friends';
  static const String _incomingKey = 'speakery_social_incoming_requests';
  static const String _outgoingKey = 'speakery_social_outgoing_requests';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loaded = false;
  bool _loading = false;

  String displayName = 'Speakery Learner';
  String username = 'speakerylearner';
  String bio = 'Building fluency one lesson at a time.';

  final Set<String> friends = <String>{};
  final List<FriendRequest> incomingRequests = <FriendRequest>[];
  final List<FriendRequest> outgoingRequests = <FriendRequest>[];

  bool get isLoaded => _loaded;
  bool get isLoading => _loading;
  String get handle => '@$username';
  int get friendsCount => friends.length;
  int get followersCount => friends.length + incomingRequests.length;
  int get followingCount => friends.length + outgoingRequests.length;

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
    if (friends.contains(targetUsername)) {
      throw const SocialProfileException('This student is already a friend.');
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
    friends.add(request.username);

    final user = _auth.currentUser;
    if (request.isRemote && user != null) {
      await _firestore.collection('friendRequests').doc(request.id).set({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(user.uid).set({
        'friends': FieldValue.arrayUnion([request.username]),
      }, SetOptions(merge: true));

      if (request.userId != null) {
        await _firestore.collection('users').doc(request.userId).set({
          'friends': FieldValue.arrayUnion([username]),
        }, SetOptions(merge: true));
      }
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
            .map((value) => normalizeUsername(value.toString()))
            .where((value) => value.isNotEmpty));
    }

    await _saveRemoteProfile();
    await _loadRemoteRequests(user.uid);
    await _saveLocal();
    notifyListeners();
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

    incomingRequests
      ..clear()
      ..addAll(incomingSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .map((doc) => FriendRequest.fromRemote(
                id: doc.id,
                data: doc.data(),
                direction: FriendRequestDirection.incoming,
              )));

    outgoingRequests
      ..clear()
      ..addAll(outgoingSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .map((doc) => FriendRequest.fromRemote(
                id: doc.id,
                data: doc.data(),
                direction: FriendRequestDirection.outgoing,
              )));
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findUserByUsername(
    String username,
  ) async {
    final snapshot = await _firestore
        .collection('users')
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
