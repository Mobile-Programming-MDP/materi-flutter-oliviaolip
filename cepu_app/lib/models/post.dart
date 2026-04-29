class Post {
  final String id;
  final String image;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String userFullname;

  Post({
    required this.id,
    required this.image,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.userFullname,
  });

  // Convert Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'user_fullname': userFullname,
    };
  }

  // Create Post from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userId: json['user_id'] as String,
      userFullname: json['user_fullname'] as String,
    );
  }

  // Copy with method
  Post copyWith({
    String? id,
    String? image,
    String? description,
    String? category,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? userFullname,
  }) {
    return Post(
      id: id ?? this.id,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      userFullname: userFullname ?? this.userFullname,
    );
  }
}
