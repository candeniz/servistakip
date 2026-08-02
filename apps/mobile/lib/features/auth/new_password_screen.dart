import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Yeni Şifre Oluşturma (Stitch): şifre + tekrar + kural kontrolleri.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _hasLength => _pass.text.length >= 8;
  bool get _hasNumber => _pass.text.contains(RegExp(r'\d'));
  bool get _hasUpper => _pass.text.contains(RegExp(r'[A-ZÇĞİÖŞÜ]'));
  bool get _matches => _pass.text.isNotEmpty && _pass.text == _confirm.text;
  bool get _valid => _hasLength && _hasNumber && _hasUpper && _matches;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Yeni Şifre Oluştur',
      subtitle: 'Hesabınız için güçlü bir şifre belirleyin',
      children: [
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('YENİ ŞİFRE', style: AppText.monoLabel),
          const SizedBox(height: 4),
          TextField(
            controller: _pass, obscureText: _obscure,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('ŞİFRE TEKRAR', style: AppText.monoLabel),
          const SizedBox(height: 4),
          TextField(
            controller: _confirm, obscureText: _obscure,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _rule('En az 8 karakter', _hasLength),
          _rule('En az bir rakam', _hasNumber),
          _rule('En az bir büyük harf', _hasUpper),
          _rule('Şifreler eşleşiyor', _matches),
        ])),
        PrimaryButton(
          label: 'Şifreyi Güncelle', icon: Icons.check,
          onPressed: _valid ? () => context.go('/login') : null,
        ),
      ],
    );
  }

  Widget _rule(String text, bool ok) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16, color: ok ? AppColors.success : AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppText.caption.copyWith(color: ok ? AppColors.success : AppColors.textSecondary)),
        ]),
      );
}
