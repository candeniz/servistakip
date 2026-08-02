import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Karşılama ekranı (Stitch): tanıtım + giriş / şirket kodu seçenekleri.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: S.appName,
      action: const Icon(Icons.help_outline, color: AppColors.textSecondary),
      children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('CANLI OPERASYON PANELİ', style: AppText.monoLabel.copyWith(color: AppColors.primary)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(TextSpan(style: AppText.display.copyWith(fontSize: 34, height: 1.15), children: const [
          TextSpan(text: 'Kurumsal Ulaşımda '),
          TextSpan(text: 'Şeffaf', style: TextStyle(color: AppColors.primary)),
          TextSpan(text: ' Takip Dönemi'),
        ])),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Personel ve okul servisleri için geliştirilmiş, gerçek zamanlı konum takibi ve '
          'gelişmiş güvenlik protokolleri ile operasyonel mükemmelliği yakalayın.',
          style: AppText.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        _featureCard(Icons.my_location, 'Canlı Takip',
            'Aracın konumunu saniye saniye harita üzerinden izleyin, varış sürelerini anlık kontrol edin.'),
        _featureCard(Icons.verified_user_outlined, 'Güvenli Ulaşım',
            'Onaylı sürücü kimlikleri ve hız sınırı kontrolleri ile personelinizi ve öğrencilerinizi güvenceye alın.'),
        const SizedBox(height: AppSpacing.sm),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hoş Geldiniz', style: AppText.h2),
          Text('Devam etmek için aşağıdaki seçeneklerden birini belirleyin.', style: AppText.caption),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Giriş Yap', icon: Icons.login_rounded, onPressed: () => context.push('/login')),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            const Expanded(child: Divider()),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('VEYA', style: AppText.monoTiny)),
            const Expanded(child: Divider()),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text('KURUM KAYDI', style: AppText.monoLabel),
          const SizedBox(height: 4),
          SecondaryButton(label: 'Şirket Kodu Gir', icon: Icons.apartment, onPressed: () => context.push('/company-code')),
          const SizedBox(height: AppSpacing.md),
          Center(child: GestureDetector(
            onTap: () => context.push('/kvkk'),
            child: Text.rich(TextSpan(style: AppText.caption, children: [
              const TextSpan(text: 'Bir hesabınız yok mu? '),
              TextSpan(text: 'Kaydolun', style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
            ])),
          )),
        ])),
        const SizedBox(height: AppSpacing.md),
        Center(child: Text('© 2024 SERVİS TAKİBİ TEKNOLOJİLERİ A.Ş.', style: AppText.monoTiny)),
      ],
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) => AppCard(
        color: AppColors.primaryLight,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppText.h3),
          const SizedBox(height: 4),
          Text(desc, style: AppText.caption),
        ]),
      );
}
