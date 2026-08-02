import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/statuses.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/demo_data.dart';
import '../../data/models/service_trip.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/simulation_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/live_map.dart';
import '../../widgets/plate_chip.dart';
import '../../widgets/service_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vehicle_card.dart';
import '../shared/profile_panel.dart';

/// Yönetici ana sayfası (Stitch): karşılama + hero servis kartı + sol-vurgu
/// istatistik kartları + hızlı işlemler + servis tablosu.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final trips = ref.watch(tripsProvider);

    return AppScaffold(
      onRefresh: () async => ref.refresh(tripsProvider.future),
      children: [
        DashboardHeader(appName: user?.tenantName ?? 'Servis Takip'),
        const SizedBox(height: AppSpacing.xs),
        Text('Günaydın, ${user?.firstName ?? ''} Bey', style: AppText.display),
        Row(children: [
          Text(user?.tenantName ?? '', style: AppText.monoTiny),
          Text('  •  ${Fmt.date(DateTime.now())}', style: AppText.monoTiny),
        ]),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'Yeni Kayıt', variant: ButtonVariant.primary, icon: Icons.add, onPressed: () {}),
        const SizedBox(height: AppSpacing.md),

        trips.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tripsProvider)),
          data: (list) {
            final onRoad = list.where((t) => t.status == TripStatus.active || t.status == TripStatus.delayed).length;
            final done = list.where((t) => t.status == TripStatus.completed).length;
            final delayed = list.where((t) => t.delayMinutes > 0).length;
            return Column(children: [
              _heroCard(list.length, onRoad, done, delayed),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Expanded(child: StatCard(label: 'Personel', value: '842',
                    accentColor: AppColors.primary, subLabel: '12 İzinli', subTone: StatTone.danger)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: StatCard(label: 'Aktif Filo', value: '56',
                    accentColor: AppColors.primaryDark, subLabel: '48 Online', subTone: StatTone.primary)),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _quickActions(context),
              const SizedBox(height: AppSpacing.lg),
              _tableHeader(),
              const SizedBox(height: AppSpacing.sm),
              _serviceTable(context, list),
            ]);
          },
        ),
      ],
    );
  }

  Widget _heroCard(int total, int onRoad, int done, int delayed) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('BUGÜNKÜ SERVİSLER', style: AppText.monoLabel),
          const Icon(Icons.event_available_outlined, color: AppColors.textMuted, size: 20),
        ]),
        Text('$total', style: AppText.statValue),
        const SizedBox(height: AppSpacing.sm),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          _heroStat('YOLDA', '$onRoad', AppColors.primary),
          _heroStat('TAMAMLANDI', '$done', AppColors.success),
          _heroStat('GECİKEN', '$delayed', AppColors.danger),
        ]),
      ]),
    );
  }

  Widget _heroStat(String label, String value, Color color) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.monoTiny),
          Text(value, style: AppText.h2.copyWith(color: color)),
        ]),
      );

  Widget _quickActions(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Hızlı İşlemler', style: AppText.h3),
      const SizedBox(height: AppSpacing.sm),
      Row(children: [
        Expanded(child: _actionCard(Icons.qr_code_2, 'Yeni Servis', () => context.push('/new-trip'))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _actionCard(Icons.person_add_alt, 'Yeni Personel', () {})),
      ]),
    ]);
  }

  Widget _actionCard(IconData icon, String label, VoidCallback onTap) => AppCard(
        radius: 16,
        onTap: onTap,
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primary, size: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      );

  Widget _tableHeader() => Row(children: [
        Text('Bugünkü Servisler', style: AppText.h3),
        const Spacer(),
        _miniOutlineButton(Icons.filter_list, 'Filtrele', AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        _miniOutlineButton(Icons.download, 'Dışa Aktar', AppColors.text),
      ]);

  Widget _miniOutlineButton(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color == AppColors.primary ? AppColors.primary : AppColors.borderStrong),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label.toUpperCase(), style: AppText.monoTiny.copyWith(color: color, fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _serviceTable(BuildContext context, List<ServiceTrip> trips) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // Başlık satırı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.surfaceTile,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(flex: 4, child: Text('GÜZERGAH / ŞOFÖR', style: AppText.monoLabel)),
            Expanded(flex: 3, child: Text('PLAKA', style: AppText.monoLabel)),
            Expanded(flex: 2, child: Text('SAAT', style: AppText.monoLabel)),
            Expanded(flex: 3, child: Text('DURUM', style: AppText.monoLabel)),
          ]),
        ),
        for (var i = 0; i < trips.length; i++)
          InkWell(
            onTap: () => context.push('/trip/${trips[i].id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                border: i < trips.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: Row(children: [
                Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(trips[i].serviceName, style: AppText.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(trips[i].driverName, style: AppText.monoTiny),
                ])),
                Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft,
                    child: PlateChip(plate: trips[i].vehiclePlate, dense: true))),
                Expanded(flex: 2, child: Text(Fmt.time(trips[i].plannedStartAt), style: AppText.body)),
                Expanded(flex: 3, child: StatusDot.trip(trips[i].status)),
              ]),
            ),
          ),
        // Sayfalama
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('Toplam ${trips.length} aktif sefer', style: AppText.monoTiny)),
            _pageBox('‹', false),
            _pageBox('1', true),
            _pageBox('2', false),
            _pageBox('›', false),
          ]),
        ),
      ]),
    );
  }

  Widget _pageBox(String label, bool active) => Container(
        margin: const EdgeInsets.only(left: 6),
        width: 32, height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primaryDark : AppColors.border),
        ),
        child: Text(label, style: AppText.monoLabel.copyWith(
            color: active ? AppColors.textInverse : AppColors.textSecondary)),
      );
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

/// Personel Yönetimi (Stitch): arama + departman filtresi + personel tablosu.
class AdminPeopleScreen extends StatefulWidget {
  const AdminPeopleScreen({super.key});

  @override
  State<AdminPeopleScreen> createState() => _AdminPeopleScreenState();
}

class _Person {
  const _Person(this.name, this.empNo, this.department, this.color);
  final String name;
  final String empNo;
  final String department;
  final Color color;
}

class _AdminPeopleScreenState extends State<AdminPeopleScreen> {
  String _search = '';
  String _department = 'Tüm Departmanlar';

  static const _people = [
    _Person('Ahmet Yılmaz', 'EMP-2309', 'Operasyon', AppColors.primary),
    _Person('Zeynep Demir', 'EMP-4412', 'Lojistik Planlama', Color(0xFF6B5B2E)),
    _Person('Murat Caner', 'EMP-1102', 'Bilgi İşlem', AppColors.primaryDark),
    _Person('Elif Yıldız', 'EMP-3320', 'Operasyon', AppColors.info),
    _Person('Can Öztürk', 'EMP-5567', 'Lojistik Planlama', Color(0xFF1DAA6D)),
  ];

  List<String> get _departments =>
      ['Tüm Departmanlar', ...{for (final p in _people) p.department}];

  @override
  Widget build(BuildContext context) {
    final filtered = _people.where((p) =>
        (p.name.toLowerCase().contains(_search.toLowerCase()) ||
            p.empNo.toLowerCase().contains(_search.toLowerCase())) &&
        (_department == 'Tüm Departmanlar' || p.department == _department)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_alt, color: AppColors.textInverse),
      ),
      body: AppScaffold(
        title: 'Personel Yönetimi',
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(
              hintText: 'Ad Soyad veya Personel No ara…',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.primaryLight,
            ),
          ),
          _dropdownField(_department, _departments, (v) => setState(() => _department = v)),
          _dropdownField('Bugün Binecekler', const ['Bugün Binecekler', 'Tümü'], (_) {}),
          _peopleTable(filtered),
        ],
      ),
    );
  }

  Widget _dropdownField(String value, List<String> options, ValueChanged<String> onChanged) {
    return Container(
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          borderRadius: BorderRadius.circular(12),
          style: AppText.body,
          items: [for (final o in options) DropdownMenuItem(value: o, child: Text(o, style: AppText.body))],
          onChanged: (v) => onChanged(v ?? value),
        ),
      ),
    );
  }

  Widget _peopleTable(List<_Person> people) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surfaceTile,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(flex: 4, child: Text('AD SOYAD', style: AppText.monoLabel)),
            Expanded(flex: 3, child: Text('PERSONEL NO', style: AppText.monoLabel)),
            Expanded(flex: 3, child: Text('DEPARTMAN', style: AppText.monoLabel)),
          ]),
        ),
        for (var i = 0; i < people.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              border: i < people.length - 1 ? const Border(bottom: BorderSide(color: AppColors.border)) : null,
            ),
            child: Row(children: [
              Expanded(flex: 4, child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: people[i].color,
                    child: Text(_initials(people[i].name),
                        style: AppText.monoTiny.copyWith(color: AppColors.textInverse, fontWeight: FontWeight.w700))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(people[i].name, style: AppText.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis)),
              ])),
              Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft,
                  child: PlateChip(plate: people[i].empNo, dense: true))),
              Expanded(flex: 3, child: Text(people[i].department, style: AppText.body,
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          ),
      ]),
    );
  }

  String _initials(String name) => name.split(' ').where((p) => p.isNotEmpty)
      .take(2).map((p) => p[0].toUpperCase()).join();
}

/// Yönetim / Araçlar (Stitch): filo istatistikleri + araç listesi + güzergâh + profil.
class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    final route = ref.watch(routeProvider('route-avrupa-sabah'));
    return AppScaffold(
      title: 'Yönetim / Araçlar',
      action: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Yeni Kayıt'),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      children: [
        const StatCard(label: 'Toplam Filo', value: '124', subLabel: '+2 Bu Ay', subTone: StatTone.success),
        const StatCard(label: 'Aktif Araçlar', value: '118', accentColor: AppColors.success, hint: '95.2% Kullanım'),
        const StatCard(label: 'Bakım Zamanı', value: '4', accentColor: AppColors.warning, hint: 'Bu hafta planlı'),
        const StatCard(label: 'Pasif / Tamir', value: '2', accentColor: AppColors.danger, hint: 'Ort. duruş 4.2 gün'),
        const SizedBox(height: AppSpacing.xs),

        Align(alignment: Alignment.centerLeft, child: Text('KAYITLI ARAÇLAR', style: AppText.monoLabel)),
        vehicles.when(
          loading: () => const LoadingState(),
          error: (e, _) => const SizedBox.shrink(),
          data: (list) => Column(children: [
            for (final v in list)
              Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: VehicleCard(vehicle: v)),
          ]),
        ),
        Align(alignment: Alignment.centerLeft, child: Text('GÜZERGÂH', style: AppText.monoLabel)),
        route.maybeWhen(
          data: (r) => AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: AppText.h3),
              Text('${r.startLocation} → ${r.endLocation} · ${r.stopCount} durak', style: AppText.caption),
            ]),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        AppCard(
          onTap: () => context.push('/announcement'),
          child: Row(children: [
            const Icon(Icons.campaign_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text('Duyuru Oluştur', style: AppText.bodyStrong)),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ]),
        ),
        AppCard(
          onTap: () => context.push('/reports'),
          child: Row(children: [
            const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text('Raporlar', style: AppText.bodyStrong)),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ]),
        ),
        const Divider(color: AppColors.border),
        const ProfilePanel(),
      ],
    );
  }
}
