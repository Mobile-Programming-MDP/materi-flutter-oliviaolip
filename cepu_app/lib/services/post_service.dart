import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cepu_app/models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'posts';

  // Create a new post
  Future<String> createPost(Post post) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(
            post.toJson(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Get all posts
  Future<List<Post>> getAllPosts() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  // Get post by ID
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(postId).get();

      if (doc.exists) {
        return Post.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  // Update post
  Future<void> updatePost(String postId, Post post) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).update(
            post.toJson(),
          );
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Get posts by user ID
  Future<List<Post>> getPostsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user posts: $e');
    }
  }

  // Get posts by category
  Future<List<Post>> getPostsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get posts by category: $e');
    }
  }

  // Stream posts
  Stream<List<Post>> streamPosts() {
    return _firestore
        .collection(_collectionName)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
