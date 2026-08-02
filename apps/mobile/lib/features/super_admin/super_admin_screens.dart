import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/statuses.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/tenant.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/search_input.dart';
import '../../widgets/service_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../shared/profile_panel.dart';

/// Süper Admin genel bakış: platform geneli istatistikler.
class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenants = ref.watch(tenantsProvider);
    return AppScaffold(
      title: 'Platform Paneli',
      subtitle: 'Genel operasyon durumu',
      onRefresh: () async => ref.refresh(tenantsProvider.future),
      children: [
        tenants.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tenantsProvider)),
          data: (list) {
            final active = list.where((t) => t.status == TenantStatus.active).length;
            final users = list.fold<int>(0, (s, t) => s + t.activeUserCount);
            final trips = list.fold<int>(0, (s, t) => s + t.activeTripCount);
            return Column(
              children: [
                Row(children: [
                  Expanded(child: StatCard(label: 'Toplam Şirket', value: '${list.length}')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: StatCard(label: 'Aktif Şirket', value: '$active', tone: StatTone.success)),
                ]),
                const SizedBox(height: AppSpacing.md),
                Row(children: [
                  Expanded(child: StatCard(label: 'Toplam Kullanıcı', value: '$users')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: StatCard(label: 'Aktif Servis', value: '$trips', tone: StatTone.success, hint: 'Şu an yolda')),
                ]),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Müşteri şirket listesi + arama.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final tenants = ref.watch(tenantsProvider);
    return AppScaffold(
      title: 'Müşteriler',
      onRefresh: () async => ref.refresh(tenantsProvider.future),
      children: [
        SearchInput(onChanged: (v) => setState(() => _search = v), hint: 'Şirket adı veya kodu…'),
        tenants.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tenantsProvider)),
          data: (list) {
            final filtered = list
                .where((t) =>
                    t.name.toLowerCase().contains(_search.toLowerCase()) ||
                    t.companyCode.toLowerCase().contains(_search.toLowerCase()))
                .toList();
            if (filtered.isEmpty) return const EmptyStateView(title: 'Şirket bulunamadı');
            return Column(
              children: [for (final t in filtered) _tenantCard(t)],
            );
          },
        ),
      ],
    );
  }

  Widget _tenantCard(Tenant t) {
    final tone = switch (t.status) {
      TenantStatus.active => BadgeTone.success,
      TenantStatus.suspended => BadgeTone.danger,
      TenantStatus.passive => BadgeTone.neutral,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.name, style: AppText.h3),
                  Text(t.companyCode, style: AppText.tiny),
                ]),
              ),
              StatusBadge(label: t.status.label, tone: tone),
            ]),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${t.activeUserCount}/${t.userLimit} kullanıcı', style: AppText.tiny),
              Text('${t.activeTripCount} aktif servis', style: AppText.tiny),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Platform geneli canlı operasyon özeti.
class LiveOperationsScreen extends ConsumerWidget {
  const LiveOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    return AppScaffold(
      title: 'Canlı Operasyon',
      subtitle: 'Tüm şirketlerde yolda olan servisler',
      onRefresh: () async => ref.refresh(tripsProvider.future),
      children: [
        trips.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tripsProvider)),
          data: (list) {
            final active = list.where((t) => t.status == TripStatus.active || t.status == TripStatus.delayed).toList();
            return Column(children: [
              Row(children: [
                Expanded(child: StatCard(label: 'Yolda', value: '${active.length}', tone: StatTone.success)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: StatCard(label: 'Gecikmeli', value: '${active.where((t) => t.delayMinutes > 0).length}', tone: StatTone.warning)),
              ]),
              const SizedBox(height: AppSpacing.md),
              for (final t in active)
                Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: ServiceCard(trip: t)),
            ]);
          },
        ),
      ],
    );
  }
}

/// Destek talepleri listesi (demo veri).
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _tickets = [
    ('Şoför uygulamaya giriş yapamıyor', 'Atlas Teknoloji', BadgeTone.danger, 'Açık'),
    ('Ek araç limiti talebi', 'Nova Lojistik', BadgeTone.warning, 'Beklemede'),
    ('Fatura sorusu', 'Delta Üretim', BadgeTone.neutral, 'Kapalı'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Destek',
      subtitle: 'Müşteri talepleri',
      children: [
        for (final (subject, company, tone, label) in _tickets)
          AppCard(
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(subject, style: AppText.bodyStrong),
                  Text(company, style: AppText.tiny),
                ]),
              ),
              StatusBadge(label: label, tone: tone),
            ]),
          ),
      ],
    );
  }
}

/// Süper Admin ayarlar/profil.
class SuperAdminSettingsScreen extends StatelessWidget {
  const SuperAdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(title: 'Ayarlar', children: [ProfilePanel()]);
  }
}
