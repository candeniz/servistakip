import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/roles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/core_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/buttons.dart';

/// Excel/CSV ile toplu personel yükleme (Stitch dili): dosya seç → önizle → yükle.
class ImportPersonnelScreen extends ConsumerStatefulWidget {
  const ImportPersonnelScreen({super.key});

  @override
  ConsumerState<ImportPersonnelScreen> createState() => _ImportPersonnelScreenState();
}

class _ImportPersonnelScreenState extends ConsumerState<ImportPersonnelScreen> {
  String? _fileName;
  List<Map<String, dynamic>> _rows = [];
  String? _parseError;
  bool _uploading = false;
  Map<String, dynamic>? _result;

  Future<void> _pickFile() async {
    setState(() {
      _parseError = null;
      _result = null;
    });
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _parseError = 'Dosya okunamadı.');
      return;
    }
    try {
      final rows = file.extension?.toLowerCase() == 'csv'
          ? _parseCsv(utf8.decode(bytes, allowMalformed: true))
          : _parseXlsx(bytes);
      setState(() {
        _fileName = file.name;
        _rows = rows;
        if (rows.isEmpty) _parseError = 'Geçerli satır bulunamadı. Başlık satırı ve en az bir kayıt olmalı.';
      });
    } catch (e) {
      setState(() => _parseError = 'Ayrıştırma hatası: $e');
    }
  }

  // ── Ayrıştırma ──
  List<Map<String, dynamic>> _parseXlsx(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.isEmpty ? null : excel.tables.values.first;
    if (sheet == null || sheet.rows.isEmpty) return [];
    final headers = sheet.rows.first.map((c) => _cell(c?.value)).toList();
    final out = <Map<String, dynamic>>[];
    for (var r = 1; r < sheet.rows.length; r++) {
      final cells = sheet.rows[r];
      String at(int i) => (i >= 0 && i < cells.length) ? _cell(cells[i]?.value) : '';
      final row = _mapRow(headers, at);
      if (row != null) out.add(row);
    }
    return out;
  }

  List<Map<String, dynamic>> _parseCsv(String content) {
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return [];
    final sep = lines.first.contains(';') ? ';' : ',';
    final headers = lines.first.split(sep).map((h) => h.trim().toLowerCase()).toList();
    final out = <Map<String, dynamic>>[];
    for (var i = 1; i < lines.length; i++) {
      final cells = lines[i].split(sep);
      String at(int idx) => (idx >= 0 && idx < cells.length) ? cells[idx].trim() : '';
      final row = _mapRow(headers, at);
      if (row != null) out.add(row);
    }
    return out;
  }

  String _cell(CellValue? v) => v == null ? '' : v.toString().trim();

  /// Başlıkları alanlara eşler ve bir satır sözlüğü üretir (e-posta zorunlu).
  Map<String, dynamic>? _mapRow(List<String> headers, String Function(int) at) {
    int idx(bool Function(String) test) => headers.indexWhere((h) => test(h.toLowerCase().trim()));
    final iFirst = idx((h) => h.startsWith('ad') || h.contains('first'));
    final iLast = idx((h) => h.contains('soyad') || h.contains('last'));
    final iEmail = idx((h) => h.contains('posta') || h.contains('mail'));
    final iPhone = idx((h) => h.contains('tel') || h.contains('phone'));
    final iRole = idx((h) => h.contains('rol'));
    final iEmp = idx((h) => h.contains('personel') || h.contains('emp') || h == 'no');
    final iDept = idx((h) => h.contains('depart') || h.contains('birim'));

    final email = at(iEmail);
    final first = at(iFirst);
    if (email.isEmpty || !email.contains('@')) return null; // e-posta yoksa satırı atla
    return {
      'first_name': first.isEmpty ? '-' : first,
      'last_name': at(iLast),
      'email': email,
      if (at(iPhone).isNotEmpty) 'phone': at(iPhone),
      'role': _mapRole(at(iRole)),
      if (at(iEmp).isNotEmpty) 'employee_number': at(iEmp),
      if (at(iDept).isNotEmpty) 'department': at(iDept),
    };
  }

  String _mapRole(String raw) {
    final r = raw.toLowerCase().trim();
    if (r.contains('şof') || r.contains('sof') || r == 'driver') return Role.driver.value;
    if (r.contains('operasyon') || r.contains('operations')) return Role.operationsManager.value;
    if (r.contains('yönet') || r.contains('yonet') || r.contains('admin')) return Role.companyAdmin.value;
    return Role.passenger.value; // varsayılan: yolcu (personel)
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    try {
      final result = await ref.read(dataServiceProvider).importUsers(_rows);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _parseError = 'Yükleme hatası: $e');
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Excel ile Toplu Personel',
      subtitle: 'Ad, Soyad, E-posta, Telefon, Rol, Personel No, Departman',
      children: [
        AppCard(
          color: AppColors.surfaceTile,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const Icon(Icons.upload_file, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(_fileName ?? 'Henüz dosya seçilmedi (.xlsx / .csv)',
                  style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(label: 'Dosya Seç', icon: Icons.folder_open, onPressed: _pickFile),
          ]),
        ),
        if (_parseError != null)
          Text(_parseError!, style: AppText.caption.copyWith(color: AppColors.danger)),
        if (_rows.isNotEmpty && _result == null) ...[
          Align(alignment: Alignment.centerLeft,
              child: Text('ÖNİZLEME · ${_rows.length} SATIR', style: AppText.monoLabel)),
          _previewTable(),
          PrimaryButton(
            label: _uploading ? 'Yükleniyor…' : '${_rows.length} Personeli Yükle',
            icon: Icons.cloud_upload_outlined,
            loading: _uploading,
            onPressed: _upload,
          ),
        ],
        if (_result != null) _resultCard(),
      ],
    );
  }

  Widget _previewTable() {
    final preview = _rows.take(8).toList();
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: const BoxDecoration(color: AppColors.surfaceTile,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Row(children: [
            Expanded(flex: 4, child: Text('AD SOYAD', style: AppText.monoLabel)),
            Expanded(flex: 5, child: Text('E-POSTA', style: AppText.monoLabel)),
            Expanded(flex: 3, child: Text('ROL', style: AppText.monoLabel)),
          ]),
        ),
        for (var i = 0; i < preview.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(border: i < preview.length - 1
                ? const Border(bottom: BorderSide(color: AppColors.border)) : null),
            child: Row(children: [
              Expanded(flex: 4, child: Text('${preview[i]['first_name']} ${preview[i]['last_name']}',
                  style: AppText.body, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Expanded(flex: 5, child: Text('${preview[i]['email']}',
                  style: AppText.monoTiny, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Expanded(flex: 3, child: Text(Role.fromValue('${preview[i]['role']}').label, style: AppText.monoTiny)),
            ]),
          ),
        if (_rows.length > preview.length)
          Padding(padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text('… ve ${_rows.length - preview.length} satır daha', style: AppText.monoTiny)),
      ]),
    );
  }

  Widget _resultCard() {
    final created = _result!['created'] ?? 0;
    final skipped = _result!['skipped'] ?? 0;
    final errors = (_result!['errors'] as List?)?.cast<String>() ?? [];
    return AppCard(
      accentColor: AppColors.success,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Text('Yükleme tamamlandı', style: AppText.h3),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text('Eklenen: $created  ·  Atlanan (kayıtlı): $skipped  ·  Hatalı: ${errors.length}',
            style: AppText.bodyStrong),
        if (errors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          for (final e in errors.take(10))
            Text('• $e', style: AppText.caption.copyWith(color: AppColors.danger)),
        ],
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(label: 'Yeni Dosya', icon: Icons.refresh, onPressed: () {
          setState(() { _rows = []; _fileName = null; _result = null; });
        }),
      ]),
    );
  }
}
