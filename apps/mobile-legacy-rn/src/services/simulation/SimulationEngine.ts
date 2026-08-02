import type { LatLng, Stop } from '@servis/shared';
import { bearingDeg, haversineMeters, isWithinRadius } from '@/lib/geo';

export interface SimulationTick {
  /** Aracın güncel konumu. */
  location: LatLng;
  /** Yön (derece). */
  heading: number;
  /** Anlık hız (km/s). */
  speedKmh: number;
  /** Sıradaki durağın index'i. */
  nextStopIndex: number;
  /** Araç şu an bir durağın yarıçapı içinde mi? */
  atStopIndex: number | null;
  /** Yol tamamlandı mı? */
  finished: boolean;
}

export type SimulationListener = (tick: SimulationTick) => void;

interface SimulationOptions {
  path: LatLng[];
  stops: Stop[];
  /** Kaç ms'de bir adım ilerlesin. */
  intervalMs?: number;
  /** Ortalama hız (görsel amaçlı). */
  speedKmh?: number;
  /** Başlangıç path index'i. */
  startIndex?: number;
}

/**
 * Backend olmadan aracın harita üzerinde hareketini simüle eder.
 * Konumu günceller, geçilen durakları tespit eder ve dinleyicilere yayınlar.
 * WebSocket geldiğinde bu motor gerçek konum akışıyla değiştirilir.
 */
export class SimulationEngine {
  private readonly path: LatLng[];
  private readonly stops: Stop[];
  private readonly intervalMs: number;
  private readonly baseSpeedKmh: number;
  private index: number;
  private timer: ReturnType<typeof setInterval> | null = null;
  private listeners = new Set<SimulationListener>();

  constructor(opts: SimulationOptions) {
    this.path = opts.path;
    this.stops = opts.stops;
    this.intervalMs = opts.intervalMs ?? 2000;
    this.baseSpeedKmh = opts.speedKmh ?? 34;
    this.index = opts.startIndex ?? 0;
  }

  subscribe(listener: SimulationListener): () => void {
    this.listeners.add(listener);
    // İlk durumu hemen ilet
    listener(this.buildTick());
    return () => this.listeners.delete(listener);
  }

  start(): void {
    if (this.timer) return;
    this.timer = setInterval(() => this.step(), this.intervalMs);
  }

  stop(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  isRunning(): boolean {
    return this.timer !== null;
  }

  private step(): void {
    if (this.index >= this.path.length - 1) {
      this.stop();
      this.emit(this.buildTick(true));
      return;
    }
    this.index += 1;
    this.emit(this.buildTick());
  }

  private currentLocation(): LatLng {
    return this.path[Math.min(this.index, this.path.length - 1)]!;
  }

  private computeNextStopIndex(loc: LatLng): number {
    // Araca en yakın "ileri" durak: yol boyunca sırayla ilk ulaşılmamış durak.
    for (let i = 0; i < this.stops.length; i++) {
      const stop = this.stops[i]!;
      const passed = this.hasPassedStop(i);
      if (!passed) return i;
      if (isWithinRadius(loc, stop, stop.radius_meters)) return i;
    }
    return this.stops.length - 1;
  }

  private hasPassedStop(stopIndex: number): boolean {
    // Path, duraklar arasına eşit bölünmüş (buildPath: 8 segment/durak arası).
    const segmentsPerStop = 8;
    const stopPathIndex = stopIndex * segmentsPerStop;
    return this.index > stopPathIndex;
  }

  private atStop(loc: LatLng): number | null {
    for (let i = 0; i < this.stops.length; i++) {
      const stop = this.stops[i]!;
      if (isWithinRadius(loc, stop, stop.radius_meters)) return i;
    }
    return null;
  }

  private buildTick(finished = false): SimulationTick {
    const loc = this.currentLocation();
    const prev = this.path[Math.max(0, this.index - 1)]!;
    const heading = bearingDeg(prev, loc);
    const moving = haversineMeters(prev, loc) > 1;
    return {
      location: loc,
      heading,
      speedKmh: moving ? this.baseSpeedKmh : 0,
      nextStopIndex: this.computeNextStopIndex(loc),
      atStopIndex: this.atStop(loc),
      finished: finished || this.index >= this.path.length - 1,
    };
  }

  private emit(tick: SimulationTick): void {
    this.listeners.forEach((l) => l(tick));
  }
}
