class UserModel {
  final String uuid;
  final String username;
  final String fullName;
  final String email;
  final bool emailVerified;
  final String? userImage;
  final DateTime? passwordChangedAt;
  final DateTime? createdAt;

  UserModel({
    required this.uuid,
    required this.username,
    required this.fullName,
    required this.email,
    this.emailVerified = false,
    this.userImage,
    this.passwordChangedAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['uuid'] ?? json['id'] ?? json['user_id'] ?? json['userId'] ?? '';
    final idString = rawId.toString().trim();

    return UserModel(
      uuid: idString,
      username: json['username'] ?? json['email'] ?? '',
      fullName:
          json['full_name'] ??
          json['fullName'] ??
          json['username'] ??
          'Usuário',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] == true,
      userImage: json['user_image'] ?? json['userImage'],
      passwordChangedAt: json['password_changed_at'] != null
          ? DateTime.tryParse(json['password_changed_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'id': uuid,
      'username': username,
      'full_name': fullName,
      'email': email,
      'email_verified': emailVerified,
      'user_image': userImage,
      'password_changed_at': passwordChangedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
