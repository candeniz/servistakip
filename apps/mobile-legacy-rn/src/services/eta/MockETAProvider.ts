import type { EtaResult } from '@servis/shared';
import { haversineMeters } from '@/lib/geo';
import type { ETAProvider, EtaInput } from './types';

/**
 * Harici API'ye bağımlı olmayan basit ETA hesaplayıcı.
 * Kalan mesafeyi durak zinciri üzerinden toplar, ortalama hız ve
 * durak duruş sürelerini ekleyerek tahmini varış süresini üretir.
 */
export class MockETAProvider implements ETAProvider {
  readonly name = 'mock';

  async calculate(input: EtaInput): Promise<EtaResult> {
    const {
      vehicleLocation,
      nextStopIndex,
      targetStopIndex,
      stops,
      averageSpeedKmh,
      dwellSecondsPerStop,
      plannedArrivalAt,
    } = input;

    const now = input.now ? new Date(input.now) : new Date();
    const clampedTarget = Math.min(Math.max(targetStopIndex, nextStopIndex), stops.length - 1);

    // 1) Kalan mesafe: araç -> sıradaki durak -> ... -> hedef durak
    let distance = 0;
    if (nextStopIndex <= clampedTarget) {
      distance += haversineMeters(vehicleLocation, stops[nextStopIndex]!);
      for (let i = nextStopIndex; i < clampedTarget; i++) {
        distance += haversineMeters(stops[i]!, stops[i + 1]!);
      }
    }

    const remainingStops = Math.max(0, clampedTarget - nextStopIndex + 1);

    // 2) Sürüş süresi (saniye) = mesafe / hız
    const speedMs = Math.max(1, (averageSpeedKmh * 1000) / 3600);
    const driveSeconds = distance / speedMs;

    // 3) Ara duraklardaki duruş süreleri (hedef durak hariç)
    const dwellSeconds = Math.max(0, remainingStops - 1) * dwellSecondsPerStop;

    const etaSeconds = driveSeconds + dwellSeconds;
    const etaMinutes = Math.max(0, Math.round(etaSeconds / 60));

    // 4) Varış tahmini ve gecikme
    const estimatedArrival = new Date(now.getTime() + etaSeconds * 1000);
    const planned = new Date(plannedArrivalAt);
    const delayMinutes = Math.max(
      0,
      Math.round((estimatedArrival.getTime() - planned.getTime()) / 60000),
    );

    return {
      remaining_stops: remainingStops,
      remaining_distance_meters: Math.round(distance),
      eta_minutes: etaMinutes,
      planned_arrival_at: planned.toISOString(),
      estimated_arrival_at: estimatedArrival.toISOString(),
      delay_minutes: delayMinutes,
    };
  }
}
