import 'package:ground_guard_app/features/user/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getUserProfile();
  Future<void> updateUserName(String uuid, String fullName);
  Future<void> updateProfileImage(String filePath);
}
