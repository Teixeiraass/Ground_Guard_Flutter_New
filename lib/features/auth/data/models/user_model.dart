class UserModel {
  final String username;
  final String fullName;
  final String email;
  final DateTime passwordChangedAt;
  final DateTime createdAt;

  UserModel({
    required this.username,
    required this.fullName,
    required this.email,
    required this.passwordChangedAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      fullName: json['full_name'],
      email: json['email'],
      passwordChangedAt: DateTime.parse(json['password_changed_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'email': email,
      'password_changed_at': passwordChangedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
