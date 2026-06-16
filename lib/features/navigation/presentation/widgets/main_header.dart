import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../components/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import 'package:ground_guard_app/core/routes/app_routes.dart';

class MainHeader extends ConsumerWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco_rounded, color: Color(0xFF2D4029)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ground Guard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D3520),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1D3520)),
              ),
              const SizedBox(width: 4),
              UserAvatar(
                user: user,
                radius: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
