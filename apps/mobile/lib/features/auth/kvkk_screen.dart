import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Yasal Onaylar (Stitch): Kullanım Koşulları + KVKK + onay kutuları.
class KvkkScreen extends StatefulWidget {
  const KvkkScreen({super.key});

  @override
  State<KvkkScreen> createState() => _KvkkScreenState();
}

class _KvkkScreenState extends State<KvkkScreen> {
  bool _terms = false;
  bool _kvkk = false;
  bool _marketing = false;

  bool get _canContinue => _terms && _kvkk;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Yasal Onaylar',
      subtitle: 'Devam etmek için metinleri inceleyip onaylayın',
      children: [
        _docCard(Icons.description_outlined, 'Kullanım Koşulları', AppColors.primary, const [
          ('1. Taraflar', 'İşbu Kullanım Koşulları, Servis Takibi platformu ile kullanıcı arasındaki ilişkileri düzenler. Uygulamaya erişim sağlayarak bu şartları kabul etmiş sayılırsınız.'),
          ('2. Hizmet Tanımı', 'Servis Takibi, lojistik operasyonların gerçek zamanlı izlenmesi, raporlanması ve yönetilmesi için sunulan bir B2B yazılım hizmetidir.'),
        ]),
        _kvkkCard(),
        _consentCard(context),
      ],
    );
  }

  Widget _docCard(IconData icon, String title, Color accent, List<(String, String)> sections) => AppCard(
        accentColor: accent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: accent, size: 20), const SizedBox(width: AppSpacing.sm), Text(title, style: AppText.h3)]),
          const SizedBox(height: AppSpacing.md),
          for (final (h, body) in sections) ...[
            Text(h, style: AppText.bodyStrong),
            const SizedBox(height: 4),
            Text(body, style: AppText.caption),
            const SizedBox(height: AppSpacing.sm),
          ],
        ]),
      );

  Widget _kvkkCard() => AppCard(
        accentColor: AppColors.warning,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.privacy_tip_outlined, color: AppColors.warning, size: 20),
            const SizedBox(width: AppSpacing.sm), Text('KVKK Aydınlatma Metni', style: AppText.h3),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text('6698 sayılı Kişisel Verilerin Korunması Kanunu uyarınca, verilerinizin işlenme amaçları ve haklarınız aşağıda belirtilmiştir.', style: AppText.caption),
          const SizedBox(height: AppSpacing.sm),
          Text('Veri İşleme Amaçları', style: AppText.bodyStrong),
          const SizedBox(height: 4),
          for (final b in const [
            'Kimlik doğrulama ve operasyonel takip.',
            'Sürüş güvenliği ve rota optimizasyonu.',
            'Hizmet kalitesinin artırılmasına yönelik analizler.',
          ]) Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: AppText.caption), Expanded(child: Text(b, style: AppText.caption)),
          ])),
        ]),
      );

  Widget _consentCard(BuildContext context) => AppCard(
        color: AppColors.primaryLight,
        child: Column(children: [
          _check('Kullanım Koşulları', 'nı okudum, anladım ve kabul ediyorum.', _terms, (v) => setState(() => _terms = v)),
          _check('KVKK Aydınlatma Metni', ' kapsamında verilerimin işlenmesine onay veriyorum.', _kvkk, (v) => setState(() => _kvkk = v)),
          _check('', 'Bilgilendirme ve kampanya iletileri almayı kabul ediyorum. (Opsiyonel)', _marketing, (v) => setState(() => _marketing = v)),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Devam Et', icon: Icons.arrow_forward, onPressed: _canContinue ? () => context.pop() : null),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(label: 'İptal Et ve Çıkış Yap', onPressed: () => context.pop()),
          const SizedBox(height: AppSpacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('GÜVENLİ ONAY SİSTEMİ', style: AppText.monoTiny.copyWith(color: AppColors.primary)),
          ]),
        ]),
      );

  Widget _check(String bold, String rest, bool value, ValueChanged<bool> onChanged) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 24, height: 24, child: Checkbox(value: value, onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(TextSpan(style: AppText.caption, children: [
                if (bold.isNotEmpty) TextSpan(text: bold, style: AppText.bodyStrong),
                TextSpan(text: rest),
              ])))),
        ],
      );
}
