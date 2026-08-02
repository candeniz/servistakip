import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/demo_data.dart';
import '../../providers/live_trip_providers.dart';
import '../../providers/simulation_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/live_map.dart';
import '../../widgets/plate_chip.dart';
import '../../widgets/state_views.dart';
import '../../widgets/trip_progress_stepper.dart';
import '../shared/notifications_list.dart';
import '../shared/profile_panel.dart';

/// Yolcu canlı servis ana ekranı (Stitch): büyük başlık + 2×2 bilgi kutuları +
/// yolculuk süreci + varışta bildir + şoför kartı.
class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simulationControllerProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationControllerProvider);
    final eta = ref.watch(passengerEtaProvider);

    if (sim.location == null || eta == null) {
      return const AppScaffold(title: S.myService, children: [
        Padding(padding: EdgeInsets.all(40), child: LoadingState(message: 'Servis konumu alınıyor…')),
      ]);
    }

    final nextStop = demoStops[sim.nextStopIndex.clamp(0, demoStops.length - 1)];
    final targetStop = demoStops[passengerStopIndex];
    final activeStep = sim.finished ? 2 : (sim.running ? 1 : 0);

    return AppScaffold(
      title: S.myService,
      subtitle: demoTrip.serviceName,
      children: [
        LiveMap(
          vehicleLocation: sim.location, vehicleHeading: sim.heading,
          stops: demoStops, routePath: demoSimulationPath, highlightStopId: targetStop.id, height: 220,
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text('Servisiniz ${eta.remainingStops} durak uzakta', style: AppText.h1)),
              if (eta.delayMinutes > 0) Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Text('GECİKME', style: AppText.monoTiny.copyWith(color: AppColors.textInverse)),
                  Text('+${eta.delayMinutes} dk', style: AppText.bodyStrong.copyWith(color: AppColors.dangerBg)),
                ]),
              ),
            ]),
            const SizedBox(height: 4),
            Text.rich(TextSpan(style: AppText.body, children: [
              const TextSpan(text: 'Tahmini varış: '),
              TextSpan(text: '~${eta.etaMinutes} dakika', style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
            ])),
            const Divider(height: AppSpacing.xl),
            Row(children: [
              Expanded(child: InfoTile(icon: Icons.schedule, label: 'Planlanan', value: Fmt.time(eta.plannedArrivalAt))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: InfoTile(icon: Icons.update, label: 'Güncel', value: Fmt.time(eta.estimatedArrivalAt), valueColor: AppColors.primary)),
            ]),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(child: InfoTile(icon: Icons.place_outlined, label: 'Kalan Durak', value: '${eta.remainingStops}')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: InfoTile(icon: Icons.badge_outlined, label: 'Plaka', value: '',
                  valueWidget: PlateChip(plate: demoTrip.vehiclePlate, dense: true))),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Text('YOLCULUK SÜRECİ', style: AppText.monoLabel),
            const SizedBox(height: AppSpacing.md),
            TripProgressStepper(steps: const ['Depo', 'Yolda', 'Durak'], activeIndex: activeStep),
          ]),
        ),
        PrimaryButton(label: 'Varışta Bildir', icon: Icons.notifications_active_outlined, onPressed: () {}),
        _driverCard(nextStop.name),
        SecondaryButton(label: S.absentToday, onPressed: () => context.push('/absent')),
      ],
    );
  }

  Widget _driverCard(String nextStopName) => AppCard(
        child: Row(children: [
          const CircleAvatar(radius: 22, backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.primary)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SÜRÜCÜ', style: AppText.monoLabel),
            Text(demoTrip.driverName, style: AppText.bodyStrong),
          ])),
          _circleIcon(Icons.call),
          const SizedBox(width: AppSpacing.sm),
          _circleIcon(Icons.chat_bubble_outline),
        ]),
      );

  Widget _circleIcon(IconData icon) => Container(
        width: 42, height: 42,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      );
}

/// Servis & Durak Detayları (Stitch): sabah/akşam + harita + şoför + mevcut durak.
class MyServiceScreen extends ConsumerStatefulWidget {
  const MyServiceScreen({super.key});

  @override
  ConsumerState<MyServiceScreen> createState() => _MyServiceScreenState();
}

class _MyServiceScreenState extends ConsumerState<MyServiceScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationControllerProvider);
    final currentStop = demoStops[sim.nextStopIndex.clamp(0, demoStops.length - 1)];

    return AppScaffold(
      title: demoTrip.routeName,
      subtitle: 'Operasyonel Servis Detayı',
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Sabah'), icon: Icon(Icons.wb_sunny_outlined)),
            ButtonSegment(value: 1, label: Text('Akşam'), icon: Icon(Icons.nightlight_outlined)),
          ],
          selected: {_segment},
          onSelectionChanged: (s) => setState(() => _segment = s.first),
        ),
        Stack(children: [
          LiveMap(vehicleLocation: sim.location, stops: demoStops, routePath: demoSimulationPath, height: 220),
          Positioned(left: AppSpacing.md, bottom: AppSpacing.md, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('CANLI TAKİP AKTİF', style: AppText.monoTiny.copyWith(color: AppColors.text, fontWeight: FontWeight.w700)),
            ]),
          )),
        ]),
        _driverInfoCard(),
        _currentStopCard(currentStop.name, sim),
        _stopDetailsCard(sim),
      ],
    );
  }

  Widget _driverInfoCard() => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Şoför Bilgisi', style: AppText.bodyStrong),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            const CircleAvatar(radius: 24, backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.primary)),
            const SizedBox(width: AppSpacing.md),
            Text(demoTrip.driverName, style: AppText.bodyStrong),
            const SizedBox(width: AppSpacing.sm),
            PlateChip(plate: demoTrip.vehiclePlate, dense: true),
          ]),
          const Divider(height: AppSpacing.xl),
          Text('ARAÇ MARKA / MODEL', style: AppText.monoLabel),
          Text('Mercedes-Benz Sprinter 2023', style: AppText.bodyStrong),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: PrimaryButton(label: 'Ara', icon: Icons.call, onPressed: () {})),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: SecondaryButton(label: 'Mesaj', icon: Icons.chat_bubble_outline, onPressed: () {})),
          ]),
        ]),
      );

  Widget _currentStopCard(String stopName, SimulationState sim) => AppCard(
        color: AppColors.primary,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MEVCUT DURAK', style: AppText.monoLabel.copyWith(color: AppColors.primaryLight)),
          Text(stopName, style: AppText.h2.copyWith(color: AppColors.textInverse)),
          Divider(height: AppSpacing.xl, color: AppColors.textInverse.withValues(alpha: 0.25)),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gecikme', style: AppText.caption.copyWith(color: AppColors.primaryLight)),
              Text('+${demoTrip.delayMinutes} dk', style: AppText.h3.copyWith(color: AppColors.textInverse)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Yolcu', style: AppText.caption.copyWith(color: AppColors.primaryLight)),
              Text('${sim.passengers.where((p) => p.boardingStatus.value == 'boarded').length} / ${sim.passengers.length}',
                  style: AppText.h3.copyWith(color: AppColors.textInverse)),
            ])),
          ]),
        ]),
      );

  Widget _stopDetailsCard(SimulationState sim) {
    final distances = ['500m', '2.4km', '8.1km', '11.2km', '14.0km', '17.5km', '20.1km', '22.4km'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('Durak Detayları', style: AppText.h3)),
        Text('Tümünü Gör →', style: AppText.monoTiny.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: AppSpacing.sm),
      AppCard(padding: EdgeInsets.zero, child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: const BoxDecoration(color: AppColors.surfaceTile,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Row(children: [
            Expanded(flex: 4, child: Text('DURAK ADI', style: AppText.monoLabel)),
            Expanded(flex: 3, child: Text('MESAFE', style: AppText.monoLabel)),
            Expanded(flex: 3, child: Text('PLANLANAN', style: AppText.monoLabel)),
          ]),
        ),
        for (var i = 0; i < demoStops.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(border: i < demoStops.length - 1
                ? const Border(bottom: BorderSide(color: AppColors.border)) : null),
            child: Row(children: [
              Expanded(flex: 4, child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(
                    color: i < sim.nextStopIndex ? AppColors.success
                        : (i == sim.nextStopIndex ? AppColors.primary : AppColors.border),
                    shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(demoStops[i].name, style: AppText.body, maxLines: 2, overflow: TextOverflow.ellipsis)),
              ])),
              Expanded(flex: 3, child: Text(distances[i % distances.length], style: AppText.body)),
              Expanded(flex: 3, child: Text('0${6 + (demoStops[i].plannedArrivalOffset ~/ 15)}:${(demoStops[i].plannedArrivalOffset % 60).toString().padLeft(2, '0')}',
                  style: AppText.monoTiny)),
            ]),
          ),
      ])),
    ]);
  }
}

/// Yolcu bildirimleri.
class PassengerNotificationsScreen extends StatelessWidget {
  const PassengerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppScaffold(title: 'Bildirimler', children: [NotificationsListView()]);
}

/// Yolculuk Geçmişi (Stitch): aylık özet + geçmiş yolculuk kartları.
class PassengerHistoryScreen extends StatelessWidget {
  const PassengerHistoryScreen({super.key});

  // (tarih, hat, planlanan, gerçekleşen, gecikme, durum) — durum: 0 bindi, 1 binmedi, 2 gecikmeli-bindi
  static const _history = [
    ('24 Ekim Perşembe', 'Maslak - Kadıköy Hattı', '18:15', '18:18', '3 DK', 0),
    ('24 Ekim Perşembe', 'Levent - Beşiktaş Hattı', '08:30', '--:--', '--', 1),
    ('23 Ekim Çarşamba', 'Kartal - Kurtköy Hattı', '17:45', '17:57', '12 DK', 2),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Geçmiş',
      subtitle: 'Yolculuk geçmişiniz',
      children: [
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aylık Özet', style: AppText.h2),
          Text('Bu ay toplam 42 başarılı yolculuk gerçekleştirdiniz.', style: AppText.caption),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: _summaryTile('Tamamlanan', '42', AppColors.primary)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _summaryTile('Kaçırılan', '3', AppColors.danger)),
          ]),
        ])),
        const SizedBox(height: AppSpacing.sm),
        for (final (date, line, planned, actual, delay, status) in _history)
          _historyCard(date, line, planned, actual, delay, status),
      ],
    );
  }

  Widget _summaryTile(String label, String value, Color color) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surfaceTile, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(label.toUpperCase(), style: AppText.monoLabel.copyWith(color: color)),
          Text(value, style: AppText.statValue.copyWith(fontSize: 28)),
        ]),
      );

  Widget _historyCard(String date, String line, String planned, String actual, String delay, int status) {
    final accent = switch (status) { 0 => AppColors.success, 1 => AppColors.danger, _ => AppColors.warning };
    final (statusIcon, statusText, statusColor) = switch (status) {
      0 => (Icons.check_circle, 'BİNDİ', AppColors.success),
      1 => (Icons.cancel, 'BİNMEDİ', AppColors.danger),
      _ => (Icons.check_circle, 'BİNDİ', AppColors.success),
    };
    return AppCard(
      accentColor: accent,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(date, style: AppText.bodyStrong),
        Text(line, style: AppText.caption),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: _kv('PLANLANAN', planned)),
          Expanded(child: _kv('GERÇEKLEŞEN', actual)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(child: _kv('GECİKME', delay)),
          Row(children: [
            Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 4),
            Text(statusText, style: AppText.monoTiny.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ]),
    );
  }

  Widget _kv(String k, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k, style: AppText.monoLabel),
        Text(v, style: AppText.bodyStrong),
      ]);
}

/// Yolcu profili.
class PassengerProfileScreen extends StatelessWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppScaffold(title: 'Profil', children: [ProfilePanel()]);
}
