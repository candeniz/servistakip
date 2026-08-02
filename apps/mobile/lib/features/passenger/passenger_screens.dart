import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/demo_data.dart';
import '../../providers/live_trip_providers.dart';
import '../../providers/simulation_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/eta_widget.dart';
import '../../widgets/live_map.dart';
import '../../widgets/remaining_stops_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stop_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/trip_status_card.dart';
import '../../widgets/user_avatar.dart';
import '../shared/notifications_list.dart';
import '../shared/profile_panel.dart';

/// Yolcu canlı servis ana ekranı: harita + ETA + kalan durak + şoför bilgisi.
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
      return const AppScaffold(
        title: S.myService,
        children: [Padding(padding: EdgeInsets.all(40), child: LoadingState(message: 'Servis konumu alınıyor…'))],
      );
    }

    final nextStop = demoStops[sim.nextStopIndex.clamp(0, demoStops.length - 1)];
    final targetStop = demoStops[passengerStopIndex];

    return AppScaffold(
      title: S.myService,
      subtitle: demoTrip.serviceName,
      children: [
        if (eta.delayMinutes > 0)
          OfflineBanner(message: 'Servis ${eta.delayMinutes} dk gecikmeli', tone: BannerTone.warning),
        if (sim.finished)
          const OfflineBanner(message: 'Servis durağınıza ulaştı 🎉', tone: BannerTone.warning),
        EtaWidget(eta: eta),
        RemainingStopsCard(
          remainingStops: eta.remainingStops,
          passengerStopName: targetStop.name,
          nextStopName: nextStop.name,
        ),
        LiveMap(
          vehicleLocation: sim.location,
          vehicleHeading: sim.heading,
          stops: demoStops,
          routePath: demoSimulationPath,
          highlightStopId: targetStop.id,
        ),
        Align(alignment: Alignment.centerLeft, child: Text(S.driverInfo.toUpperCase(), style: AppText.label)),
        AppCard(
          child: Row(children: [
            UserAvatar(name: demoTrip.driverName, size: 44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(demoTrip.driverName, style: AppText.bodyStrong),
                Text('${demoTrip.vehiclePlate} · ${demoStops.length} durak', style: AppText.caption),
              ]),
            ),
          ]),
        ),
        SecondaryButton(label: S.absentToday, onPressed: () => context.go('/passenger/my-service')),
      ],
    );
  }
}

/// Yolcu servis detayı + durak zaman çizelgesi + "bugün binmeyeceğim".
class MyServiceScreen extends ConsumerStatefulWidget {
  const MyServiceScreen({super.key});

  @override
  ConsumerState<MyServiceScreen> createState() => _MyServiceScreenState();
}

class _MyServiceScreenState extends ConsumerState<MyServiceScreen> {
  bool _morning = false;
  bool _evening = false;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationControllerProvider);
    return AppScaffold(
      title: S.myService,
      subtitle: demoTrip.routeName,
      children: [
        TripStatusCard(trip: demoTrip),
        Align(alignment: Alignment.centerLeft, child: Text('DURAKLAR', style: AppText.label)),
        AppCard(
          child: StopTimeline(
            stops: demoStops,
            nextStopIndex: sim.nextStopIndex,
            highlightStopId: PassengerSnapshot.passengerStopId,
          ),
        ),
        Align(alignment: Alignment.centerLeft, child: Text(S.absentToday.toUpperCase(), style: AppText.label)),
        AppCard(
          child: Column(children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sabah servisine binmeyeceğim', style: AppText.body),
              value: _morning,
              onChanged: (v) => setState(() => _morning = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Akşam servisine binmeyeceğim', style: AppText.body),
              value: _evening,
              onChanged: (v) => setState(() => _evening = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: _saved ? 'Kaydedildi ✓' : 'Bildir',
              onPressed: (_morning || _evening)
                  ? () {
                      setState(() => _saved = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _saved = false);
                      });
                    }
                  : null,
            ),
          ]),
        ),
      ],
    );
  }
}

/// Yolcu bildirimleri.
class PassengerNotificationsScreen extends StatelessWidget {
  const PassengerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppScaffold(title: 'Bildirimler', children: [NotificationsListView()]);
}

/// Yolcu geçmiş yolculukları (demo veri).
class PassengerHistoryScreen extends StatelessWidget {
  const PassengerHistoryScreen({super.key});

  static const _history = [
    ('2026-08-01', 'Avrupa Yakası Sabah Servisi', true),
    ('2026-07-31', 'Avrupa Yakası Akşam Servisi', false),
    ('2026-07-31', 'Avrupa Yakası Sabah Servisi', true),
    ('2026-07-30', 'Avrupa Yakası Akşam Servisi', true),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Geçmiş',
      subtitle: 'Önceki yolculuklarınız',
      children: [
        for (final (date, name, onTime) in _history)
          AppCard(
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: AppText.bodyStrong),
                  Text(Fmt.date(DateTime.parse(date)), style: AppText.tiny),
                ]),
              ),
              StatusBadge(
                label: onTime ? 'Zamanında' : 'Gecikmeli',
                tone: onTime ? BadgeTone.success : BadgeTone.warning,
              ),
            ]),
          ),
      ],
    );
  }
}

/// Yolcu profili.
class PassengerProfileScreen extends StatelessWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppScaffold(title: 'Profil', children: [ProfilePanel()]);
}
