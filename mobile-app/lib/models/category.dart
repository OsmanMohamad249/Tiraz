// lib/models/category.dart
class Category {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;
  
  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
