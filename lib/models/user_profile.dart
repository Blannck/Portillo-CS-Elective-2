class UserProfile {
  final String id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final int? roleId;
  final String? role;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.roleId,
    this.role,
    this.createdAt,
  });

  String get fullName {
    final first = firstname ?? '';
    final last = lastname ?? '';
    final combined = '$first $last'.trim();
    return combined.isNotEmpty ? combined : (email ?? 'User');
  }

  bool get isAdmin => role?.toLowerCase() == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String? roleName;
    if (json['roles'] != null && json['roles'] is Map) {
      roleName = json['roles']['role'] as String?;
    }

    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      roleId: json['role_id'] != null
          ? (json['role_id'] is int ? json['role_id'] as int : int.tryParse(json['role_id'].toString()))
          : null,
      role: roleName,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
