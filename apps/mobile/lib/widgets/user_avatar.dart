import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Kullanıcı avatarı — foto yoksa baş harfler.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.photoUrl, this.size = 40});

  final String name;
  final String? photoUrl;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(radius: size / 2, backgroundImage: NetworkImage(photoUrl!));
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
      child: Text(
        _initials.isEmpty ? '?' : _initials,
        style: AppText.bodyStrong.copyWith(color: AppColors.primary, fontSize: size * 0.38),
      ),
    );
  }
}
