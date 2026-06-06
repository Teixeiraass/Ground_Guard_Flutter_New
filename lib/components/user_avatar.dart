import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/features/user/data/models/user_model.dart';
import 'package:ground_guard_app/core/util/api_config.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:ground_guard_app/features/user/presentation/providers/user_provider.dart';

class UserAvatar extends ConsumerWidget {
  final UserModel? user;
  final double radius;
  final bool showBorder;

  const UserAvatar({
    super.key,
    this.user,
    this.radius = 22,
    this.showBorder = false,
  });

  String get _initials {
    if (user == null || user!.fullName.isEmpty) return '?';
    final names = user!.fullName.trim().split(' ');
    if (names.length >= 2) {
      return (names[0][0] + names[1][0]).toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var imageUrl = ApiConfig.getFullImageUrl(user?.userImage);
    
    // Pegamos a versão estável da imagem do provider
    final imageVersion = ref.watch(userImageVersionProvider);
    
    if (imageUrl.isNotEmpty) {
      imageUrl = imageUrl.contains('?') 
          ? '$imageUrl&v=$imageVersion' 
          : '$imageUrl?v=$imageVersion';
    }

    Widget avatar;
    if (imageUrl.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          imageUrl,
          key: ValueKey(imageUrl), // A URL só muda se a versão no provider mudar
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildInitialsAvatar();
          },
        ),
      );
    } else {
      avatar = _buildInitialsAvatar();
    }

    if (showBorder) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
