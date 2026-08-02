import type { LatLng, Stop, EtaResult } from '@servis/shared';

/** ETA hesaplaması için gerekli girdi. */
export interface EtaInput {
  /** Aracın mevcut konumu. */
  vehicleLocation: LatLng;
  /** Sıradaki durak (varış hedefi zinciri buradan başlar). */
  nextStopIndex: number;
  /** Güzergâhın tüm durakları (sıralı). */
  stops: Stop[];
  /** Hedef durak (genelde yolcunun durağı). */
  targetStopIndex: number;
  /** Ortalama hız (km/s). */
  averageSpeedKmh: number;
  /** Her durakta beklenen ortalama duruş süresi (saniye). */
  dwellSecondsPerStop: number;
  /** Planlanan varış zamanı (ISO). Gecikme hesabı için. */
  plannedArrivalAt: string;
  /** Şu anki referans zaman (ISO); verilmezse now(). */
  now?: string;
}

/**
 * ETA sağlayıcı arayüzü.
 * MVP'de MockETAProvider kullanılır; ileride Google/Mapbox
 * aynı arayüzü uygulayarak sorunsuzca değiştirilebilir.
 */
export interface ETAProvider {
  readonly name: string;
  calculate(input: EtaInput): Promise<EtaResult>;
}
