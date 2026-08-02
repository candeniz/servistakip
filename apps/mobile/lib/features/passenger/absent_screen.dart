import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Servise Binmeyeceğim (Stitch): devamsızlık türü seçimi + not + gönder.
class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  int _selected = 0;
  bool _sent = false;

  static const _options = [
    (Icons.wb_sunny_outlined, 'Bugün Sabah', 'Sadece sabah servisi', AppColors.warning),
    (Icons.nightlight_outlined, 'Bugün Akşam', 'Sadece akşam servisi', AppColors.primary),
    (Icons.do_not_disturb_on_outlined, 'Hiçbirine', 'Tüm gün binmeyeceğim', AppColors.danger),
    (Icons.calendar_month_outlined, 'Tarih Aralığı', 'Birden fazla gün seç', AppColors.statusPaused),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Servise Binmeyeceğim',
      subtitle: 'Bildiriminiz anlık olarak şoföre iletilecektir',
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.35,
          children: [
            for (var i = 0; i < _options.length; i++) _optionCard(i),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(alignment: Alignment.centerLeft, child: Row(children: [
          Text('AÇIKLAMA (NOT)', style: AppText.monoLabel),
          const SizedBox(width: 6),
          Text('OPSİYONEL', style: AppText.monoTiny),
        ])),
        const SizedBox(height: 4),
        TextField(maxLines: 3, decoration: const InputDecoration(hintText: 'Şoföre iletmek istediğiniz kısa bir not…')),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10),
            border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(
              'Bildiriminiz onaylandığında şoförün paneline [CANLI BİLGİ] olarak düşecektir. '
              'Güzergah planlaması buna göre güncellenir.',
              style: AppText.caption.copyWith(color: AppColors.primaryDark),
            )),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: _sent ? 'Gönderildi ✓' : 'Bildirimi Gönder',
          icon: _sent ? Icons.check : Icons.send,
          onPressed: _sent ? null : () {
            setState(() => _sent = true);
            Future.delayed(const Duration(milliseconds: 700), () {
              if (context.mounted) context.pop();
            });
          },
        ),
      ],
    );
  }

  Widget _optionCard(int i) {
    final (icon, title, subtitle, color) = _options[i];
    final active = _selected == i;
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        color: active ? AppColors.primaryLight : AppColors.surface,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(title, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}
