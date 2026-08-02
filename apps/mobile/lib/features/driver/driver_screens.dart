import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/demo_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/simulation_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/live_map.dart';
import '../../widgets/passenger_row.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/trip_status_card.dart';
import '../shared/notifications_list.dart';
import '../shared/profile_panel.dart';

const _checklist = [
  'Araç yakıtı yeterli',
  'Lastik ve fren kontrolü yapıldı',
  'İlk yardım çantası mevcut',
  'Yolcu listesi güncel',
];

/// Şoför ana sayfası: bugünkü servis + servis öncesi kontrol + başlat.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  final List<bool> _checked = List.filled(_checklist.length, false);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final running = ref.watch(simulationControllerProvider).running;
    final allChecked = _checked.every((c) => c);

    return AppScaffold(
      title: 'Merhaba, ${user?.firstName ?? ''}',
      subtitle: 'Bugünkü servisiniz',
      children: [
        TripStatusCard(trip: demoTrip),
        Align(alignment: Alignment.centerLeft, child: Text(S.preTripCheck.toUpperCase(), style: AppText.label)),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < _checklist.length; i++)
                InkWell(
                  onTap: () => setState(() => _checked[i] = !_checked[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(children: [
                      Icon(_checked[i] ? Icons.check_box : Icons.check_box_outline_blank,
                          color: _checked[i] ? AppColors.success : AppColors.border),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(_checklist[i], style: AppText.body)),
                    ]),
                  ),
                ),
            ],
          ),
        ),
        if (running)
          PrimaryButton(
            label: 'Aktif Yolculuğa Git',
            variant: ButtonVariant.success,
            onPressed: () => context.go('/driver/trip'),
          )
        else
          PrimaryButton(
            label: S.startTrip,
            onPressed: allChecked
                ? () async {
                    final ok = await showConfirmationDialog(
                      context,
                      title: 'Servis başlatılsın mı?',
                      message: 'Konum paylaşımı başlayacak ve yolcular bilgilendirilecek.',
                      confirmLabel: S.startTrip,
                    );
                    if (!ok || !context.mounted) return;
                    ref.read(simulationControllerProvider.notifier).start();
                    // Gerçek konum takibini başlat (native/güvenli).
                    await ref.read(locationServiceProvider).start((_) {});
                    if (context.mounted) context.go('/driver/trip');
                  }
                : null,
          ),
        if (!allChecked && !running)
          Text('Servisi başlatmak için tüm kontrolleri tamamlayın.', style: AppText.tiny),
      ],
    );
  }
}

/// Şoför aktif yolculuk ekranı: harita, durak akışı, tamamla/olay.
class DriverTripScreen extends ConsumerStatefulWidget {
  const DriverTripScreen({super.key});

  @override
  ConsumerState<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends ConsumerState<DriverTripScreen> {
  bool _atStop = false;

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationControllerProvider);

    if (!sim.running && !sim.finished) {
      return AppScaffold(
        title: 'Aktif Yolculuk',
        children: [
          const EmptyStateView(
            icon: '🚦',
            title: S.tripNotStarted,
            description: 'Ana sayfadan servis öncesi kontrolü tamamlayıp servisi başlatın.',
          ),
          PrimaryButton(label: 'Ana Sayfaya Dön', onPressed: () => context.go('/driver')),
        ],
      );
    }

    final nextStop = demoStops[sim.nextStopIndex.clamp(0, demoStops.length - 1)];

    return AppScaffold(
      title: demoTrip.serviceName,
      subtitle: '${sim.speedKmh.round()} km/s',
      children: [
        if (sim.finished)
          const OfflineBanner(message: 'Servis tamamlanmak üzere — son durağa ulaşıldı.', tone: BannerTone.warning),
        LiveMap(
          vehicleLocation: sim.location,
          vehicleHeading: sim.heading,
          stops: demoStops,
          routePath: demoSimulationPath,
          height: 280,
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.nextStop.toUpperCase(), style: AppText.label),
            Text(nextStop.name, style: AppText.h2),
            Text(sim.atStopIndex != null ? 'Araç durak yarıçapında' : 'Durağa yaklaşılıyor', style: AppText.caption),
          ]),
        ),
        if (!_atStop)
          PrimaryButton(label: S.arriveStop, onPressed: () => setState(() => _atStop = true))
        else
          PrimaryButton(label: S.departStop, variant: ButtonVariant.success, onPressed: () => setState(() => _atStop = false)),
        SecondaryButton(label: S.reportIncident, onPressed: () => context.push('/incident')),
        PrimaryButton(
          label: S.completeTrip,
          variant: ButtonVariant.danger,
          onPressed: () async {
            final ok = await showConfirmationDialog(
              context,
              title: 'Servis tamamlansın mı?',
              message: 'Konum paylaşımı duracak ve yolculuk kapatılacak.',
              confirmLabel: S.completeTrip,
              destructive: true,
            );
            if (!ok) return;
            await ref.read(locationServiceProvider).stop();
            if (context.mounted) context.go('/trip-summary');
          },
        ),
      ],
    );
  }
}

/// Şoför yolcu listesi: durak bazında biniş durumu işaretleme.
class DriverPassengersScreen extends ConsumerWidget {
  const DriverPassengersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sim = ref.watch(simulationControllerProvider);
    final controller = ref.read(simulationControllerProvider.notifier);
    final boarded = sim.passengers.where((p) => p.boardingStatus.value == 'boarded').length;

    return AppScaffold(
      title: 'Yolcular',
      subtitle: '$boarded/${sim.passengers.length} bindi',
      children: [
        Row(children: [
          Expanded(child: StatCard(label: 'Toplam', value: '${sim.passengers.length}')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: StatCard(label: 'Bindi', value: '$boarded', tone: StatTone.success)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: StatCard(label: 'Kalan', value: '${sim.passengers.length - boarded}')),
        ]),
        for (var i = 0; i < demoStops.length; i++)
          if (sim.passengers.any((p) => p.stopId == demoStops[i].id)) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${demoStops[i].name.toUpperCase()}${i == sim.nextStopIndex ? ' • SIRADAKİ' : ''}',
                style: AppText.label.copyWith(color: i == sim.nextStopIndex ? AppColors.primary : null),
              ),
            ),
            for (final p in sim.passengers.where((p) => p.stopId == demoStops[i].id))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: PassengerRow(
                  passenger: p,
                  onSetStatus: (status) => controller.setPassengerStatus(p.id, status),
                ),
              ),
          ],
      ],
    );
  }
}

/// Şoför bildirimleri.
class DriverNotificationsScreen extends StatelessWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppScaffold(title: 'Bildirimler', children: [NotificationsListView()]);
}

/// Şoför profili.
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppScaffold(title: 'Profil', children: [ProfilePanel()]);
}
