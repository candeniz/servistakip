import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih/saat biçimlendirmesi için yerel verileri yükle.
  await initializeDateFormatting('tr_TR', null);

  // Firebase çekirdeği (FCM için). Yapılandırma sorunlarında uygulamayı bloklama.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase başlatılamadı: $e');
  }

  runApp(const ProviderScope(child: ServisTakipApp()));
}
