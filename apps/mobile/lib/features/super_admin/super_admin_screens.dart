import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/statuses.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/tenant.dart';
import '../../providers/data_providers.dart';
import '../../core/constants/strings.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/mini_stat_card.dart';
import '../../widgets/service_card.dart';
import '../../widgets/simple_bar_chart.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../shared/profile_panel.dart';

/// Süper Admin genel bakış (Stitch: Sistem Özeti) — platform geneli.
class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenants = ref.watch(tenantsProvider);
    final total = tenants.maybeWhen(data: (l) => l.length, orElse: () => 0);
    final active = tenants.maybeWhen(
        data: (l) => l.where((t) => t.status == TenantStatus.active).length, orElse: () => 0);

    return AppScaffold(
      padded: true,
      onRefresh: () async => ref.refresh(tenantsProvider.future),
      children: [
        const DashboardHeader(appName: S.appName),
        const SizedBox(height: AppSpacing.xs),
        Text('Sistem Özeti', style: AppText.display),
        Row(children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
          Text('Tüm sistemler kararlı. Canlı veri akışı aktif.', style: AppText.monoTiny),
        ]),
        const SizedBox(height: AppSpacing.md),

        // Aksiyon butonları
        Row(children: [
          Expanded(child: PrimaryButton(label: 'Yeni Kayıt', icon: Icons.add, onPressed: () {})),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: SecondaryButton(label: 'Rapor Al', icon: Icons.download, onPressed: () {})),
        ]),
        const SizedBox(height: AppSpacing.md),

        // 2×3 istatistik grid'i
        Row(children: [
          Expanded(child: MiniStatCard(label: 'Toplam Şirket', value: '$total', accent: const DeltaTag(text: '+2.4%'))),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: MiniStatCard(label: 'Aktif Şirket', value: '$active',
              accent: const Icon(Icons.check_circle, size: 18, color: AppColors.success))),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          const Expanded(child: MiniStatCard(label: 'Yolcu Sayısı', value: '12.4k', accent: MiniChip(label: 'Genel'))),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: MiniStatCard(label: 'Kayıtlı Araç', value: '850',
              accent: Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.textSecondary))),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: MiniStatCard(label: 'Aktif Servis', value: '344',
              accent: Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle)))),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: MiniStatCard(label: 'Çevrimiçi Şoför', value: '310',
              accent: Icon(Icons.wifi_tethering, size: 18, color: AppColors.success))),
        ]),
        const SizedBox(height: AppSpacing.lg),

        _supportCard(),
        const SizedBox(height: AppSpacing.md),
        _packageCard(),
        const SizedBox(height: AppSpacing.md),
        _statsCard(),
      ],
    );
  }

  Widget _supportCard() {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bekleyen Destek', style: AppText.h3),
            Text('8 AÇIK TALEP', style: AppText.monoTiny),
          ]),
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.confirmation_number_outlined, color: AppColors.danger, size: 20)),
        ]),
        const SizedBox(height: AppSpacing.md),
        _ticketRow('#42', 'Ödeme Hatası'),
        const Divider(),
        _ticketRow('#45', 'GPS Veri Kesintisi'),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(label: 'Tüm Biletler', onPressed: () {}),
      ]),
    );
  }

  Widget _ticketRow(String id, String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(4)),
              child: Text(id, style: AppText.monoTiny.copyWith(color: AppColors.primary))),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(title, style: AppText.body)),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ]),
      );

  Widget _packageCard() {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Biten Paketler', style: AppText.h3),
            Text('5 KRİTİK FİRMA', style: AppText.monoTiny),
          ]),
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.warning, size: 20)),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: 0.85, minHeight: 8,
                  backgroundColor: AppColors.surfaceAlt, color: AppColors.primary))),
          const SizedBox(width: AppSpacing.sm),
          Text('85%', style: AppText.monoLabel),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text('Yenileme oranı geçen aya göre %4 arttı.', style: AppText.caption),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'Yenilemeleri Başlat', variant: ButtonVariant.primary, onPressed: () {}),
      ]),
    );
  }

  Widget _statsCard() {
    const bars = [
      BarDatum(label: '1 HAZ', value: 320),
      BarDatum(label: '5 HAZ', value: 512, highlight: true),
      BarDatum(label: '10 HAZ', value: 280),
      BarDatum(label: '15 HAZ', value: 360),
      BarDatum(label: '20 HAZ', value: 300),
      BarDatum(label: '25 HAZ', value: 210, highlight: false),
      BarDatum(label: '30 HAZ', value: 340),
    ];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Son 30 Günlük Sefer İstatistiği', style: AppText.h3),
        Text('Tamamlanan, iptal edilen ve geciken seferlerin dağılımı.', style: AppText.caption),
        const SizedBox(height: AppSpacing.md),
        const SimpleBarChart(data: bars),
      ]),
    );
  }
}


/// Müşteri Yönetimi (Stitch): filtre çipleri + zengin şirket kartları.
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

enum _CustomerFilter { all, active, passive, expiring, trial, enterprise }

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  _CustomerFilter _filter = _CustomerFilter.all;

  bool _matches(Tenant t) => switch (_filter) {
        _CustomerFilter.all => true,
        _CustomerFilter.active => t.status == TenantStatus.active,
        _CustomerFilter.passive => t.status == TenantStatus.passive,
        _CustomerFilter.expiring => t.endDate.contains('Doldu') || t.endDate.startsWith('05'),
        _CustomerFilter.trial => t.packageName.toLowerCase().contains('deneme'),
        _CustomerFilter.enterprise => t.packageName.toLowerCase().contains('enterprise'),
      };

  @override
  Widget build(BuildContext context) {
    final tenants = ref.watch(tenantsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textInverse),
      ),
      body: AppScaffold(
        title: 'Müşteri Yönetimi',
        onRefresh: () async => ref.refresh(tenantsProvider.future),
        children: [
          _filterChips(),
          tenants.when(
            loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
            error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tenantsProvider)),
            data: (list) {
              final filtered = list.where(_matches).toList();
              if (filtered.isEmpty) return const EmptyStateView(title: 'Şirket bulunamadı');
              return Column(children: [for (final t in filtered) _CustomerCard(tenant: t)]);
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    const items = [
      (_CustomerFilter.all, 'Tümü', null),
      (_CustomerFilter.active, 'Aktif', AppColors.success),
      (_CustomerFilter.passive, 'Pasif', null),
      (_CustomerFilter.expiring, 'Süresi Dolan', AppColors.warning),
      (_CustomerFilter.trial, 'Deneme', AppColors.primary),
      (_CustomerFilter.enterprise, 'Enterprise', AppColors.statusPaused),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        Padding(padding: const EdgeInsets.only(top: 6, right: 2),
            child: Text('Filtrele:', style: AppText.monoLabel)),
        for (final (value, label, dot) in items)
          GestureDetector(
            onTap: () => setState(() => _filter = value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _filter == value ? AppColors.primaryDark : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (dot != null) ...[
                  Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                ],
                Text(label, style: AppText.monoTiny.copyWith(
                    color: _filter == value ? AppColors.textInverse : AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ],
    );
  }
}

/// Süper admin müşteri kartı — Stitch tasarımına göre.
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.tenant});
  final Tenant tenant;

  @override
  Widget build(BuildContext context) {
    final active = tenant.status == TenantStatus.active;
    final expired = tenant.endDate.contains('Doldu');
    final expiringSoon = tenant.endDate.startsWith('05.08');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Başlık
          Row(children: [
            Container(width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.business, color: AppColors.primary, size: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tenant.name, style: AppText.h3),
              Text('[KOD: ${tenant.companyCode}]', style: AppText.monoTiny),
            ])),
            Switch(value: active, onChanged: (_) {}, activeThumbColor: AppColors.primary),
          ]),
          const Divider(height: AppSpacing.xl),
          // 3'lü stat
          Row(children: [
            _stat('Kullanıcı', '${tenant.activeUserCount}', AppColors.text),
            _stat('Araç', '${tenant.vehicleCount}', AppColors.text),
            _stat('Aktif İş', '${tenant.activeTripCount}', AppColors.primary),
          ]),
          const Divider(height: AppSpacing.xl),
          // Yönetici / paket / bitiş
          _detailRow(Icons.person_outline, 'Yönetici:', Text(tenant.managerName, style: AppText.bodyStrong)),
          const SizedBox(height: AppSpacing.sm),
          _detailRow(Icons.inventory_2_outlined, 'Paket:', _packageChip(tenant.packageName)),
          const SizedBox(height: AppSpacing.sm),
          _detailRow(Icons.event_outlined, 'Bitiş Tarihi:', Row(mainAxisSize: MainAxisSize.min, children: [
            Text(tenant.endDate, style: AppText.bodyStrong.copyWith(
                color: expired || expiringSoon ? AppColors.danger : AppColors.text)),
            if (expired || expiringSoon) ...[
              const SizedBox(width: 4),
              const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.danger),
            ],
          ])),
          const SizedBox(height: AppSpacing.md),
          // CTA
          Material(
            color: active ? AppColors.primaryLight : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => context.push('/customer/${tenant.id}'),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(active ? 'Detayları Görüntüle' : 'Hesabı İncele',
                      style: AppText.bodyStrong.copyWith(color: active ? AppColors.primary : AppColors.textSecondary)),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: active ? AppColors.primary : AppColors.textSecondary),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(
        child: Column(children: [
          Text(label, style: AppText.monoTiny),
          const SizedBox(height: 2),
          Text(value, style: AppText.h3.copyWith(color: color)),
        ]),
      );

  Widget _detailRow(IconData icon, String label, Widget value) => Row(children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(label, style: AppText.caption),
        const Spacer(),
        value,
      ]);

  Widget _packageChip(String name) {
    final isEnterprise = name.toLowerCase().contains('enterprise');
    final isTrial = name.toLowerCase().contains('deneme');
    final bg = isEnterprise ? AppColors.primary : (isTrial ? AppColors.surfaceAlt : AppColors.infoBg);
    final fg = isEnterprise ? AppColors.textInverse : (isTrial ? AppColors.textSecondary : AppColors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(name, style: AppText.monoTiny.copyWith(color: fg, fontWeight: FontWeight.w600)),
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
