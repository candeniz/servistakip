import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Servis tanımı oluşturma formu (mock: yerel olarak onaylar).
class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _startTime = TextEditingController(text: '06:30');
  final _plate = TextEditingController();
  final _driver = TextEditingController();
  bool _created = false;

  @override
  void dispose() {
    _name.dispose();
    _startTime.dispose();
    _plate.dispose();
    _driver.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _created = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Yeni Servis',
      subtitle: 'Servis tanımı oluştur',
      children: [
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _field(_name, 'Servis Adı', 'Avrupa Yakası Sabah Servisi',
                  (v) => (v == null || v.trim().length < 3) ? 'En az 3 karakter' : null),
              const SizedBox(height: AppSpacing.md),
              _field(_startTime, 'Kalkış Saati', '06:30',
                  (v) => (v == null || !RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(v)) ? 'SS:DD biçiminde' : null),
              const SizedBox(height: AppSpacing.md),
              _field(_plate, 'Araç Plakası', '34 ST 2026',
                  (v) => (v == null || v.trim().length < 4) ? 'Plaka gerekli' : null),
              const SizedBox(height: AppSpacing.md),
              _field(_driver, 'Şoför', 'Mehmet Yılmaz',
                  (v) => (v == null || v.trim().length < 2) ? 'Şoför gerekli' : null),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: _created ? 'Oluşturuldu ✓' : 'Servisi Oluştur', onPressed: _created ? null : _submit),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Demo modunda servis yerel olarak oluşturulur; backend bağlandığında POST /service-definitions çağrılır.',
                style: AppText.tiny,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, String hint, String? Function(String?) validator) =>
      TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
      );
}
