import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// One post in the shared community feed.
///
/// Field names match the documents already sitting in `posts`, so the feed
/// picks up the existing history instead of starting from an empty collection.
class CommunityPost {
  final String id;
  final String uid;
  final String name;
  final String level;
  final String type;
  final String text;
  final String? help;
  final int likes;
  final List<String> likedBy;
  final int comments;

  /// Null for the moment between a local write and the server timestamp
  /// landing — Firestore serves the optimistic copy first.
  final DateTime? createdAt;

  const CommunityPost({
    required this.id,
    required this.uid,
    required this.name,
    required this.level,
    required this.type,
    required this.text,
    required this.help,
    required this.likes,
    required this.likedBy,
    required this.comments,
    required this.createdAt,
  });

  factory CommunityPost.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CommunityPost(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      name: (data['name'] as String? ?? '').trim().isEmpty
          ? 'Learner'
          : (data['name'] as String).trim(),
      level: data['level'] as String? ?? 'A1',
      // Older documents predate the type field; they read as progress notes.
      type: data['type'] as String? ?? 'Progress',
      text: data['text'] as String? ?? '',
      help: (data['help'] as String?)?.trim().isEmpty ?? true
          ? null
          : (data['help'] as String).trim(),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      likedBy: (data['likedBy'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  bool likedByMe(String? uid) => uid != null && likedBy.contains(uid);

  String get initial => name.isEmpty ? 'S' : name.substring(0, 1).toUpperCase();

  /// Compact age label — "now", "8m", "3h", "2d".
  String get age {
    final created = createdAt;
    if (created == null) return 'now';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }
}

/// One reply under a community post.
class CommunityComment {
  final String id;
  final String uid;
  final String name;
  final String level;
  final String text;
  final DateTime? createdAt;

  const CommunityComment({
    required this.id,
    required this.uid,
    required this.name,
    required this.level,
    required this.text,
    required this.createdAt,
  });

  factory CommunityComment.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CommunityComment(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      name: (data['name'] as String? ?? '').trim().isEmpty
          ? 'Learner'
          : (data['name'] as String).trim(),
      level: data['level'] as String? ?? 'A1',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  String get initial => name.isEmpty ? 'S' : name.substring(0, 1).toUpperCase();
}

/// The shared community feed, live from Firestore.
///
/// Every signed-in account reads the same `posts` collection, so a post one
/// learner writes shows up on everyone else's feed as soon as the server
/// acknowledges it — no refresh, no polling.
class CommunityFeedStore {
  CommunityFeedStore._();

  static final CommunityFeedStore instance = CommunityFeedStore._();

  static const int maxPostLength = 600;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  String? get currentUid => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  /// Live feed, newest first. Listeners are pushed a new list on every change
  /// anyone makes, including their own optimistic writes.
  Stream<List<CommunityPost>> watchFeed({int limit = 60}) {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(CommunityPost.fromDoc).toList());
  }

  /// Writes a post as the signed-in user. Throws [StateError] when nobody is
  /// signed in, because the security rules would reject the write anyway.
  Future<void> createPost({
    required String text,
    required String type,
    required String name,
    required String level,
    String? help,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to post to the community.');
    }

    final clean = text.trim();
    await _posts.add({
      'uid': user.uid,
      'name': name.trim().isEmpty ? 'Learner' : name.trim(),
      'level': level,
      'type': type,
      'text': clean.length > maxPostLength
          ? clean.substring(0, maxPostLength)
          : clean,
      if (help != null && help.trim().isNotEmpty) 'help': help.trim(),
      'likes': 0,
      'likedBy': <String>[],
      'reposts': 0,
      'repostedBy': <String>[],
      'comments': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Flips this account's like on [post]. The counter and the membership list
  /// move together so every client can render the state without a second read.
  Future<void> toggleLike(CommunityPost post) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to like posts.');
    }

    final liked = post.likedBy.contains(user.uid);
    await _posts.doc(post.id).update({
      'likedBy': liked
          ? FieldValue.arrayRemove([user.uid])
          : FieldValue.arrayUnion([user.uid]),
      'likes': FieldValue.increment(liked ? -1 : 1),
    });
  }

  /// One reply under a post.
  Stream<List<CommunityComment>> watchComments(String postId, {int limit = 50}) {
    return _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(CommunityComment.fromDoc).toList());
  }

  /// Adds a reply and bumps the post's counter in the same batch, so the
  /// number under the post never drifts from the replies actually stored.
  Future<void> addComment({
    required String postId,
    required String text,
    required String name,
    required String level,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to reply.');
    }

    final clean = text.trim();
    final postRef = _posts.doc(postId);
    final commentRef = postRef.collection('comments').doc();

    await _firestore.runTransaction((tx) async {
      tx.set(commentRef, {
        'uid': user.uid,
        'name': name.trim().isEmpty ? 'Learner' : name.trim(),
        'level': level,
        'text': clean.length > 400 ? clean.substring(0, 400) : clean,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(postRef, {'comments': FieldValue.increment(1)});
    });
  }

  /// Only the author may remove a post; the rules enforce the same thing.
  Future<void> deletePost(CommunityPost post) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != post.uid) {
      throw StateError('You can only delete your own posts.');
    }
    await _posts.doc(post.id).delete();
  }
}
