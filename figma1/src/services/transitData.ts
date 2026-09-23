// Centralized Transit Dataset and Domain Models for SmartCrowd Transit

export interface TransitStop {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  order: number;
  isMajor?: boolean;
}

export interface TimetableEntry {
  period: 'morning' | 'afternoon' | 'evening';
  times: { time: string; status: 'LIVE' | 'SCHEDULED' }[];
}

export interface TransitRoute {
  id: string;
  operator: string;
  routeNumber: string;
  name: string;
  origin: string;
  destination: string;
  direction: 'outbound' | 'inbound';
  stops: TransitStop[];
  // High-density polyline coordinates following actual roads
  coordinates: [number, number][]; // [lat, lng]
  // Detour coordinates when route deviation is active
  detourCoordinates?: [number, number][];
  timetable: TimetableEntry[];
}

export type TrackingSource = 'CROWD' | 'DRIVER' | 'HYBRID' | 'LAST_KNOWN' | 'SCHEDULED' | 'NO_LIVE_DATA';
export type ServiceStatus = 'NORMAL' | 'POSSIBLE_DISRUPTION' | 'CONFIRMED_DISRUPTION' | 'DETOUR';
export type OccupancyLevel = 'LOW' | 'MODERATE' | 'HIGH';
export type ConfidenceLevel = 'High confidence' | 'Medium confidence' | 'Limited live data' | 'No live data';

export interface BusState {
  id: string;
  routeId: string;
  operator: string;
  routeNumber: string;
  latitude: number;
  longitude: number;
  heading: number; // in degrees (0 = north, 90 = east, etc.)
  speedKmh: number;
  currentCoordinateIndex: number;
  currentStopId: string;
  nextStopId: string;
  etaMinutes: number;
  progressPercent: number;
  occupancy: OccupancyLevel;
  trackingSource: TrackingSource;
  confidence: ConfidenceLevel;
  serviceStatus: ServiceStatus;
  lastUpdatedSec: number;
  disruptionMessage?: string;
}

// -------------------------------------------------------------
// Realistic Road Coordinates for TMT 50 (Thane Station West -> Manpada)
// Connects Thane Station West via Gokhale Rd, Teen Hath Naka,
// Cadbury Junction, Majiwada Junction, Ghodbunder Rd to Manpada.
// -------------------------------------------------------------
export const TMT_50_STOPS: TransitStop[] = [
  { id: 'stop-1', name: 'Thane Station West', latitude: 19.1864, longitude: 72.9756, order: 1, isMajor: true },
  { id: 'stop-2', name: 'Panchpakhadi', latitude: 19.1932, longitude: 72.9692, order: 2 },
  { id: 'stop-3', name: 'Nitin Company Junction', latitude: 19.1995, longitude: 72.9680, order: 3 },
  { id: 'stop-4', name: 'Cadbury Junction', latitude: 19.2045, longitude: 72.9710, order: 4, isMajor: true },
  { id: 'stop-5', name: 'Majiwada Junction', latitude: 19.2138, longitude: 72.9785, order: 5, isMajor: true },
  { id: 'stop-6', name: 'Kapurbawdi', latitude: 19.2225, longitude: 72.9810, order: 6 },
  { id: 'stop-7', name: 'Manpada', latitude: 19.2365, longitude: 72.9765, order: 7, isMajor: true },
];

export const TMT_50_COORDINATES: [number, number][] = [
  // Thane Station West
  [19.1864, 72.9756],
  [19.1872, 72.9749],
  [19.1883, 72.9738],
  [19.1898, 72.9723],
  [19.1915, 72.9706],
  // Panchpakhadi / Teen Hath Naka
  [19.1932, 72.9692],
  [19.1945, 72.9687],
  [19.1962, 72.9683],
  [19.1978, 72.9681],
  // Nitin Company
  [19.1995, 72.9680],
  [19.2010, 72.9687],
  [19.2028, 72.9698],
  // Cadbury Junction
  [19.2045, 72.9710],
  [19.2062, 72.9724],
  [19.2081, 72.9742],
  [19.2102, 72.9760],
  [19.2120, 72.9774],
  // Majiwada Junction
  [19.2138, 72.9785],
  [19.2155, 72.9793],
  [19.2175, 72.9802],
  [19.2198, 72.9808],
  // Kapurbawdi
  [19.2225, 72.9810],
  [19.2245, 72.9805],
  [19.2268, 72.9797],
  [19.2290, 72.9788],
  [19.2312, 72.9780],
  [19.2335, 72.9773],
  [19.2352, 72.9768],
  // Manpada
  [19.2365, 72.9765],
];

// Alternate Detour coordinates branching from Majiwada via Pokhran Rd 2 to Manpada
export const TMT_50_DETOUR_COORDINATES: [number, number][] = [
  [19.1864, 72.9756],
  [19.1898, 72.9723],
  [19.1932, 72.9692],
  [19.1995, 72.9680],
  [19.2045, 72.9710],
  [19.2138, 72.9785], // Majiwada diversion start
  [19.2150, 72.9720], // Diversion west along Pokhran
  [19.2185, 72.9680],
  [19.2240, 72.9695],
  [19.2295, 72.9730],
  [19.2340, 72.9750],
  [19.2365, 72.9765], // Re-joins at Manpada
];

export const TMT_50_TIMETABLE: TimetableEntry[] = [
  {
    period: 'morning',
    times: [
      { time: '07:00', status: 'SCHEDULED' },
      { time: '07:20', status: 'SCHEDULED' },
      { time: '07:40', status: 'LIVE' },
      { time: '08:00', status: 'SCHEDULED' },
      { time: '08:20', status: 'SCHEDULED' },
      { time: '08:40', status: 'SCHEDULED' },
      { time: '09:00', status: 'SCHEDULED' },
      { time: '09:30', status: 'SCHEDULED' },
    ],
  },
  {
    period: 'afternoon',
    times: [
      { time: '12:00', status: 'SCHEDULED' },
      { time: '12:20', status: 'SCHEDULED' },
      { time: '12:40', status: 'SCHEDULED' },
      { time: '13:00', status: 'SCHEDULED' },
      { time: '13:30', status: 'SCHEDULED' },
      { time: '14:00', status: 'SCHEDULED' },
    ],
  },
  {
    period: 'evening',
    times: [
      { time: '17:00', status: 'SCHEDULED' },
      { time: '17:20', status: 'SCHEDULED' },
      { time: '17:40', status: 'SCHEDULED' },
      { time: '18:00', status: 'SCHEDULED' },
      { time: '18:20', status: 'SCHEDULED' },
      { time: '18:40', status: 'SCHEDULED' },
      { time: '19:00', status: 'SCHEDULED' },
    ],
  },
];

// Primary Route Definition
export const ROUTE_TMT_50: TransitRoute = {
  id: 'tmt-50',
  operator: 'TMT',
  routeNumber: '50',
  name: 'Thane Station West → Manpada',
  origin: 'Thane Station West',
  destination: 'Manpada',
  direction: 'outbound',
  stops: TMT_50_STOPS,
  coordinates: TMT_50_COORDINATES,
  detourCoordinates: TMT_50_DETOUR_COORDINATES,
  timetable: TMT_50_TIMETABLE,
};

// Secondary Route TMT 2 (Thane Station West -> Balkum)
export const ROUTE_TMT_2: TransitRoute = {
  id: 'tmt-2',
  operator: 'TMT',
  routeNumber: '2',
  name: 'Thane Station West → Balkum',
  origin: 'Thane Station West',
  destination: 'Balkum',
  direction: 'outbound',
  stops: [
    { id: 'stop-t2-1', name: 'Thane Station West', latitude: 19.1864, longitude: 72.9756, order: 1 },
    { id: 'stop-t2-2', name: 'Panchpakhadi', latitude: 19.1932, longitude: 72.9692, order: 2 },
    { id: 'stop-t2-3', name: 'Majiwada Junction', latitude: 19.2138, longitude: 72.9785, order: 3 },
    { id: 'stop-t2-4', name: 'Balkum Naka', latitude: 19.2240, longitude: 72.9920, order: 4 },
  ],
  coordinates: [
    [19.1864, 72.9756],
    [19.1932, 72.9692],
    [19.2045, 72.9710],
    [19.2138, 72.9785],
    [19.2190, 72.9850],
    [19.2240, 72.9920],
  ],
  timetable: [
    {
      period: 'morning',
      times: [
        { time: '08:15', status: 'SCHEDULED' },
        { time: '08:45', status: 'SCHEDULED' },
        { time: '10:25', status: 'SCHEDULED' },
      ],
    },
  ],
};

// All available routes dataset
export const ALL_ROUTES: Record<string, TransitRoute> = {
  'tmt-50': ROUTE_TMT_50,
  'tmt50': ROUTE_TMT_50,
  'tmt-2': ROUTE_TMT_2,
  'tmt2': ROUTE_TMT_2,
};

// Utility function to calculate heading bearing between two lat/lng points in degrees (0-360)
export function calculateBearing(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const toDeg = (rad: number) => (rad * 180) / Math.PI;

  const dLon = toRad(lon2 - lon1);
  const y = Math.sin(dLon) * Math.cos(toRad(lat2));
  const x =
    Math.cos(toRad(lat1)) * Math.sin(toRad(lat2)) -
    Math.sin(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.cos(dLon);

  const brng = toDeg(Math.atan2(y, x));
  return (brng + 360) % 360;
}

// Approximate distance in km using Haversine formula
export function calculateDistanceKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
