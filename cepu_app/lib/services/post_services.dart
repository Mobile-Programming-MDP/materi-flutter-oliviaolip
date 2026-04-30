import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPost(Post post) async {
    try {
      await _firestore.collection('posts').add(post.toMap());
    } catch (e) {
      throw Exception('Gagal menambahkan post: $e');
    }
  }

  Stream<List<Post>> getPosts() {
    return _firestore.collection('posts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return Post.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus post: $e');
    }
  }
}