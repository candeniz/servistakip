import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/stat_card.dart';

/// Kullanıcı Yönetimi (Stitch): kullanıcı istatistikleri + kullanıcı listesi +
/// rol & yetki matrisi.
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  static const _users = [
    ('Ayşe Yılmaz', 'ayse.yilmaz@logistix.com', 'Yönetici', _RoleStyle.outline),
    ('Mehmet Demir', 'm.demir@logistix.com', 'Şoför', _RoleStyle.neutral),
    ('Caner Soylu', 'caner.soylu@logistix.com', 'Operasyon', _RoleStyle.filled),
  ];

  static const _modules = [
    (Icons.explore_outlined, 'Live Tracking', [true, true, false]),
    (Icons.badge_outlined, 'Staff Management', [true, true, false]),
    (Icons.local_shipping_outlined, 'Vehicle Fleet', [true, false, false]),
    (Icons.bar_chart_outlined, 'Business Reports', [true, true, true]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, backgroundColor: AppColors.primaryDark,
        child: const Icon(Icons.person_add_alt, color: AppColors.textInverse),
      ),
      body: AppScaffold(
        title: 'Kullanıcı Yönetimi',
        action: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add_alt, size: 16),
          label: const Text('Ekle'),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primaryDark, foregroundColor: AppColors.textInverse,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        children: [
          const StatCard(label: 'Toplam Kullanıcı', value: '124', subLabel: '+8', subTone: StatTone.success),
          const StatCard(label: 'Aktif Operasyon', value: '42', tone: StatTone.primary),
          const StatCard(label: 'Saha Personeli', value: '76'),
          const StatCard(label: 'Pasif Hesaplar', value: '6', tone: StatTone.danger, accentColor: AppColors.danger),
          const SizedBox(height: AppSpacing.sm),
          _userListCard(),
          const SizedBox(height: AppSpacing.md),
          _matrixHeader(),
          const SizedBox(height: AppSpacing.sm),
          _matrixCard(),
        ],
      ),
    );
  }

  Widget _userListCard() {
    return AppCard(
      color: AppColors.surfaceTile,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SizedBox(width: 90, child: Text('Alt Kullanıcı Listesi', style: AppText.bodyStrong)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: SizedBox(height: 42, child: TextField(
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara…', isDense: true,
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              fillColor: AppColors.surface, filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ))),
        ]),
        const SizedBox(height: AppSpacing.md),
        for (final (name, email, role, style) in _users)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppColors.primaryLight,
                  child: Text(name.substring(0, 1), style: AppText.bodyStrong.copyWith(color: AppColors.primary))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: AppText.bodyStrong),
                Text(email, style: AppText.monoTiny),
              ])),
              _roleChip(role, style),
            ]),
          ),
      ]),
    );
  }

  Widget _roleChip(String label, _RoleStyle style) {
    final (bg, fg, border) = switch (style) {
      _RoleStyle.outline => (AppColors.surface, AppColors.primary, AppColors.primary),
      _RoleStyle.neutral => (AppColors.surfaceAlt, AppColors.textSecondary, AppColors.surfaceAlt),
      _RoleStyle.filled => (AppColors.primary, AppColors.textInverse, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: border)),
      child: Text(label.toUpperCase(), style: AppText.monoTiny.copyWith(color: fg, fontWeight: FontWeight.w700)),
    );
  }

  Widget _matrixHeader() => Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rol ve Yetki Matrisi', style: AppText.h3),
          Text('Modül erişim ve işlem yetkilerini yönetin.', style: AppText.caption),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderStrong)),
          child: Text('YENİ ROL', style: AppText.monoTiny.copyWith(fontWeight: FontWeight.w700)),
        ),
      ]);

  Widget _matrixCard() {
    const cols = ['GÖRÜNTÜLE', 'DÜZENLE', 'SİL'];
    return AppCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(children: [
          // Dark header
          Container(
            color: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(children: [
              SizedBox(width: 160, child: Text('MODÜL İSMİ',
                  style: AppText.monoLabel.copyWith(color: AppColors.textInverse))),
              for (final c in cols)
                SizedBox(width: 90, child: Text(c, textAlign: TextAlign.center,
                    style: AppText.monoLabel.copyWith(color: AppColors.textInverse))),
            ]),
          ),
          for (var i = 0; i < _modules.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: i.isEven ? AppColors.surfaceTile.withValues(alpha: 0.5) : AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(children: [
                SizedBox(width: 160, child: Row(children: [
                  Icon(_modules[i].$1, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(_modules[i].$2, style: AppText.bodyStrong,
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ])),
                for (final granted in _modules[i].$3)
                  SizedBox(width: 90, child: Icon(
                    granted ? Icons.check_circle : Icons.remove_circle_outline,
                    color: granted ? AppColors.success : AppColors.outline, size: 20)),
              ]),
            ),
        ]),
      ),
    );
  }
}

enum _RoleStyle { outline, neutral, filled }
