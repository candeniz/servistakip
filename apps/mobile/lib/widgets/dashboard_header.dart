import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Dashboard üst çubuğu: menü + uygulama adı + bildirim (kırmızı nokta) + avatar.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.appName});
  final String appName;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.menu, color: AppColors.text),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(appName, style: AppText.h3, maxLines: 1, overflow: TextOverflow.ellipsis)),
      Stack(children: [
        const Padding(padding: EdgeInsets.all(2), child: Icon(Icons.notifications_none_rounded, color: AppColors.text)),
        Positioned(right: 2, top: 0, child: Container(width: 8, height: 8,
            decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle))),
      ]),
      const SizedBox(width: AppSpacing.md),
      const CircleAvatar(radius: 16, backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, size: 18, color: AppColors.primary)),
    ]);
  }
}
