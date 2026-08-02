import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Yönetici Raporları (Stitch): KPI kartları + filtre + rapor listesi + dağılım.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, backgroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add, color: AppColors.textInverse),
      ),
      body: AppScaffold(
        title: 'Yönetici Raporları',
        subtitle: 'Operasyonel performansı takip edin',
        children: [
          Row(children: [
            Expanded(child: SecondaryButton(label: 'PDF İndir', icon: Icons.picture_as_pdf_outlined, onPressed: () {})),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: PrimaryButton(label: 'Excel Dışa Aktar', icon: Icons.table_chart_outlined, onPressed: () {})),
          ]),
          const SizedBox(height: AppSpacing.xs),
          _kpi('Zamanında Varış', '%94.2', '+2.4% geçen aya göre', AppColors.success,
              Icons.check_circle, true),
          _kpi('Ort. Gecikme Süresi', '12dk', '-4.1% geçen aya göre', AppColors.warning,
              Icons.schedule, false),
          _kpi('Araç Kullanım Oranı', '%81.5', '[KAPASİTE: 240/300]', AppColors.primary,
              Icons.local_shipping_outlined, null),
          const SizedBox(height: AppSpacing.sm),
          _filterCard(),
          const SizedBox(height: AppSpacing.md),
          _reportListCard(),
          const SizedBox(height: AppSpacing.md),
          _distributionCard(),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, String delta, Color accent, IconData icon, bool? positive) {
    final deltaColor = positive == null ? AppColors.textMuted : (positive ? AppColors.success : AppColors.danger);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        accentColor: accent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label.toUpperCase(), style: AppText.monoLabel),
            Icon(icon, size: 20, color: accent),
          ]),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppText.statValue),
          const SizedBox(height: 2),
          Row(children: [
            if (positive != null)
              Icon(positive ? Icons.trending_up : Icons.trending_down, size: 14, color: deltaColor),
            if (positive != null) const SizedBox(width: 2),
            Text(delta, style: AppText.monoTiny.copyWith(color: deltaColor, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  Widget _filterCard() {
    return AppCard(
      color: AppColors.surfaceTile,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.filter_alt_outlined, size: 20, color: AppColors.text),
          const SizedBox(width: AppSpacing.sm),
          Text('Gelişmiş Filtreleme', style: AppText.h3),
        ]),
        const SizedBox(height: AppSpacing.md),
        Text('TARİH ARALIĞI', style: AppText.monoLabel),
        const SizedBox(height: 4),
        _field('gg/aa/yyyy', trailing: const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.md),
        Text('SERVİS TİPİ', style: AppText.monoLabel),
        const SizedBox(height: 4),
        _field('Tüm Servisler', trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.md),
        Text('ARAÇ GRUBU', style: AppText.monoLabel),
        const SizedBox(height: 4),
        _field('Tüm Araçlar', trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'Filtrele', variant: ButtonVariant.primary, onPressed: () {}),
      ]),
    );
  }

  Widget _field(String text, {Widget? trailing}) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Expanded(child: Text(text, style: AppText.body.copyWith(color: AppColors.textMuted))),
          ?trailing,
        ]),
      );

  Widget _reportListCard() {
    const reports = [
      ('Günlük Güzergah Performansı', 'Operasyonel', AppColors.primary, AppColors.infoBg, 'Bugün 09:45'),
      ('Aylık Yakıt Analizi', 'Finansal', AppColors.statusPaused, Color(0xFFEEEAFF), 'Dün 18:20'),
      ('Şoför Performans Karnesi', 'İK / Personel', AppColors.warning, AppColors.warningBg, '12.10.2025'),
      ('Gelmeyen Personel & Aksaklık', 'Kritik', AppColors.danger, AppColors.dangerBg, 'Bugün 07:30'),
      ('Bakım & Onarım Planı', 'Teknik', AppColors.textSecondary, AppColors.surfaceAlt, '11.10.2025'),
    ];
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(children: [
            Expanded(child: Text('Güncel Rapor Listesi', style: AppText.h3)),
            const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            const Icon(Icons.sort, size: 20, color: AppColors.textSecondary),
          ]),
        ),
        for (var i = 0; i < reports.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
              color: i.isEven ? AppColors.surface : AppColors.surfaceTile.withValues(alpha: 0.4),
            ),
            child: Row(children: [
              Expanded(flex: 4, child: Text(reports[i].$1, style: AppText.bodyStrong,
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
              Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft,
                  child: _categoryChip(reports[i].$2, reports[i].$3, reports[i].$4))),
              Expanded(flex: 2, child: Text(reports[i].$5, style: AppText.monoTiny)),
            ]),
          ),
      ]),
    );
  }

  Widget _categoryChip(String label, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label.toUpperCase(), style: AppText.monoTiny.copyWith(color: fg, fontWeight: FontWeight.w700),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      );

  Widget _distributionCard() {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Operasyonel Dağılım', style: AppText.h3),
        const SizedBox(height: AppSpacing.md),
        _progressRow('Aktif Seferler', 0.68, AppColors.primary),
        _progressRow('Depo Stok Verimliliği', 0.42, AppColors.warning),
        _progressRow('Müşteri Memnuniyeti', 0.91, AppColors.success),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.surfaceTile, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SİSTEM NOTU:', style: AppText.monoLabel),
            const SizedBox(height: 4),
            Text(
              '"Geçen haftaya oranla operasyonel gecikmelerde %15 azalma gözlemlendi. '
              'Şoför performans puanları yükseliş trendinde."',
              style: AppText.caption.copyWith(fontStyle: FontStyle.italic),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _progressRow(String label, double value, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: AppText.body),
            Text('%${(value * 100).round()}', style: AppText.bodyStrong),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: value, minHeight: 8,
                  backgroundColor: AppColors.surfaceAlt, color: color)),
        ]),
      );
}
