/**
 * API DTO tipleri — istek ve yanıt şekilleri.
 * Backend Pydantic şemaları ile aynı sözleşmeyi temsil eder.
 */
import type { Role } from './roles';
import type {
  UserStatus,
  TenantStatus,
  TripStatus,
  BoardingStatus,
  VehicleStatus,
  RouteDirection,
  IncidentType,
  NotificationType,
} from './status';

export interface AuthTokens {
  access_token: string;
  refresh_token: string;
  token_type: 'bearer';
  expires_in: number;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthUser {
  id: string;
  tenant_id: string | null;
  first_name: string;
  last_name: string;
  email: string;
  phone: string | null;
  role: Role;
  status: UserStatus;
  profile_photo: string | null;
  tenant_name: string | null;
}

export interface LoginResponse {
  tokens: AuthTokens;
  user: AuthUser;
}

export interface Tenant {
  id: string;
  name: string;
  company_code: string;
  logo_url: string | null;
  primary_color: string | null;
  status: TenantStatus;
  package_id: string | null;
  user_limit: number;
  vehicle_limit: number;
  active_user_count: number;
  active_trip_count: number;
  created_at: string;
  updated_at: string;
}

export interface Vehicle {
  id: string;
  tenant_id: string;
  plate_number: string;
  brand: string;
  model: string;
  year: number;
  capacity: number;
  vehicle_type: string;
  inspection_expiry_date: string | null;
  insurance_expiry_date: string | null;
  status: VehicleStatus;
}

export interface Stop {
  id: string;
  tenant_id: string;
  route_id: string;
  name: string;
  latitude: number;
  longitude: number;
  order_index: number;
  planned_arrival_offset: number; // dakika
  radius_meters: number;
  status: string;
}

export interface RouteSummary {
  id: string;
  tenant_id: string;
  name: string;
  direction: RouteDirection;
  start_location: string;
  end_location: string;
  encoded_polyline: string | null;
  estimated_distance: number;
  estimated_duration: number;
  status: string;
  stop_count: number;
}

export interface RouteDetail extends RouteSummary {
  stops: Stop[];
}

export interface LatLng {
  latitude: number;
  longitude: number;
}

export interface VehicleLocation extends LatLng {
  service_trip_id: string;
  vehicle_id: string;
  driver_id: string;
  speed: number;
  heading: number;
  accuracy: number;
  recorded_at: string;
}

export interface EtaResult {
  remaining_stops: number;
  remaining_distance_meters: number;
  eta_minutes: number;
  planned_arrival_at: string;
  estimated_arrival_at: string;
  delay_minutes: number;
}

export interface TripPassenger {
  id: string;
  service_trip_id: string;
  passenger_id: string;
  passenger_name: string;
  stop_id: string;
  stop_name: string;
  boarding_status: BoardingStatus;
  boarded_at: string | null;
  driver_note: string | null;
}

export interface ServiceTrip {
  id: string;
  tenant_id: string;
  service_definition_id: string;
  service_name: string;
  service_date: string;
  direction: RouteDirection;
  route_id: string;
  route_name: string;
  driver_id: string;
  driver_name: string;
  vehicle_id: string;
  vehicle_plate: string;
  planned_start_at: string;
  actual_start_at: string | null;
  planned_end_at: string;
  actual_end_at: string | null;
  current_stop_id: string | null;
  next_stop_id: string | null;
  status: TripStatus;
  delay_minutes: number;
  total_distance: number;
  passenger_count: number;
  stop_count: number;
}

export interface AppNotification {
  id: string;
  tenant_id: string;
  user_id: string;
  title: string;
  message: string;
  type: NotificationType;
  data: Record<string, unknown> | null;
  read_at: string | null;
  created_at: string;
}

export interface Incident {
  id: string;
  tenant_id: string;
  service_trip_id: string;
  driver_id: string;
  vehicle_id: string;
  incident_type: IncidentType;
  description: string;
  latitude: number | null;
  longitude: number | null;
  image_url: string | null;
  status: string;
  created_at: string;
  resolved_at: string | null;
}

export interface AbsenceRequest {
  id: string;
  tenant_id: string;
  passenger_id: string;
  start_date: string;
  end_date: string;
  morning_absent: boolean;
  evening_absent: boolean;
  reason: string | null;
  status: string;
}

/** Basit sayfalama zarfı. */
export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  page_size: number;
}

/** Standart API hata gövdesi (sistem içi detay içermez). */
export interface ApiError {
  detail: string;
  code?: string;
}
