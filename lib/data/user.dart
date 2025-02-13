class User {
  final String id;
  final String name;
  final String username;
  final String joinedAt;
  final Role role;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.joinedAt,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '', // Konversi ke String
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      joinedAt: json['joined_at'] ?? '',
      role: Role.fromJson(json['role'] ?? {}),
    );
  }
}

class Role {
  final String id;
  final String name;
  final bool isSuperAdmin;

  Role({required this.id, required this.name, required this.isSuperAdmin});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id']?.toString() ?? '', // Konversi ke String
      name: json['name'] ?? '',
      isSuperAdmin: json['is_superadmin'] ?? false,
    );
  }
}
