import 'package:flutter/material.dart';

import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Onay diyaloğu (servis başlat/tamamla/iptal gibi kritik işlemler).
/// Kullanıcı onaylarsa true döner.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = S.confirm,
  String cancelLabel = S.cancel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: AppText.h2),
      content: message == null ? null : Text(message, style: AppText.caption),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? AppColors.danger : AppColors.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
