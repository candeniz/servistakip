import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Şirket Kodu Seçimi (Stitch): kurumsal portal girişi.
class CompanyCodeScreen extends StatefulWidget {
  const CompanyCodeScreen({super.key});

  @override
  State<CompanyCodeScreen> createState() => _CompanyCodeScreenState();
}

class _CompanyCodeScreenState extends State<CompanyCodeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(child: Column(children: [
          Text(S.appName, style: AppText.h1),
          Text('KURUMSAL PORTAL', style: AppText.monoLabel.copyWith(color: AppColors.primary)),
        ])),
        const SizedBox(height: AppSpacing.xl),
        Text('Kurumunuzu Tanımlayın', style: AppText.display.copyWith(fontSize: 30)),
        const SizedBox(height: AppSpacing.xs),
        Text('Devam etmek için size atanan şirket kodunu girin veya listeden seçin.',
            style: AppText.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Şirket Kodu')),
            ButtonSegment(value: 1, label: Text('Kurum Listesi')),
          ],
          selected: {_tab},
          onSelectionChanged: (s) => setState(() => _tab = s.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_tab == 0) ...[
          Text('ŞİRKET KODU', style: AppText.monoLabel),
          const SizedBox(height: 4),
          const TextField(decoration: InputDecoration(
            hintText: 'ÖRN: LOGI-2024',
            prefixIcon: Icon(Icons.apartment, color: AppColors.textMuted),
          )),
          const SizedBox(height: AppSpacing.sm),
          Text('Kodu bilmiyorsanız yöneticinizle iletişime geçin.', style: AppText.caption),
        ] else ...[
          for (final c in const ['Atlas Teknoloji · ATLAS01', 'Nova Lojistik · NOVA02', 'Global Rota · GLO-2150'])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.business, color: AppColors.primary),
              title: Text(c.split(' · ').first, style: AppText.bodyStrong),
              subtitle: Text(c.split(' · ').last, style: AppText.monoTiny),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () => context.push('/login'),
            ),
        ],
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(label: 'Devam Et', icon: Icons.arrow_forward, onPressed: () => context.push('/login')),
        const SizedBox(height: AppSpacing.md),
        Center(child: Text.rich(TextSpan(style: AppText.caption, children: [
          const TextSpan(text: 'Yardıma mı ihtiyacınız var? '),
          TextSpan(text: 'Destek Merkezi', style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
        ]))),
        const SizedBox(height: AppSpacing.lg),
        Center(child: Text('v2.4.0-PRO  •  GDPR UYUMLU', style: AppText.monoTiny)),
      ],
    );
  }
}
