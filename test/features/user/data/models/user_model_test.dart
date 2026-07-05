import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final tUserJson = {
      'uuid': '123',
      'username': 'joao',
      'full_name': 'João Silva',
      'email': 'joao@example.com',
      'user_image': 'image.png',
      'password_changed_at': '2023-01-01T00:00:00Z',
      'created_at': '2023-01-01T00:00:00Z',
    };

    test('should return a valid model from JSON', () {
      final result = UserModel.fromJson(tUserJson);

      expect(result.uuid, '123');
      expect(result.fullName, 'João Silva');
      expect(result.email, 'joao@example.com');
    });

    test('should return a JSON map containing proper data', () {
      final model = UserModel(
        uuid: '123',
        username: 'joao',
        fullName: 'João Silva',
        email: 'joao@example.com',
        userImage: 'image.png',
        passwordChangedAt: DateTime.parse('2023-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
      );

      final result = model.toJson();

      expect(result['uuid'], '123');
      expect(result['full_name'], 'João Silva');
    });
  });
}
