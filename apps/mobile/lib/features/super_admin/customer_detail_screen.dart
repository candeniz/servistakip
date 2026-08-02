import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/statuses.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/demo_data.dart';
import '../../data/models/tenant.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/buttons.dart';
import '../../widgets/service_card.dart';
import '../../widgets/simple_bar_chart.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vehicle_card.dart';

/// Süper admin müşteri detay ekranı (Stitch) — sekmeli, zengin içerik.
class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({super.key, required this.tenantId});
  final String tenantId;

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  int _tab = 0;
  static const _tabs = ['Genel Bilgiler', 'Kullanıcılar', 'Araç Filosu', 'Servisler'];

  @override
  Widget build(BuildContext context) {
    final tenants = ref.watch(tenantsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: tenants.when(
          loading: () => const LoadingState(),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tenantsProvider)),
          data: (list) {
            final tenant = list.firstWhere((t) => t.id == widget.tenantId, orElse: () => list.first);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _breadcrumb(context, tenant),
                const SizedBox(height: AppSpacing.md),
                _titleBlock(tenant),
                const SizedBox(height: AppSpacing.md),
                _actionButtons(),
                const SizedBox(height: AppSpacing.lg),
                _tabBar(),
                const SizedBox(height: AppSpacing.lg),
                _tabContent(tenant),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _breadcrumb(BuildContext context, Tenant t) => Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Text('Müşteriler', style: AppText.monoTiny.copyWith(color: AppColors.primary)),
        ),
        Text('  ›  ${t.name}', style: AppText.monoTiny, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]);

  Widget _titleBlock(Tenant t) {
    final active = t.status == TenantStatus.active;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.business, color: AppColors.primary)),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.name, style: AppText.h1),
        const SizedBox(height: 4),
        Row(children: [
          StatusBadge(label: active ? 'Aktif' : 'Pasif', tone: active ? BadgeTone.success : BadgeTone.neutral),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 2),
          Text('İstanbul, TR', style: AppText.monoTiny),
        ]),
      ])),
      IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: AppColors.textSecondary)),
    ]);
  }

  Widget _actionButtons() => Row(children: [
        Expanded(child: PrimaryButton(label: 'Sisteme Gir (İzle)', icon: Icons.visibility_outlined, onPressed: () {})),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: SecondaryButton(label: 'Paket Yükselt', icon: Icons.upgrade, onPressed: () {})),
      ]);

  Widget _tabBar() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < _tabs.length; i++)
            GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.lg),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                      color: _tab == i ? AppColors.primary : Colors.transparent, width: 2.5)),
                ),
                child: Text(_tabs[i], style: (_tab == i ? AppText.bodyStrong : AppText.body).copyWith(
                    color: _tab == i ? AppColors.text : AppColors.textMuted)),
              ),
            ),
        ]),
      );

  Widget _tabContent(Tenant t) => switch (_tab) {
        1 => _usersTab(),
        2 => _fleetTab(),
        3 => _servicesTab(),
        _ => _generalTab(t),
      };

  // ── Genel Bilgiler ──
  Widget _generalTab(Tenant t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _accentStat('Aktif Araçlar', '${t.vehicleCount}', AppColors.primary,
          trailing: const DeltaTrailing()),
      const SizedBox(height: AppSpacing.md),
      _accentStat('Günlük Servis', '2,840', AppColors.success,
          trailing: Text('Limit: 5k', style: AppText.monoTiny)),
      const SizedBox(height: AppSpacing.md),
      _accentStat('API Çağrıları', '85k', AppColors.warning,
          trailing: SizedBox(width: 70, child: ClipRRect(borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: 0.6, minHeight: 6,
                  backgroundColor: AppColors.surfaceAlt, color: AppColors.primary)))),
      const SizedBox(height: AppSpacing.lg),
      _chartCard(),
      const SizedBox(height: AppSpacing.md),
      _contractCard(t),
      const SizedBox(height: AppSpacing.md),
      _packageCard(),
      const SizedBox(height: AppSpacing.md),
      _quickActionsCard(),
      const SizedBox(height: AppSpacing.md),
      _activityCard(),
    ]);
  }

  Widget _accentStat(String label, String value, Color accent, {required Widget trailing}) => AppCard(
        accentColor: accent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: AppText.monoLabel),
          const SizedBox(height: AppSpacing.xs),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Text(value, style: AppText.statValue.copyWith(fontSize: 30))),
            trailing,
          ]),
        ]),
      );

  Widget _chartCard() {
    const bars = [
      BarDatum(label: '01 EYL', value: 1400),
      BarDatum(label: '10 EYL', value: 2800, highlight: true),
      BarDatum(label: '20 EYL', value: 1800),
      BarDatum(label: '25 EYL', value: 2200),
      BarDatum(label: '30 EYL', value: 2000),
    ];
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Servis Kullanım Grafiği', style: AppText.h3),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Text('Son 30 Gün', style: AppText.monoTiny),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
            ])),
      ]),
      const SizedBox(height: AppSpacing.md),
      const SimpleBarChart(data: bars),
    ]));
  }

  Widget _contractCard(Tenant t) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Sözleşme Bilgileri', style: AppText.h3),
          Text('Düzenle', style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
        ]),
        const SizedBox(height: AppSpacing.md),
        _kv('SÖZLEŞME BİTİŞ', '12 Aralık 2024'),
        _kv('FATURA PERİYODU', 'Aylık (Döviz Endeksli)'),
        _kv('VERGİ DAİRESİ / NO', 'Zincirlikuyu V.D. / 4580221921'),
        Row(children: [
          Expanded(child: Text('HESAP YÖNETİCİSİ', style: AppText.monoLabel)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const CircleAvatar(radius: 8, backgroundColor: AppColors.primary),
          const SizedBox(width: 6),
          Text(t.managerName.isEmpty ? 'Canan Yılmaz' : t.managerName, style: AppText.bodyStrong),
        ]),
      ]));

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: AppText.monoLabel),
          const SizedBox(height: 2),
          Text(v, style: AppText.bodyStrong),
        ]),
      );

  Widget _packageCard() => AppCard(
        color: AppColors.primaryDark,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MEVCUT PAKET', style: AppText.monoLabel.copyWith(color: AppColors.borderStrong)),
          const SizedBox(height: 2),
          Text('Enterprise Pro+', style: AppText.h1.copyWith(color: AppColors.textInverse)),
          const SizedBox(height: AppSpacing.md),
          _feature('Sınırsız Alt Kullanıcı'),
          _feature('7/24 Teknik Destek'),
          _feature('API Access (L2)'),
          const SizedBox(height: AppSpacing.md),
          SizedBox(height: 46, width: double.infinity, child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderStrong),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Limitleri Yönet', style: AppText.monoStrong.copyWith(color: AppColors.textInverse)),
          )),
        ]),
      );

  Widget _feature(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppText.body.copyWith(color: AppColors.textInverse)),
        ]),
      );

  Widget _quickActionsCard() => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hızlı İşlemler', style: AppText.h3),
        const SizedBox(height: AppSpacing.sm),
        _actionRow(Icons.lock_reset, 'Şifre Sıfırla (Admin)', false),
        _actionRow(Icons.pause_circle_outline, 'Hesabı Askıya Al', false),
        _actionRow(Icons.download, 'Log Kayıtlarını İndir', false),
        _actionRow(Icons.delete_outline, 'Müşteriyi Sil', true),
      ]));

  Widget _actionRow(IconData icon, String label, bool danger) {
    final color = danger ? AppColors.danger : AppColors.text;
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(children: [
          Icon(icon, size: 20, color: danger ? AppColors.danger : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppText.body.copyWith(color: color))),
          if (!danger) const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
        ]),
      ),
    );
  }

  Widget _activityCard() => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Son Aktiviteler', style: AppText.h3),
        const SizedBox(height: AppSpacing.md),
        _activityRow(AppColors.primary, 'Admin yeni bir araç ekledi:', '34 ABC 123', '2 saat önce'),
        _activityRow(AppColors.success, 'Sistem otomatik rapor oluşturdu:', 'Haftalık Verimlilik', 'Dün, 14:05'),
        _activityRow(AppColors.textMuted, 'Müşteri destek talebi oluşturdu:', '#8821 – API Entegrasyonu', '2 gün önce'),
      ]));

  Widget _activityRow(Color dot, String text, String highlight, String time) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(TextSpan(style: AppText.body, children: [
              TextSpan(text: '$text '),
              TextSpan(text: highlight, style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
            ])),
            Text(time, style: AppText.monoTiny),
          ])),
        ]),
      );

  // ── Diğer sekmeler (gerçek listeler) ──
  Widget _usersTab() => Column(children: [
        for (final p in demoTripPassengers.take(8))
          AppCard(child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: AppColors.primaryLight,
                child: Text(p.passengerName.substring(0, 1),
                    style: AppText.bodyStrong.copyWith(color: AppColors.primary))),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.passengerName, style: AppText.bodyStrong),
              Text('Personel · ${p.stopName}', style: AppText.monoTiny),
            ])),
          ])),
      ]);

  Widget _fleetTab() => Column(children: [
        for (final v in demoVehicles) Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md), child: VehicleCard(vehicle: v)),
      ]);

  Widget _servicesTab() => Column(children: [
        for (final t in demoTrips) Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ServiceCard(trip: t, onTap: () => context.push('/trip/${t.id}'))),
      ]);
}

/// "+12%" yeşil trend etiketi.
class DeltaTrailing extends StatelessWidget {
  const DeltaTrailing({super.key});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.trending_up, size: 16, color: AppColors.success),
        const SizedBox(width: 2),
        Text('+12%', style: AppText.monoTiny.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
      ]);
}
