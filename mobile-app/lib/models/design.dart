// lib/models/design.dart
class Design {
  final String id;
  final String title;
  final String description;
  final String styleType;
  final double price;
  final String imageUrl;
  final String designerId;
  final String categoryId;
  final DateTime createdAt;
  
  Design({
    required this.id,
    required this.title,
    required this.description,
    required this.styleType,
    required this.price,
    required this.imageUrl,
    required this.designerId,
    required this.categoryId,
    required this.createdAt,
  });
  
  factory Design.fromJson(Map<String, dynamic> json) {
    return Design(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      styleType: json['style_type'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      designerId: json['designer_id'],
      categoryId: json['category_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'style_type': styleType,
      'price': price,
      'image_url': imageUrl,
      'designer_id': designerId,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
