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
import '../../widgets/buttons.dart';

/// Tek giriş ekranı — Stitch tasarımına göre. Başarılı girişte router yönlendirir.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

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
      /* Hata auth state üzerinden gösterilir. */
    }
  }

  void _fillDemo(String email) {
    _email.text = email;
    _password.text = demoPassword;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppCard(
                    radius: 24,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo + başlık
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_bus_rounded, color: AppColors.primary, size: 30),
                              const SizedBox(width: AppSpacing.sm),
                              Text(S.appName, style: AppText.h1),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text('Hoş Geldiniz', style: AppText.h1),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Lütfen hesabınıza giriş yapın.', style: AppText.caption),
                          const SizedBox(height: AppSpacing.xl),

                          // E-posta
                          Text('E-POSTA VEYA TELEFON', style: AppText.monoLabel),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              hintText: 'Ad Soyad veya 05xx…',
                              prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
                              if (!v.contains('@')) return 'Geçerli bir e-posta girin';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Şifre + unuttum
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ŞİFRE', style: AppText.monoLabel),
                              GestureDetector(
                                onTap: () => context.push('/forgot-password'),
                                child: Text('ŞİFREMİ UNUTTUM?',
                                    style: AppText.monoLabel.copyWith(color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Beni hatırla
                          Row(
                            children: [
                              SizedBox(
                                width: 24, height: 24,
                                child: Checkbox(
                                  value: _remember,
                                  onChanged: (v) => setState(() => _remember = v ?? false),
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text('Beni hatırla', style: AppText.caption.copyWith(color: AppColors.primary)),
                            ],
                          ),

                          if (auth.error != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(auth.error!, style: AppText.caption.copyWith(color: AppColors.danger)),
                          ],
                          const SizedBox(height: AppSpacing.lg),

                          PrimaryButton(
                            label: 'Giriş Yap',
                            icon: Icons.login_rounded,
                            loading: auth.loading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Yardıma mı ihtiyacınız var?', style: AppText.caption),
                              Text('Destek Ekibi',
                                  style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _secureBadge(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _demoAccounts(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secureBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text('[GÜVENLİ BAĞLANTI AKTİF]',
              style: AppText.monoTiny.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _demoAccounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DEMO HESAPLARI · ŞİFRE: $demoPassword', style: AppText.monoTiny),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final acc in demoAccounts)
              SizedBox(
                width: 200,
                child: AppCard(
                  radius: 12,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onTap: () => _fillDemo(acc.user.email),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(acc.user.role.label, style: AppText.bodyStrong.copyWith(color: AppColors.primary)),
                      Text(acc.user.email, style: AppText.monoTiny),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
