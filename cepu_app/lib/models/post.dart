class Post {
  final String id;
  final String image;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String userId;
  final String userFullName;
  final String userFullname; // Alias untuk userFullName
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.image,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.userFullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }): userFullname = userFullName, createdAt = createdAt ?? DateTime.now(), updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'user_fullname': userFullName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
      id: documentId,
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      userId: map['user_id'] ?? '',
      userFullName: map['user_fullname'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }
}