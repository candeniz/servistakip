import { create } from 'zustand';
import type { LatLng, TripPassenger, BoardingStatus } from '@servis/shared';
import { SimulationEngine, type SimulationTick } from '@/services/simulation/SimulationEngine';
import {
  demoSimulationPath,
  demoStops,
  demoTrip,
  demoTripPassengers,
  PASSENGER_STOP_INDEX,
} from '@/mocks/demoData';

interface SimulationState {
  running: boolean;
  location: LatLng | null;
  heading: number;
  speedKmh: number;
  nextStopIndex: number;
  atStopIndex: number | null;
  finished: boolean;
  passengers: TripPassenger[];
  /** Simülasyonu başlatır (şoför "Servisi Başlat" veya yolcu ekranı açılışı). */
  start: () => void;
  stop: () => void;
  reset: () => void;
  setPassengerStatus: (tripPassengerId: string, status: BoardingStatus) => void;
}

// Tekil motor örneği (demo trip için paylaşılır).
let engine: SimulationEngine | null = null;
let unsubscribe: (() => void) | null = null;

function ensureEngine(apply: (tick: SimulationTick) => void): SimulationEngine {
  if (!engine) {
    engine = new SimulationEngine({
      path: demoSimulationPath,
      stops: demoStops,
      intervalMs: 2000,
      speedKmh: 34,
      startIndex: 0,
    });
  }
  if (!unsubscribe) {
    unsubscribe = engine.subscribe(apply);
  }
  return engine;
}

export const useSimulationStore = create<SimulationState>((set, get) => ({
  running: false,
  location: null,
  heading: 0,
  speedKmh: 0,
  nextStopIndex: demoStops.findIndex((s) => s.id === demoTrip.next_stop_id) || 1,
  atStopIndex: null,
  finished: false,
  passengers: demoTripPassengers,

  start: () => {
    const eng = ensureEngine((tick) => {
      set((state) => ({
        location: tick.location,
        heading: tick.heading,
        speedKmh: tick.speedKmh,
        nextStopIndex: tick.nextStopIndex,
        atStopIndex: tick.atStopIndex,
        finished: tick.finished,
        // Araç bir durağı geçtiyse o duraktaki bekleyen yolcuları "bindi" yap.
        passengers: autoBoard(state.passengers, tick.nextStopIndex),
      }));
    });
    eng.start();
    set({ running: true });
  },

  stop: () => {
    engine?.stop();
    set({ running: false });
  },

  reset: () => {
    engine?.stop();
    unsubscribe?.();
    unsubscribe = null;
    engine = null;
    set({
      running: false,
      location: null,
      heading: 0,
      speedKmh: 0,
      nextStopIndex: 1,
      atStopIndex: null,
      finished: false,
      passengers: demoTripPassengers,
    });
  },

  setPassengerStatus: (tripPassengerId, status) => {
    set({
      passengers: get().passengers.map((p) =>
        p.id === tripPassengerId
          ? { ...p, boarding_status: status, boarded_at: status === 'boarded' ? new Date().toISOString() : p.boarded_at }
          : p,
      ),
    });
  },
}));

/** Araç geçtiği duraklardaki "expected" yolcuları otomatik olarak bindirir. */
function autoBoard(passengers: TripPassenger[], nextStopIndex: number): TripPassenger[] {
  const stopIndexById = new Map(demoStops.map((s, i) => [s.id, i]));
  return passengers.map((p) => {
    const idx = stopIndexById.get(p.stop_id) ?? 0;
    if (idx < nextStopIndex && p.boarding_status === 'expected') {
      return { ...p, boarding_status: 'boarded', boarded_at: new Date().toISOString() };
    }
    return p;
  });
}

export { PASSENGER_STOP_INDEX };
