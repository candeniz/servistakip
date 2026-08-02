import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../data/models/app_notification.dart';
import 'app_card.dart';

/// Bildirim listesi öğesi. Okunmamışsa vurgulanır.
class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: unread ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title,
                    style: AppText.bodyStrong.copyWith(
                        color: unread ? AppColors.text : AppColors.textSecondary)),
                Text(notification.message, style: AppText.caption),
                const SizedBox(height: 2),
                Text(Fmt.relative(notification.createdAt), style: AppText.tiny),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
