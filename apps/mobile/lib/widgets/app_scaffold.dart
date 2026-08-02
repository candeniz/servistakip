import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Tüm ekranların ortak kabuğu: AppBar (opsiyonel) + kaydırılabilir gövde.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.action,
    this.onRefresh,
    this.scrollable = true,
    this.padded = true,
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final Future<void> Function()? onRefresh;
  final bool scrollable;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title == null
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              actions: action == null
                  ? null
                  : [Padding(padding: const EdgeInsets.only(right: AppSpacing.md), child: action!)],
            ),
      body: SafeArea(top: title == null, child: body),
    );
  }

  Widget _buildBody() {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );

    final padding = padded ? const EdgeInsets.all(AppSpacing.lg) : EdgeInsets.zero;

    if (!scrollable) {
      return Padding(padding: padding, child: content);
    }

    final scroll = SingleChildScrollView(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      child: content,
    );

    if (onRefresh == null) return scroll;
    return RefreshIndicator(onRefresh: onRefresh!, color: AppColors.primary, child: scroll);
  }
}
