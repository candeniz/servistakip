import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/plate_chip.dart';
import '../../widgets/status_badge.dart';

class _RouteItem {
  const _RouteItem(this.name, this.active, this.origin, this.destination, this.stops,
      this.distance, this.duration, this.vehicles, this.plate);
  final String name;
  final bool active;
  final String origin;
  final String destination;
  final String stops;
  final String distance;
  final String duration;
  final String vehicles;
  final String plate;
}

/// Güzergâh Listesi (Stitch): arama + durum filtresi + zengin güzergâh kartları.
class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  String _search = '';

  static const _routes = [
    _RouteItem('Kadıköy - Maslak', true, 'Rıhtım İETT Durakları', 'Maslak Plaza Hub',
        '12 Durak', '24.5 km', '45 dk', '8 Araç', '34 SK 2024'),
    _RouteItem('Beşiktaş - Ümraniye', true, 'Beşiktaş İskele', 'Ümraniye Sanayi Sitesi',
        '18 Durak', '15.2 km', '35 dk', '12 Araç', '34 TR 0505'),
    _RouteItem('Beylikdüzü - Mecidiyeköy', false, 'Beylikdüzü Son Durak', 'Mecidiyeköy Meydan',
        '25 Durak', '42.0 km', '75 dk', '0 Araç', 'REVİZYON GEREKLİ'),
    _RouteItem('Ataşehir - Kartal', true, 'Batı Ataşehir Konutları', 'Kartal Sahil Lojistik',
        '9 Durak', '18.1 km', '28 dk', '5 Araç', '34 FLT 88'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _routes.where((r) => r.name.toLowerCase().contains(_search.toLowerCase())).toList();
    return AppScaffold(
      title: 'Güzergâh Listesi',
      subtitle: 'Tanımlanmış servis hatlarını yönetin',
      children: [
        PrimaryButton(label: 'Yeni Güzergâh', variant: ButtonVariant.primary, icon: Icons.add_road,
            onPressed: () => context.push('/route-builder')),
        AppCard(
          color: AppColors.surfaceTile,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('GÜZERGÂH ARA', style: AppText.monoLabel),
            const SizedBox(height: 4),
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Güzergâh adı veya nokta yazın…',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                fillColor: AppColors.surface,
              ),
            ),
          ]),
        ),
        for (final r in filtered) _routeCard(r),
      ],
    );
  }

  Widget _routeCard(_RouteItem r) {
    return AppCard(
      accentColor: r.active ? null : AppColors.warning,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(r.name, style: AppText.h3)),
          const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
        ]),
        const SizedBox(height: AppSpacing.xs),
        StatusBadge(label: r.active ? 'Aktif' : 'Pasif', tone: r.active ? BadgeTone.success : BadgeTone.neutral),
        const SizedBox(height: AppSpacing.md),
        _point(Icons.radio_button_checked, r.origin),
        const SizedBox(height: 4),
        _point(Icons.location_on, r.destination),
        const Divider(height: AppSpacing.xl),
        Row(children: [
          _stat('DURAKLAR', r.stops),
          _stat('MESAFE', r.distance),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          _stat('SÜRE', r.duration),
          _stat('SERVİS SAYISI', r.vehicles),
        ]),
        const Divider(height: AppSpacing.xl),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (r.active) PlateChip(plate: '[${r.plate}]', dense: true)
          else Text('[${r.plate}]', style: AppText.monoTiny.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(r.active ? 'DETAYLAR' : 'ETKİNLEŞTİR',
                style: AppText.monoTiny.copyWith(
                    color: r.active ? AppColors.primary : AppColors.warning, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Icon(r.active ? Icons.arrow_forward : Icons.add_circle_outline,
                size: 14, color: r.active ? AppColors.primary : AppColors.warning),
          ]),
        ]),
      ]),
    );
  }

  Widget _point(IconData icon, String text) => Row(children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppText.body)),
      ]);

  Widget _stat(String label, String value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.monoLabel),
          Text(value, style: AppText.bodyStrong),
        ]),
      );
}
