import { MockETAProvider } from '@/services/eta/MockETAProvider';
import { demoStops } from '@/mocks/demoData';

describe('MockETAProvider', () => {
  const provider = new MockETAProvider();

  it('hedef durak için kalan durak sayısını doğru hesaplar', async () => {
    const result = await provider.calculate({
      vehicleLocation: { latitude: demoStops[0]!.latitude, longitude: demoStops[0]!.longitude },
      stops: demoStops,
      nextStopIndex: 1,
      targetStopIndex: 4,
      averageSpeedKmh: 32,
      dwellSecondsPerStop: 45,
      plannedArrivalAt: new Date().toISOString(),
    });
    // 1..4 arası = 4 durak
    expect(result.remaining_stops).toBe(4);
    expect(result.remaining_distance_meters).toBeGreaterThan(0);
    expect(result.eta_minutes).toBeGreaterThanOrEqual(0);
  });

  it('araç ilerledikçe ETA azalır', async () => {
    const base = {
      stops: demoStops,
      targetStopIndex: 4,
      averageSpeedKmh: 32,
      dwellSecondsPerStop: 45,
      plannedArrivalAt: new Date().toISOString(),
    };
    const far = await provider.calculate({
      ...base,
      nextStopIndex: 1,
      vehicleLocation: { latitude: demoStops[0]!.latitude, longitude: demoStops[0]!.longitude },
    });
    const near = await provider.calculate({
      ...base,
      nextStopIndex: 4,
      vehicleLocation: { latitude: demoStops[3]!.latitude, longitude: demoStops[3]!.longitude },
    });
    expect(near.remaining_distance_meters).toBeLessThan(far.remaining_distance_meters);
    expect(near.remaining_stops).toBeLessThan(far.remaining_stops);
  });
});
