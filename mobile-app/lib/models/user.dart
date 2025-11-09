// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final String role;  // 'customer', 'designer', 'admin', 'tailor'
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.isActive,
    required this.role,
    required this.createdAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isActive: json['is_active'],
      role: json['role'] ?? 'customer',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return email;
  }
  
  bool get isAdmin => role == 'admin';
  bool get isDesigner => role == 'designer';
  bool get isCustomer => role == 'customer';
  bool get isTailor => role == 'tailor';
}
