import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/status_badge.dart';

/// Haftalık Servis Takvimi (Stitch): gün seçici + sabah/akşam servis blokları.
class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  int _day = 0;
  static const _days = [
    ('PZT', '22'), ('SAL', '23'), ('ÇAR', '24'), ('PER', '25'), ('CUM', '26'), ('CMT', '27'), ('PAZ', '28'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Haftalık Servis Takvimi',
      subtitle: '22 - 28 Mayıs 2024 Arası Operasyonel Plan',
      children: [
        Row(children: [
          Expanded(child: _dropdown('Tüm Bölgeler')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _dropdown('Tüm Tipler')),
        ]),
        _daySelector(),
        const SizedBox(height: AppSpacing.sm),
        _sectionHeader('☀', 'Sabah Servisleri (06:00 - 09:30)'),
        _serviceCard('34 SK 2024', 'Teknopark - Levent Hattı', 'Ahmet Yılmaz', '07:15 Kalkış',
            const StatusBadge(label: 'Aktif', tone: BadgeTone.success), capacity: 'Kapasite: 18/22'),
        _conflictCard(),
        _serviceCard('34 AA 999', 'Maslak - Beşiktaş Hattı', 'Caner Korkmaz', '08:00 Kalkış',
            const StatusBadge(label: 'Beklemede', tone: BadgeTone.warning)),
        _sectionHeader('🌙', 'Akşam Servisleri (16:30 - 19:30)'),
        _cancelledCard(),
        _serviceCard('06 ANC 06', 'Plaza - Metro Bağlantısı', 'Selim Ak', '17:45 Kalkış',
            const StatusBadge(label: 'Aktif', tone: BadgeTone.success), passengers: true),
        _addBlockCard(),
        _liveStrip(),
      ],
    );
  }

  Widget _dropdown(String value) => Container(
        height: 50, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Expanded(child: Text(value, style: AppText.body)),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
        ]),
      );

  Widget _daySelector() => SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _days.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final active = i == _day;
            return GestureDetector(
              onTap: () => setState(() => _day = i),
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_days[i].$1, style: AppText.monoTiny.copyWith(
                      color: active ? AppColors.textInverse : AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(_days[i].$2, style: AppText.h2.copyWith(
                      color: active ? AppColors.textInverse : AppColors.text)),
                ]),
              ),
            );
          },
        ),
      );

  Widget _sectionHeader(String icon, String title) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(title, style: AppText.h3)),
        ]),
      );

  Widget _serviceCard(String plate, String name, String driver, String time, Widget badge,
      {String? capacity, bool passengers = false}) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('[PLAKA: $plate]', style: AppText.monoTiny.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))),
          badge,
        ]),
        const SizedBox(height: 2),
        Text(name, style: AppText.bodyStrong),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          const Icon(Icons.person_outline, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(driver, style: AppText.caption),
          const Spacer(),
          const Icon(Icons.schedule, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(time, style: AppText.caption),
        ]),
        if (capacity != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(capacity, style: AppText.monoTiny.copyWith(fontStyle: FontStyle.italic)),
        ],
        if (passengers) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            for (var i = 0; i < 3; i++) Align(widthFactor: 0.7,
                child: CircleAvatar(radius: 11, backgroundColor: [AppColors.primary, AppColors.success, AppColors.warning][i],
                    child: const Text(''))),
            const SizedBox(width: 10),
            Text('+12  Yolcu Listesi Onaylı', style: AppText.monoTiny),
          ]),
        ],
      ]),
    );
  }

  Widget _conflictCard() => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.danger, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.danger),
            const SizedBox(width: 6),
            Expanded(child: Text('Kadıköy - Pendik Ekspres', style: AppText.bodyStrong.copyWith(color: AppColors.danger))),
            const StatusBadge(label: 'Çakışma', tone: BadgeTone.danger),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Çakışma: Şoför Mehmet Can farklı görevde', style: AppText.bodyStrong.copyWith(color: AppColors.dangerStrong)),
              Text('Aynı saatte "Ümraniye Servisi" atanmış.', style: AppText.caption),
            ]),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: SizedBox(height: 44, child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Şoför Değiştir', style: AppText.monoStrong.copyWith(color: AppColors.textInverse, fontSize: 13)),
            ))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: SizedBox(height: 44, child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(backgroundColor: AppColors.surfaceAlt,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('İncele', style: AppText.monoStrong.copyWith(color: AppColors.textSecondary, fontSize: 13)),
            ))),
          ]),
        ]),
      );

  Widget _cancelledCard() => AppCard(
        color: AppColors.surfaceAlt,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('[İPTAL EDİLDİ]', style: AppText.monoTiny.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w700))),
            const StatusBadge(label: 'İptal', tone: BadgeTone.neutral),
          ]),
          const SizedBox(height: 2),
          Text('Etiler - Şişli Ring', style: AppText.bodyStrong.copyWith(
              color: AppColors.textMuted, decoration: TextDecoration.lineThrough)),
          const SizedBox(height: AppSpacing.sm),
          Text('Gerekçe: Personel sayısındaki yetersizlik (22 Mayıs)', style: AppText.caption.copyWith(fontStyle: FontStyle.italic)),
        ]),
      );

  Widget _addBlockCard() => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderStrong, style: BorderStyle.solid, width: 1.5),
        ),
        child: Column(children: [
          const Icon(Icons.add_circle_outline, size: 28, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text('Yeni Akşam Bloğu Ekle', style: AppText.bodyStrong),
          Text('Henüz planlanmamış bir servis var mı?', style: AppText.caption),
        ]),
      );

  Widget _liveStrip() => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('Canlı Takip: 12 araç aktif yolda', style: AppText.bodyStrong)),
          Text('MAP GÖRÜNÜMÜNE GEÇ', style: AppText.monoTiny.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
        ]),
      );
}
