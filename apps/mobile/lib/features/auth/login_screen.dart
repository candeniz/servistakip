import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/demo_users.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Tek giriş ekranı — başarılı girişte router role göre yönlendirir.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
    } catch (_) {
      // Hata auth state üzerinden gösterilir.
    }
  }

  void _fillDemo(String email) {
    _email.text = email;
    _password.text = demoPassword;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AppScaffold(
      children: [
        const SizedBox(height: AppSpacing.xl),
        Column(
          children: [
            const Text('🚐', style: TextStyle(fontSize: 48)),
            Text(S.appName, style: AppText.display),
            Text(S.tagline, style: AppText.caption, textAlign: TextAlign.center),
          ],
        ),
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(S.login, style: AppText.h2),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: S.email, hintText: 'ornek@sirket.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
                    if (!v.contains('@')) return 'Geçerli bir e-posta girin';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: S.password, hintText: '••••••••'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(auth.error!, style: AppText.caption.copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(label: S.login, loading: auth.loading, onPressed: _submit),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text(S.forgotPassword),
                ),
              ],
            ),
          ),
        ),
        _demoAccounts(),
      ],
    );
  }

  Widget _demoAccounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.demoHint, style: AppText.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final acc in demoAccounts)
              SizedBox(
                width: 160,
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onTap: () => _fillDemo(acc.user.email),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(acc.user.role.label, style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
                      Text(acc.user.email, style: AppText.tiny),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Tüm demo hesapların şifresi: $demoPassword', style: AppText.tiny),
      ],
    );
  }
}
