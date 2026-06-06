class UserModel {
  final String uuid;
  final String username;
  final String fullName;
  final String email;
  final String? userImage;
  final DateTime passwordChangedAt;
  final DateTime createdAt;

  UserModel({
    required this.uuid,
    required this.username,
    required this.fullName,
    required this.email,
    this.userImage,
    required this.passwordChangedAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json['uuid'] ?? '',
      username: json['username'],
      fullName: json['full_name'],
      email: json['email'],
      userImage: json['user_image'],
      passwordChangedAt: DateTime.parse(json['password_changed_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'username': username,
      'full_name': fullName,
      'email': email,
      'user_image': userImage,
      'password_changed_at': passwordChangedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
