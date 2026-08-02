import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/demo_data.dart';
import '../../providers/simulation_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/live_map.dart';

/// Yolculuk Özeti (Stitch): şoför servis tamamlama özeti.
class TripSummaryScreen extends ConsumerWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sim = ref.watch(simulationControllerProvider);
    final boarded = sim.passengers.where((p) => p.boardingStatus.value == 'boarded').length;
    final noShow = sim.passengers.length - boarded;

    return AppScaffold(
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(child: Column(children: [
          Container(width: 72, height: 72, alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.check, color: AppColors.textInverse, size: 40)),
          const SizedBox(height: AppSpacing.md),
          Text('Tebrikler!', style: AppText.h1),
          Text('Yolculuk başarıyla tamamlandı ve veriler işlendi.',
              style: AppText.caption, textAlign: TextAlign.center),
        ])),
        const SizedBox(height: AppSpacing.md),
        _metricCard(Icons.schedule, 'Süre', '52 dk'),
        _metricCard(Icons.place_outlined, 'Mesafe', '24.8 km'),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.danger),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(6)),
                child: Text('[GEÇ KALMA]', style: AppText.monoTiny.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text('${demoTrip.delayMinutes} dk Gecikmeli Tamamlandı', style: AppText.h3),
        ])),
        AppCard(child: Row(children: [
          Expanded(child: _countCol(Icons.people_outline, 'BİNEN', '$boarded', AppColors.primary)),
          Container(width: 1, height: 44, color: AppColors.border),
          Expanded(child: _countCol(Icons.person_off_outlined, 'GELMEYEN', '$noShow', AppColors.danger)),
        ])),
        Stack(children: [
          LiveMap(stops: demoStops, routePath: demoSimulationPath, height: 180),
          Positioned(left: AppSpacing.md, bottom: AppSpacing.md, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
            child: Text('GÜZERGÂH ÖZETİ', style: AppText.monoTiny.copyWith(fontWeight: FontWeight.w700)),
          )),
        ]),
        PrimaryButton(label: 'Servisi Tamamla', icon: Icons.flag_outlined, onPressed: () {
          ref.read(simulationControllerProvider.notifier).stop();
          context.go('/driver');
        }),
        SecondaryButton(label: 'Detaylı Raporu Görüntüle', onPressed: () {}),
      ],
    );
  }

  Widget _metricCard(IconData icon, String label, String value) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const Spacer(),
            Text(label.toUpperCase(), style: AppText.monoLabel),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppText.statValue.copyWith(fontSize: 30)),
        ]),
      );

  Widget _countCol(IconData icon, String label, String value, Color color) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppText.monoLabel.copyWith(color: color)),
        ]),
        Text(value, style: AppText.statValue.copyWith(fontSize: 28, color: color)),
      ]);
}
