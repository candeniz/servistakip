import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Duyuru oluşturma + push bildirim (mock).
class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
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
      title: 'Duyuru Oluştur',
      subtitle: 'Tüm personele bildirim gönderilir',
      children: [
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Başlık', hintText: 'Servis saati değişikliği'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'En az 3 karakter' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _content,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'İçerik',
                  hintText: 'Yarınki sabah servisi 15 dk erken kalkacaktır.',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 5) ? 'En az 5 karakter' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: _sent ? 'Gönderildi ✓' : 'Duyuru Gönder', onPressed: _sent ? null : _submit),
              const SizedBox(height: AppSpacing.sm),
              Text('Demo modunda gerçek push bildirimi gönderilmez.', style: AppText.tiny),
            ]),
          ),
        ),
      ],
    );
  }
}
