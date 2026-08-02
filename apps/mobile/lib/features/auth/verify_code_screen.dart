import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Doğrulama kodu girişi (mock akış → giriş ekranına döner).
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Doğrulama Kodu',
      subtitle: 'E-postanıza gelen 6 haneli kodu girin',
      children: [
        TextField(
          controller: _code,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: 'Kod', hintText: '000000', errorText: _error),
        ),
        PrimaryButton(
          label: 'Doğrula',
          onPressed: () {
            if (_code.text.length != 6) {
              setState(() => _error = 'Kod 6 haneli olmalı');
              return;
            }
            context.go('/login');
          },
        ),
        Text('Demo modunda herhangi 6 haneli kod kabul edilir.', style: AppText.tiny),
      ],
    );
  }
}
