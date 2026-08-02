import { useEffect, useState } from 'react';
import type { EtaResult, LatLng, Stop } from '@servis/shared';
import { etaProvider } from '@/services/eta';

interface UseEtaParams {
  vehicleLocation: LatLng | null;
  stops: Stop[];
  nextStopIndex: number;
  targetStopIndex: number;
  plannedArrivalAt: string;
  averageSpeedKmh?: number;
  dwellSecondsPerStop?: number;
}

/**
 * Aktif ETA sağlayıcısını kullanarak hedef durak için ETA hesaplar.
 * Araç konumu her değiştiğinde yeniden hesaplanır.
 */
export function useEta({
  vehicleLocation,
  stops,
  nextStopIndex,
  targetStopIndex,
  plannedArrivalAt,
  averageSpeedKmh = 32,
  dwellSecondsPerStop = 45,
}: UseEtaParams): EtaResult | null {
  const [eta, setEta] = useState<EtaResult | null>(null);

  useEffect(() => {
    let cancelled = false;
    if (!vehicleLocation) return;

    void etaProvider
      .calculate({
        vehicleLocation,
        stops,
        nextStopIndex,
        targetStopIndex,
        averageSpeedKmh,
        dwellSecondsPerStop,
        plannedArrivalAt,
      })
      .then((result) => {
        if (!cancelled) setEta(result);
      })
      .catch(() => {
        // ETA hesaplanamazsa mevcut değeri koru
      });

    return () => {
      cancelled = true;
    };
  }, [vehicleLocation, stops, nextStopIndex, targetStopIndex, plannedArrivalAt, averageSpeedKmh, dwellSecondsPerStop]);

  return eta;
}
