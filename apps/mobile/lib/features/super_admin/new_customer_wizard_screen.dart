import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Yeni Müşteri Oluşturma Sihirbazı (Stitch): çok adımlı form.
class NewCustomerWizardScreen extends StatefulWidget {
  const NewCustomerWizardScreen({super.key});

  @override
  State<NewCustomerWizardScreen> createState() => _NewCustomerWizardScreenState();
}

class _NewCustomerWizardScreenState extends State<NewCustomerWizardScreen> {
  int _step = 0;
  static const _steps = ['Firma Bilgileri', 'Yönetici', 'Limitler', 'Paket & Onay'];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Yeni Müşteri Sihirbazı',
      subtitle: 'Yeni bir lojistik firması tanımlayın',
      children: [
        _stepIndicator(),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_cardTitle(), style: AppText.h3),
            const Divider(height: AppSpacing.xl),
            ..._stepFields(),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              TextButton(onPressed: () => context.pop(),
                  child: Text('Vazgeç', style: AppText.bodyStrong.copyWith(color: AppColors.textSecondary))),
              const Spacer(),
              SizedBox(width: 170, child: PrimaryButton(
                label: _step == _steps.length - 1 ? 'Oluştur' : 'Sonraki Adım',
                icon: _step == _steps.length - 1 ? Icons.check : Icons.arrow_forward,
                onPressed: _next,
              )),
            ]),
          ]),
        ),
      ],
    );
  }

  String _cardTitle() => switch (_step) {
        0 => 'Kurumsal Bilgiler',
        1 => 'Yönetici Hesabı',
        2 => 'Kullanım Limitleri',
        _ => 'Paket Seçimi & Onay',
      };

  Widget _stepIndicator() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < _steps.length; i++) ...[
            Column(children: [
              Container(
                width: 44, height: 44, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == _step ? AppColors.primary : (i < _step ? AppColors.success : AppColors.primaryLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: i < _step
                    ? const Icon(Icons.check, color: AppColors.textInverse, size: 20)
                    : Text('${i + 1}', style: AppText.bodyStrong.copyWith(
                        color: i == _step ? AppColors.textInverse : AppColors.primary)),
              ),
              const SizedBox(height: 4),
              Text(_steps[i], style: AppText.monoTiny.copyWith(
                  color: i == _step ? AppColors.primary : AppColors.textMuted,
                  fontWeight: i == _step ? FontWeight.w700 : FontWeight.w500)),
            ]),
            if (i < _steps.length - 1) const SizedBox(width: AppSpacing.xl),
          ],
        ]),
      );

  List<Widget> _stepFields() => switch (_step) {
        0 => [
            _field('FİRMA TAM ADI (ÜNVAN)', 'Örn: LojiSaas Taşımacılık A.Ş.'),
            _field('VERGİ NUMARASI / MERSİS', '1234567890'),
            _dropdown('SEKTÖR', 'Uluslararası Nakliye'),
            _field('ŞEHİR / ÜLKE', 'İstanbul / Türkiye'),
            _field('ADRES', 'Açık adres bilgilerini buraya giriniz…', lines: 3),
          ],
        1 => [
            _field('YÖNETİCİ AD SOYAD', 'Örn: Ahmet Yılmaz'),
            _field('E-POSTA', 'yonetici@firma.com'),
            _field('TELEFON', '+90 5xx xxx xx xx'),
            _field('GEÇİCİ ŞİFRE', '••••••••'),
          ],
        2 => [
            _field('KULLANICI LİMİTİ', '50'),
            _field('ARAÇ LİMİTİ', '20'),
            _field('AYLIK API ÇAĞRI LİMİTİ', '100000'),
          ],
        _ => [
            _dropdown('PAKET', 'Professional (₺1.200/aylık)'),
            _dropdown('FATURA PERİYODU', 'Aylık'),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Tüm bilgiler hazır. Oluştur ile müşteriyi ekleyin.',
                    style: AppText.caption.copyWith(color: AppColors.success))),
              ]),
            ),
          ],
      };

  Widget _field(String label, String hint, {int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.monoLabel),
          const SizedBox(height: 4),
          TextField(maxLines: lines, decoration: InputDecoration(hintText: hint)),
        ]),
      );

  Widget _dropdown(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.monoLabel),
          const SizedBox(height: 4),
          Container(
            height: 52, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Expanded(child: Text(value, style: AppText.body)),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
            ]),
          ),
        ]),
      );
}
