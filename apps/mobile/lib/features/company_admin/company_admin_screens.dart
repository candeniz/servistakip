import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/statuses.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/demo_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/simulation_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/live_map.dart';
import '../../widgets/search_input.dart';
import '../../widgets/service_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/vehicle_card.dart';
import '../shared/profile_panel.dart';

/// Yönetici ana sayfası: şirket özeti + bugünkü servisler.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final trips = ref.watch(tripsProvider);
    return AppScaffold(
      title: 'Merhaba, ${user?.firstName ?? ''}',
      subtitle: user?.tenantName,
      onRefresh: () async => ref.refresh(tripsProvider.future),
      children: [
        trips.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tripsProvider)),
          data: (list) {
            final active = list.where((t) => t.status == TripStatus.active || t.status == TripStatus.delayed).length;
            final pax = list.fold<int>(0, (s, t) => s + t.passengerCount);
            return Column(children: [
              Row(children: [
                Expanded(child: StatCard(label: 'Bugünkü Servis', value: '${list.length}')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: StatCard(label: 'Yolda', value: '$active', tone: StatTone.success)),
              ]),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Expanded(child: StatCard(label: 'Toplam Yolcu', value: '$pax')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: StatCard(label: 'Aktif Araç', value: '$active')),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Align(alignment: Alignment.centerLeft, child: Text('BUGÜNKÜ SERVİSLER', style: AppText.label)),
              const SizedBox(height: AppSpacing.sm),
              for (final t in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ServiceCard(trip: t, onTap: () => context.push('/trip/${t.id}')),
                ),
            ]);
          },
        ),
      ],
    );
  }
}

/// Yönetici canlı takip: aracın haritada gerçek zamanlı konumu.
class AdminLiveScreen extends ConsumerStatefulWidget {
  const AdminLiveScreen({super.key});

  @override
  ConsumerState<AdminLiveScreen> createState() => _AdminLiveScreenState();
}

class _AdminLiveScreenState extends ConsumerState<AdminLiveScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran açılınca simülasyonu başlat (demo).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simulationControllerProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sim = ref.watch(simulationControllerProvider);
    final nextStop = demoStops[sim.nextStopIndex.clamp(0, demoStops.length - 1)];
    return AppScaffold(
      title: 'Canlı Takip',
      subtitle: demoTrip.serviceName,
      children: [
        LiveMap(
          vehicleLocation: sim.location,
          vehicleHeading: sim.heading,
          stops: demoStops,
          routePath: demoSimulationPath,
          height: 300,
        ),
        Row(children: [
          Expanded(child: StatCard(label: 'Hız', value: '${sim.speedKmh.round()} km/s')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: StatCard(label: 'Sıradaki Durak', value: nextStop.name)),
        ]),
        AppCard(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(demoTrip.driverName, style: AppText.bodyStrong),
                Text(demoTrip.vehiclePlate, style: AppText.tiny),
              ]),
            ),
            StatusBadge.trip(demoTrip.delayMinutes > 0 ? TripStatus.delayed : TripStatus.active),
          ]),
        ),
      ],
    );
  }
}

/// Servis listesi.
class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    return AppScaffold(
      title: 'Servisler',
      action: TextButton(onPressed: () => context.push('/new-trip'), child: const Text('+ Yeni')),
      onRefresh: () async => ref.refresh(tripsProvider.future),
      children: [
        trips.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tripsProvider)),
          data: (list) => list.isEmpty
              ? const EmptyStateView(title: 'Servis bulunamadı')
              : Column(children: [
                  for (final t in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ServiceCard(trip: t, onTap: () => context.push('/trip/${t.id}')),
                    ),
                ]),
        ),
      ],
    );
  }
}

/// Kişiler: personel/yolcu ve şoför listeleri (segment kontrolü).
class AdminPeopleScreen extends StatefulWidget {
  const AdminPeopleScreen({super.key});

  @override
  State<AdminPeopleScreen> createState() => _AdminPeopleScreenState();
}

class _AdminPeopleScreenState extends State<AdminPeopleScreen> {
  int _segment = 0;
  String _search = '';

  static const _drivers = [
    ('Mehmet Yılmaz', '34 ST 2026', true),
    ('Ali Vural', '34 XY 1400', true),
    ('Hasan Kaya', '—', false),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Kişiler',
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Personel')),
            ButtonSegment(value: 1, label: Text('Şoförler')),
          ],
          selected: {_segment},
          onSelectionChanged: (s) => setState(() => _segment = s.first),
        ),
        SearchInput(onChanged: (v) => setState(() => _search = v), hint: 'İsim ara…'),
        if (_segment == 0)
          for (final p in demoTripPassengers.where((p) => p.passengerName.toLowerCase().contains(_search.toLowerCase())))
            AppCard(
              child: Row(children: [
                UserAvatar(name: p.passengerName, size: 38),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.passengerName, style: AppText.bodyStrong),
                    Text('Durak: ${p.stopName}', style: AppText.tiny),
                  ]),
                ),
              ]),
            )
        else
          for (final (name, vehicle, active) in _drivers.where((d) => d.$1.toLowerCase().contains(_search.toLowerCase())))
            AppCard(
              child: Row(children: [
                UserAvatar(name: name, size: 38),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: AppText.bodyStrong),
                    Text('Araç: $vehicle', style: AppText.tiny),
                  ]),
                ),
                StatusBadge(label: active ? 'Aktif' : 'Pasif', tone: active ? BadgeTone.success : BadgeTone.neutral),
              ]),
            ),
      ],
    );
  }
}

/// Yönetim: araçlar, güzergâh, duyuru ve profil.
class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    final route = ref.watch(routeProvider('route-avrupa-sabah'));
    return AppScaffold(
      title: 'Yönetim',
      children: [
        AppCard(
          onTap: () => context.push('/announcement'),
          child: Row(children: [
            const Text('📣', style: TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text('Duyuru Oluştur', style: AppText.bodyStrong)),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ]),
        ),
        Align(alignment: Alignment.centerLeft, child: Text('ARAÇLAR', style: AppText.label)),
        vehicles.when(
          loading: () => const LoadingState(),
          error: (e, _) => const SizedBox.shrink(),
          data: (list) => Column(children: [
            for (final v in list)
              Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: VehicleCard(vehicle: v)),
          ]),
        ),
        Align(alignment: Alignment.centerLeft, child: Text('GÜZERGÂH', style: AppText.label)),
        route.maybeWhen(
          data: (r) => AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: AppText.h3),
              Text('${r.startLocation} → ${r.endLocation} · ${r.stopCount} durak', style: AppText.caption),
            ]),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        const Divider(color: AppColors.border),
        const ProfilePanel(),
      ],
    );
  }
}
