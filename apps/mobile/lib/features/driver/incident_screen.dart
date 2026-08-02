import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/statuses.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Şoför olay bildirimi (gecikme, trafik, arıza, kaza).
class IncidentScreen extends StatefulWidget {
  const IncidentScreen({super.key});

  @override
  State<IncidentScreen> createState() => _IncidentScreenState();
}

class _IncidentScreenState extends State<IncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  IncidentType _type = IncidentType.delay;
  bool _sent = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sent = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Olay Bildir',
      subtitle: 'Yöneticiye anlık iletilir',
      children: [
        Align(alignment: Alignment.centerLeft, child: Text('OLAY TÜRÜ', style: AppText.label)),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final t in IncidentType.values)
              GestureDetector(
                onTap: () => setState(() => _type = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _type == t ? AppColors.primary : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(t.label,
                      style: AppText.bodyStrong.copyWith(
                          color: _type == t ? AppColors.textInverse : AppColors.textSecondary)),
                ),
              ),
          ],
        ),
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Kısa açıklama girin…',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 5) ? 'En az 5 karakter' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: _sent ? 'Bildirildi ✓' : 'Olayı Bildir', onPressed: _sent ? null : _submit),
            ]),
          ),
        ),
      ],
    );
  }
}
