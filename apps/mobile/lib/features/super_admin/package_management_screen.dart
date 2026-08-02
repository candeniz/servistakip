import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';
import '../../widgets/mini_stat_card.dart';

class _Feature {
  const _Feature(this.label, this.included);
  final String label;
  final bool included;
}

class _Package {
  const _Package(this.name, this.customers, this.description, this.price, this.features,
      {this.highlighted = false, this.popular = false});
  final String name;
  final String customers;
  final String description;
  final String price;
  final List<_Feature> features;
  final bool highlighted;
  final bool popular;
}

/// Paket Yönetimi (Stitch): paket istatistikleri + fiyatlandırma kartları.
class PackageManagementScreen extends StatelessWidget {
  const PackageManagementScreen({super.key});

  static const _packages = [
    _Package('Starter', '84 Müşteri', 'Küçük ölçekli yerel dağıtım operasyonları için ideal başlangıç seviyesi.',
        '₺450', [
      _Feature('2 Kullanıcı Limiti', true),
      _Feature('5 Araç Takibi', true),
      _Feature('Standart Raporlama', true),
      _Feature('Canlı Takip Paneli', false),
    ]),
    _Package('Professional', '942 Müşteri', 'Büyüyen lojistik firmaları için gelişmiş takip ve analiz araçları.',
        '₺1.200', [
      _Feature('10 Kullanıcı Limiti', true),
      _Feature('25 Araç Takibi', true),
      _Feature('Detaylı Raporlama', true),
      _Feature('Canlı Takip Paneli (Gecikmesiz)', true),
    ], highlighted: true, popular: true),
    _Package('Enterprise', '222 Müşteri', 'Global operasyonlar için limitsiz kapasite ve özel entegrasyon çözümleri.',
        '₺3.500', [
      _Feature('Sınırsız Kullanıcı', true),
      _Feature('Sınırsız Araç Takibi', true),
      _Feature('Özel API Erişimi', true),
      _Feature('7/24 Öncelikli Destek', true),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Paket Yönetimi',
      action: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Yeni Paket'),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primaryDark, foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      children: [
        Row(children: [
          const Expanded(child: MiniStatCard(label: 'Toplam Paket', value: '3')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: MiniStatCard(label: 'Aktif Abonelik', value: '1.248',
              accent: const Icon(Icons.people_outline, size: 18, color: AppColors.primary))),
        ]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: MiniStatCard(label: 'Aylık Gelir (MRR)', value: '₺142K',
              accent: Text('▲', style: AppText.monoTiny.copyWith(color: AppColors.warning)))),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: MiniStatCard(label: 'Popüler Paket', value: 'Pro')),
        ]),
        const SizedBox(height: AppSpacing.sm),
        for (final p in _packages) _packageCard(p),
      ],
    );
  }

  Widget _packageCard(_Package p) {
    final dark = p.highlighted;
    final textColor = dark ? AppColors.textInverse : AppColors.text;
    final mutedColor = dark ? AppColors.borderStrong : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        color: dark ? AppColors.primaryDark : AppColors.surface,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(p.name, style: AppText.h2.copyWith(color: textColor))),
            if (p.popular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                child: Text('EN POPÜLER', style: AppText.monoTiny.copyWith(color: AppColors.textInverse, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: dark ? AppColors.primary : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(999)),
              child: Text(p.customers, style: AppText.monoTiny.copyWith(
                  color: dark ? AppColors.textInverse : AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(p.description, style: AppText.caption.copyWith(color: mutedColor)),
          const SizedBox(height: AppSpacing.md),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(p.price, style: AppText.statValue.copyWith(fontSize: 32, color: textColor)),
            Text(' /aylık', style: AppText.caption.copyWith(color: mutedColor)),
          ]),
          const SizedBox(height: AppSpacing.md),
          for (final f in p.features) Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(children: [
              Icon(f.included ? Icons.check_circle : Icons.cancel_outlined, size: 18,
                  color: f.included ? (dark ? AppColors.primaryBright : AppColors.success) : AppColors.outline),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(f.label, style: AppText.body.copyWith(
                  color: f.included ? textColor : mutedColor))),
            ]),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (dark)
            PrimaryButton(label: 'Düzenle', variant: ButtonVariant.primary, onPressed: () {})
          else
            SecondaryButton(label: 'Düzenle', onPressed: () {}),
        ]),
      ),
    );
  }
}
