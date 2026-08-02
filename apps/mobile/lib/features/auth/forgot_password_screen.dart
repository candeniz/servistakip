import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Şifremi unuttum — doğrulama kodu ekranına yönlendirir (mock akış).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Şifremi Unuttum',
      subtitle: 'E-postanıza doğrulama kodu gönderilir',
      children: [
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'E-posta', hintText: 'ornek@sirket.com'),
        ),
        PrimaryButton(
          label: _sent ? 'Kod gönderildi ✓' : 'Kod Gönder',
          onPressed: _sent
              ? null
              : () {
                  setState(() => _sent = true);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) context.push('/verify-code');
                  });
                },
        ),
        Text(
          'Demo modunda gerçek e-posta gönderilmez; sonraki ekranda herhangi 6 haneli kodu girebilirsiniz.',
          style: AppText.tiny,
        ),
      ],
    );
  }
}
