import { WS_RECONNECT, type WsEvent } from '@servis/shared';
import { env } from '@/config/env';

export interface WsMessage<T = unknown> {
  event: WsEvent;
  channel: string;
  payload: T;
}

export type WsStatus = 'connecting' | 'open' | 'closed' | 'reconnecting';

interface WsClientOptions {
  channel: string;
  token: string;
  onMessage: (msg: WsMessage) => void;
  onStatus?: (status: WsStatus) => void;
}

/**
 * WebSocket istemci soyutlaması.
 * - Kanal ve token ile bağlanır (yetkilendirme backend'de yapılır).
 * - Bağlantı koparsa exponential backoff ile yeniden bağlanır.
 * - Gerçek WS yoksa (mock mod) sessizce pasif kalır; simülasyon devreye girer.
 */
export class WsClient {
  private ws: WebSocket | null = null;
  private attempts = 0;
  private closedByUser = false;
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;

  constructor(private readonly opts: WsClientOptions) {}

  connect(): void {
    if (env.useMock) {
      // Mock modda gerçek soket açılmaz; simülasyon motoru veri sağlar.
      this.opts.onStatus?.('open');
      return;
    }
    this.closedByUser = false;
    this.open();
  }

  private open(): void {
    this.opts.onStatus?.(this.attempts === 0 ? 'connecting' : 'reconnecting');
    const url = `${env.wsBaseUrl}/ws?channel=${encodeURIComponent(this.opts.channel)}&token=${encodeURIComponent(this.opts.token)}`;
    try {
      this.ws = new WebSocket(url);
    } catch {
      this.scheduleReconnect();
      return;
    }

    this.ws.onopen = () => {
      this.attempts = 0;
      this.opts.onStatus?.('open');
    };
    this.ws.onmessage = (e) => {
      try {
        const msg = JSON.parse(String(e.data)) as WsMessage;
        this.opts.onMessage(msg);
      } catch {
        // Bozuk mesajı yok say
      }
    };
    this.ws.onclose = () => {
      this.opts.onStatus?.('closed');
      if (!this.closedByUser) this.scheduleReconnect();
    };
    this.ws.onerror = () => {
      this.ws?.close();
    };
  }

  private scheduleReconnect(): void {
    if (this.closedByUser || this.attempts >= WS_RECONNECT.MAX_ATTEMPTS) return;
    const delay = Math.min(
      WS_RECONNECT.MAX_DELAY_MS,
      WS_RECONNECT.BASE_DELAY_MS * WS_RECONNECT.FACTOR ** this.attempts,
    );
    this.attempts += 1;
    this.opts.onStatus?.('reconnecting');
    this.reconnectTimer = setTimeout(() => this.open(), delay);
  }

  send(message: WsMessage): void {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    }
  }

  close(): void {
    this.closedByUser = true;
    if (this.reconnectTimer) clearTimeout(this.reconnectTimer);
    this.ws?.close();
    this.ws = null;
  }
}
