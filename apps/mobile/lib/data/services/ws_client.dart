import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/env.dart';
import '../../core/constants/ws_channels.dart';

enum WsStatus { connecting, open, closed, reconnecting }

class WsMessage {
  const WsMessage({required this.event, required this.channel, required this.payload});
  final String event;
  final String channel;
  final Map<String, dynamic> payload;

  factory WsMessage.fromJson(Map<String, dynamic> json) => WsMessage(
        event: json['event'] as String? ?? '',
        channel: json['channel'] as String? ?? '',
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
}

/// WebSocket istemci soyutlaması.
/// - Kanal + token ile bağlanır (yetkilendirme backend'de yapılır).
/// - Bağlantı koparsa exponential backoff ile yeniden bağlanır.
/// - Mock modda gerçek soket açılmaz; simülasyon devreye girer.
class WsClient {
  WsClient({required this.channel, required this.token});

  final String channel;
  final String token;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  int _attempts = 0;
  bool _closedByUser = false;
  Timer? _reconnectTimer;

  final _messages = StreamController<WsMessage>.broadcast();
  final _statuses = StreamController<WsStatus>.broadcast();

  Stream<WsMessage> get messages => _messages.stream;
  Stream<WsStatus> get statuses => _statuses.stream;

  void connect() {
    if (Env.useMock) {
      // Mock modda gerçek soket açılmaz; simülasyon motoru veri sağlar.
      _statuses.add(WsStatus.open);
      return;
    }
    _closedByUser = false;
    _open();
  }

  void _open() {
    _statuses.add(_attempts == 0 ? WsStatus.connecting : WsStatus.reconnecting);
    final uri = Uri.parse(
      '${Env.wsBaseUrl}/ws?channel=${Uri.encodeQueryComponent(channel)}&token=${Uri.encodeQueryComponent(token)}',
    );
    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (_) {
      _scheduleReconnect();
      return;
    }
    _statuses.add(WsStatus.open);
    _attempts = 0;
    _sub = _channel!.stream.listen(
      (data) {
        try {
          _messages.add(WsMessage.fromJson(jsonDecode(data as String) as Map<String, dynamic>));
        } catch (_) {
          // bozuk mesajı yok say
        }
      },
      onDone: () {
        _statuses.add(WsStatus.closed);
        if (!_closedByUser) _scheduleReconnect();
      },
      onError: (_) {
        if (!_closedByUser) _scheduleReconnect();
      },
    );
  }

  void _scheduleReconnect() {
    if (_closedByUser || _attempts >= RealtimeConfig.reconnectMaxAttempts) return;
    final base = RealtimeConfig.reconnectBaseDelay.inMilliseconds;
    final delayMs = (base * _powInt(RealtimeConfig.reconnectFactor, _attempts))
        .clamp(base, RealtimeConfig.reconnectMaxDelay.inMilliseconds);
    _attempts++;
    _statuses.add(WsStatus.reconnecting);
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), _open);
  }

  int _powInt(int base, int exp) {
    var result = 1;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  Future<void> close() async {
    _closedByUser = true;
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close();
    await _messages.close();
    await _statuses.close();
  }
}
