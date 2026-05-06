import 'package:cepu_app/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _postsCollection =
      _database.collection('posts');

  // ➕ ADD POST
  static Future<void> addPost(Post post) async {
    Map<String, dynamic> newPost = {
      'image': post.image ?? '',
      'description': post.description ?? '',
      'category': post.category ?? '',
      'latitude': post.latitude ?? 0.0,
      'longitude': post.longitude ?? 0.0,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': post.userId ?? '',
      'user_full_name': post.userFullName ?? '',
    };

    await _postsCollection.add(newPost);
  }

  // ✏️ UPDATE POST
  static Future<void> updatePost(Post post) async {
    Map<String, dynamic> updatedPost = {
      'image': post.image ?? '',
      'description': post.description ?? '',
      'category': post.category ?? '',
      'latitude': post.latitude ?? 0.0,
      'longitude': post.longitude ?? 0.0,
      'created_at': post.createdAt,
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': post.userId ?? '',
      'user_full_name': post.userFullName ?? '',
    };

    await _postsCollection.doc(post.id).update(updatedPost);
  }

  // ❌ DELETE POST
  static Future<void> deletePost(Post post) async {
    await _postsCollection.doc(post.id).delete();
  }

  // 📥 GET ALL (tanpa filter)
  static Stream<List<Post>> getPostList() {
    return _postsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Post(
          id: doc.id,
          image: data['image'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          createdAt: data['created_at'],
          updatedAt: data['updated_at'],
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          userId: data['user_id'] ?? '',
          userFullName: data['user_full_name'] ?? '',
        );
      }).toList();
    });
  }

  // 🔍 GET BY CATEGORY (INI YANG KAMU BUTUH)
  static Stream<List<Post>> getPostListByCategory(String? category) {
    Query query = _postsCollection;

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Post(
          id: doc.id,
          image: data['image'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          createdAt: data['created_at'],
          updatedAt: data['updated_at'],
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          userId: data['user_id'] ?? '',
          userFullName: data['user_full_name'] ?? '',
        );
      }).toList();
    });
  }
}