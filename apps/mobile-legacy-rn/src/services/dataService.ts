import type {
  AppNotification,
  ServiceTrip,
  Tenant,
  TripPassenger,
  Vehicle,
  RouteDetail,
} from '@servis/shared';
import { env } from '@/config/env';
import { api } from './apiClient';
import { demoTenants, demoVehicles, demoTrip, demoTripPassengers, demoRoute } from '@/mocks/demoData';
import { demoNotifications } from '@/mocks/demoNotifications';

/**
 * Liste/detay verileri için servis katmanı.
 * useMock=true iken mock verileri, aksi halde gerçek API'yi kullanır.
 * Ekranlar bu katmanı TanStack Query ile tüketir.
 */
const delay = (ms = 250) => new Promise<void>((r) => setTimeout(r, ms));

export const dataService = {
  async listTenants(): Promise<Tenant[]> {
    if (env.useMock) {
      await delay();
      return demoTenants;
    }
    const { data } = await api.get<{ items: Tenant[] }>('/tenants');
    return data.items;
  },

  async listVehicles(): Promise<Vehicle[]> {
    if (env.useMock) {
      await delay();
      return demoVehicles;
    }
    const { data } = await api.get<{ items: Vehicle[] }>('/vehicles');
    return data.items;
  },

  async listTrips(): Promise<ServiceTrip[]> {
    if (env.useMock) {
      await delay();
      return [demoTrip];
    }
    const { data } = await api.get<{ items: ServiceTrip[] }>('/trips');
    return data.items;
  },

  async getTrip(id: string): Promise<ServiceTrip> {
    if (env.useMock) {
      await delay();
      return demoTrip;
    }
    const { data } = await api.get<ServiceTrip>(`/trips/${id}`);
    return data;
  },

  async getRoute(id: string): Promise<RouteDetail> {
    if (env.useMock) {
      await delay();
      return demoRoute;
    }
    const { data } = await api.get<RouteDetail>(`/routes/${id}`);
    return data;
  },

  async listTripPassengers(tripId: string): Promise<TripPassenger[]> {
    if (env.useMock) {
      await delay();
      return demoTripPassengers;
    }
    const { data } = await api.get<{ items: TripPassenger[] }>(`/trips/${tripId}/passengers`);
    return data.items;
  },

  async listNotifications(): Promise<AppNotification[]> {
    if (env.useMock) {
      await delay();
      return demoNotifications;
    }
    const { data } = await api.get<{ items: AppNotification[] }>('/passenger/notifications');
    return data.items;
  },

  async getPassengerCurrentTrip(): Promise<ServiceTrip> {
    if (env.useMock) {
      await delay();
      return demoTrip;
    }
    const { data } = await api.get<ServiceTrip>('/passenger/current-trip');
    return data;
  },
};
