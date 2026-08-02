import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Türkçe tarih/saat biçimlendirmesi için yerel verileri yükle.
  await initializeDateFormatting('tr_TR', null);
  runApp(const ProviderScope(child: ServisTakipApp()));
}
