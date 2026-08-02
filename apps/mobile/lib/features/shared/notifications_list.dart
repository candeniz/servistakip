import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../providers/data_providers.dart';
import '../../widgets/notification_card.dart';
import '../../widgets/state_views.dart';

/// Bildirim listesini yükleyip gösteren paylaşılan bileşen (şoför/yolcu).
class NotificationsListView extends ConsumerWidget {
  const NotificationsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return notifications.when(
      loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
      error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(notificationsProvider)),
      data: (list) => list.isEmpty
          ? const EmptyStateView(title: 'Bildirim yok', icon: '🔔')
          : Column(children: [
              for (final n in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NotificationCard(notification: n),
                ),
            ]),
    );
  }
}
