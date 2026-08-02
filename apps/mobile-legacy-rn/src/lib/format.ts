/** Türkçe biçimlendirme yardımcıları. */

/** ISO tarihi HH:mm biçiminde döndürür. */
export function formatTime(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
}

/** ISO tarihi gün.ay.yıl biçiminde döndürür. */
export function formatDate(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return d.toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

/** Metreyi okunabilir mesafeye çevirir (m / km). */
export function formatDistance(meters: number): string {
  if (meters < 1000) return `${Math.round(meters)} m`;
  return `${(meters / 1000).toFixed(1)} km`;
}

/** Dakikayı "12 dk" biçiminde döndürür. */
export function formatMinutes(minutes: number): string {
  return `${Math.max(0, Math.round(minutes))} dk`;
}

/** "az önce / 5 dk önce / 2 sa önce" göreli zaman. */
export function formatRelative(iso: string): string {
  const diffMs = Date.now() - new Date(iso).getTime();
  const min = Math.floor(diffMs / 60000);
  if (min < 1) return 'az önce';
  if (min < 60) return `${min} dk önce`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr} sa önce`;
  return `${Math.floor(hr / 24)} gün önce`;
}
