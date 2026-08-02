import { useEffect, useRef } from 'react';
import { useSimulationStore, PASSENGER_STOP_INDEX } from '@/stores/simulationStore';
import { useEta } from './useEta';
import { demoStops, demoTrip, demoPassengerSnapshot } from '@/mocks/demoData';

/**
 * Yolcu canlı servis verisini bir araya getirir:
 * simülasyon konumu + aktif ETA sağlayıcı ile hedef durak ETA'sı.
 * Demo modunda ekran açılışında simülasyon otomatik başlar.
 */
export function useLiveTrip(targetStopIndex: number = PASSENGER_STOP_INDEX) {
  const { location, heading, nextStopIndex, running, start, finished } = useSimulationStore();

  // Planlanan varışı ekran açılışına göre sabitle; böylece senaryoya uygun
  // (~3 dk) bir gecikme çıkar ve araç ilerledikçe gecikme azalır.
  const plannedArrivalAtRef = useRef<string>(
    new Date(Date.now() + (demoPassengerSnapshot.etaMinutes - demoPassengerSnapshot.delayMinutes) * 60000).toISOString(),
  );

  useEffect(() => {
    if (!running && !finished) start();
  }, [running, finished, start]);

  const eta = useEta({
    vehicleLocation: location,
    stops: demoStops,
    nextStopIndex,
    targetStopIndex,
    plannedArrivalAt: plannedArrivalAtRef.current,
  });

  const nextStop = demoStops[nextStopIndex] ?? null;
  const targetStop = demoStops[targetStopIndex] ?? null;

  return { location, heading, eta, nextStop, targetStop, nextStopIndex, running, finished, trip: demoTrip };
}
