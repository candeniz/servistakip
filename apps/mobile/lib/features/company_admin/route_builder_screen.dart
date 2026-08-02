import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/demo_data.dart';
import '../../widgets/buttons.dart';
import '../../widgets/live_map.dart';

class _BuilderStop {
  const _BuilderStop(this.name, this.time, this.eta, {this.isDepot = false});
  final String name;
  final String time;
  final String? eta;
  final bool isDepot;
}

/// Harita üzerinde rota oluşturma (Stitch): harita + sürüklenebilir durak listesi.
class RouteBuilderScreen extends StatelessWidget {
  const RouteBuilderScreen({super.key});

  static const _stops = [
    _BuilderStop('Merkez Depo', '08:00', null, isDepot: true),
    _BuilderStop('Beşiktaş Meydan', '08:25 (Tahmini)', '+12m'),
    _BuilderStop('Zorlu Center', '08:40 (Tahmini)', '+8m'),
    _BuilderStop('Levent İş Kuleleri', '09:05 (Tahmini)', '+15m'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(children: [
          Positioned.fill(child: LiveMap(stops: demoStops, height: double.infinity)),
          // Üst durak listesi kartı
          Positioned(
            top: AppSpacing.md, left: AppSpacing.md, right: AppSpacing.md,
            child: _stopListCard(context),
          ),
          // Alt özet kartı
          Positioned(
            bottom: AppSpacing.md, left: AppSpacing.md, right: AppSpacing.md,
            child: _summaryCard(context),
          ),
        ]),
      ),
    );
  }

  Widget _stopListCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x1A0B1C30), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            Row(children: [
              Expanded(child: Text('Durak Listesi', style: AppText.h2)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(8)),
                  child: Text('${_stops.length} DURAK', style: AppText.monoTiny.copyWith(color: AppColors.textInverse, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: AppSpacing.xs),
            Row(children: [
              Expanded(child: Text('Sabah / Akşam Rotası', style: AppText.body)),
              Switch(value: false, onChanged: (_) {}, activeThumbColor: AppColors.primary),
            ]),
          ]),
        ),
        Flexible(child: ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: [
          for (final s in _stops) _stopRow(s),
          _addStopRow(),
        ])),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(label: 'Güzergâhı Kaydet', icon: Icons.save_outlined, onPressed: () {}),
        ),
      ]),
    );
  }

  Widget _stopRow(_BuilderStop s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: s.isDepot ? AppColors.primary : AppColors.warning, width: 3),
            bottom: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(children: [
          const Icon(Icons.drag_indicator, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.name, style: AppText.bodyStrong),
            Row(children: [
              const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(s.time, style: AppText.monoTiny),
            ]),
          ])),
          if (s.isDepot) const Icon(Icons.home_outlined, size: 18, color: AppColors.textSecondary),
          if (s.eta != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
            child: Text(s.eta!, style: AppText.monoTiny),
          ),
        ]),
      );

  Widget _addStopRow() => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.warning, width: 3))),
        child: Row(children: [
          const Icon(Icons.drag_indicator, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('Durak Adı Ekle…', style: AppText.body.copyWith(color: AppColors.textMuted))),
          const Icon(Icons.add_location_alt_outlined, size: 18, color: AppColors.textSecondary),
        ]),
      );

  Widget _summaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x1A0B1C30), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TOPLAM MESAFE', style: AppText.monoLabel),
            Text.rich(TextSpan(children: [
              TextSpan(text: '24.8', style: AppText.statValue.copyWith(fontSize: 26)),
              TextSpan(text: ' km', style: AppText.caption),
            ])),
          ])),
          Container(width: 1, height: 40, color: AppColors.border),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TAHMİNİ SÜRE', style: AppText.monoLabel),
            Text.rich(TextSpan(children: [
              TextSpan(text: '52', style: AppText.statValue.copyWith(fontSize: 26)),
              TextSpan(text: ' dk', style: AppText.caption),
            ])),
          ])),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('CANLI TRAFİK AKTİF', style: AppText.monoTiny.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
          const Spacer(),
          SizedBox(width: 90, height: 44, child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('İptal', style: AppText.monoStrong.copyWith(color: AppColors.primary, fontSize: 13)),
          )),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 110, child: PrimaryButton(label: 'Yayınla', variant: ButtonVariant.primary, onPressed: () => context.pop())),
        ]),
      ]),
    );
  }
}
