import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/components/user_avatar.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';

void main() {
  final tUser = UserModel(
    uuid: '1',
    username: 'test',
    fullName: 'Test User',
    email: 'test@example.com',
    passwordChangedAt: DateTime.now(),
    createdAt: DateTime.now(),
  );

  testWidgets('should show initials when userImage is null', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: UserAvatar(user: tUser),
          ),
        ),
      ),
    );

    expect(find.text('TU'), findsOneWidget);
  });

  testWidgets('should show question mark when user is null', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: UserAvatar(user: null),
          ),
        ),
      ),
    );

    expect(find.text('?'), findsOneWidget);
  });
}
