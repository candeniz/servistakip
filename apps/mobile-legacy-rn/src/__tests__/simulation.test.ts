import { SimulationEngine } from '@/services/simulation/SimulationEngine';
import { demoSimulationPath, demoStops } from '@/mocks/demoData';

jest.useFakeTimers();

describe('SimulationEngine', () => {
  it('başlangıçta ilk konumu yayınlar', () => {
    const engine = new SimulationEngine({ path: demoSimulationPath, stops: demoStops, intervalMs: 1000 });
    const ticks: number[] = [];
    engine.subscribe((t) => ticks.push(t.location.latitude));
    expect(ticks).toHaveLength(1);
  });

  it('adım ilerledikçe araç konumu değişir', () => {
    const engine = new SimulationEngine({ path: demoSimulationPath, stops: demoStops, intervalMs: 1000 });
    let last = { latitude: 0, longitude: 0 };
    engine.subscribe((t) => {
      last = t.location;
    });
    const first = { ...last };
    engine.start();
    jest.advanceTimersByTime(3000);
    engine.stop();
    expect(last).not.toEqual(first);
  });

  it('yol sonunda finished=true olur', () => {
    const shortPath = demoSimulationPath.slice(0, 3);
    const engine = new SimulationEngine({ path: shortPath, stops: demoStops, intervalMs: 500 });
    let finished = false;
    engine.subscribe((t) => {
      finished = t.finished;
    });
    engine.start();
    jest.advanceTimersByTime(5000);
    expect(finished).toBe(true);
  });
});
