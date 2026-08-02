/// Ortam yapılandırması.
///
/// Değerler `--dart-define` ile derleme zamanında geçilebilir:
///   flutter run --dart-define=USE_MOCK=false --dart-define=API_URL=http://10.0.2.2:8000
class Env {
  const Env._();

  /// true ise ağ katmanı yerine mock servisler kullanılır (backend olmadan çalışır).
  static const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  /// Backend REST taban adresi.
  static const String apiBaseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000');

  /// Backend WebSocket taban adresi.
  static const String wsBaseUrl =
      String.fromEnvironment('WS_URL', defaultValue: 'ws://localhost:8000');
}
