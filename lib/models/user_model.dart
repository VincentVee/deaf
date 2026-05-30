class AppUser {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' or 'user'
  final DateTime createdAt;
  final bool isActive;
  final String? profileImageUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.isActive,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as dynamic).toDate(),
      isActive: map['isActive'] ?? true,
      profileImageUrl: map['profileImageUrl'],
    );
  }
}