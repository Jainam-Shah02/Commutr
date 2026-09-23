import React, { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react';
import {
  TransitRoute,
  TransitStop,
  BusState,
  TrackingSource,
  ServiceStatus,
  OccupancyLevel,
  ConfidenceLevel,
  ROUTE_TMT_50,
  ALL_ROUTES,
  calculateBearing,
} from '../services/transitData';

interface TransitContextType {
  selectedRoute: TransitRoute;
  busState: BusState | null;
  isSimulating: boolean;
  setIsSimulating: (sim: boolean) => void;
  trackingSource: TrackingSource;
  serviceStatus: ServiceStatus;
  userLocation: { latitude: number; longitude: number } | null;
  requestUserLocation: () => void;
  followBus: boolean;
  setFollowBus: (follow: boolean) => void;
  destinationStopId: string;
  setDestinationStopId: (id: string) => void;
  driverModeActive: boolean;
  startDriverTrip: () => void;
  endDriverTrip: () => void;
  reportDriverBreakdown: () => void;
  reportPassengerProblem: (problemType: string) => void;
  triggerDetour: (active: boolean) => void;
  toggleLiveAvailable: () => void;
  resetSimulation: () => void;
  setSelectedRouteById: (routeId: string) => void;
  activePolyline: [number, number][];
}

const TransitContext = createContext<TransitContextType | undefined>(undefined);

export const TransitProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [selectedRoute, setSelectedRoute] = useState<TransitRoute>(ROUTE_TMT_50);
  const [isSimulating, setIsSimulating] = useState<boolean>(true);
  const [trackingSource, setTrackingSource] = useState<TrackingSource>('CROWD');
  const [serviceStatus, setServiceStatus] = useState<ServiceStatus>('NORMAL');
  const [followBus, setFollowBus] = useState<boolean>(true);
  const [destinationStopId, setDestinationStopId] = useState<string>('stop-7'); // default: Manpada
  const [driverModeActive, setDriverModeActive] = useState<boolean>(false);
  const [isLiveAvailable, setIsLiveAvailable] = useState<boolean>(true);
  const [userLocation, setUserLocation] = useState<{ latitude: number; longitude: number } | null>(null);

  // Active path coordinates (switches to detour coordinates when DETOUR is active)
  const activePolyline = useMemo(() => {
    if (serviceStatus === 'DETOUR' && selectedRoute.detourCoordinates) {
      return selectedRoute.detourCoordinates;
    }
    return selectedRoute.coordinates;
  }, [selectedRoute, serviceStatus]);

  // Initial bus state
  const initialCoordIndex = Math.min(17, activePolyline.length - 1); // near Majiwada Junction
  const [coordIndex, setCoordIndex] = useState<number>(initialCoordIndex);
  const [lastUpdated, setLastUpdated] = useState<number>(12);

  // Helper to find closest stop & next stop based on coordinate index
  const getStopStatusForIndex = useCallback(
    (idx: number, stops: TransitStop[], totalCoords: number) => {
      const progressFraction = idx / (totalCoords - 1);
      const totalStops = stops.length;
      const approximateStopFloat = progressFraction * (totalStops - 1);
      const currentStopIndex = Math.min(Math.floor(approximateStopFloat), totalStops - 1);
      const nextStopIndex = Math.min(currentStopIndex + 1, totalStops - 1);

      const currentStop = stops[currentStopIndex];
      const nextStop = stops[nextStopIndex];

      // ETA estimation: roughly 2.5 minutes per remaining stop
      const stopsRemaining = Math.max(1, totalStops - 1 - currentStopIndex);
      const remainingFractionInCurrentSegment = 1 - (approximateStopFloat - currentStopIndex);
      const estimatedMinutes = Math.max(1, Math.round(stopsRemaining * 2.2 * remainingFractionInCurrentSegment + 1));

      return {
        currentStopId: currentStop.id,
        nextStopId: nextStop.id,
        etaMinutes: estimatedMinutes,
        progressPercent: Math.round(progressFraction * 100),
      };
    },
    []
  );

  // User location request with safety
  const requestUserLocation = useCallback(() => {
    if (typeof window !== 'undefined' && 'geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          setUserLocation({
            latitude: pos.coords.latitude,
            longitude: pos.coords.longitude,
          });
        },
        () => {
          // Fallback if permission denied - Thane station vicinity
          setUserLocation({ latitude: 19.1890, longitude: 72.9730 });
        },
        { enableHighAccuracy: true, timeout: 5000 }
      );
    }
  }, []);

  // Request location once on mount
  useEffect(() => {
    requestUserLocation();
  }, [requestUserLocation]);

  // Simulation timer loop
  useEffect(() => {
    if (!isSimulating || !isLiveAvailable || serviceStatus === 'CONFIRMED_DISRUPTION') {
      return;
    }

    const interval = setInterval(() => {
      setCoordIndex((prev) => {
        const next = prev + 1;
        if (next >= activePolyline.length) {
          return 0; // loop back to start for continuous demo
        }
        return next;
      });

      setLastUpdated(Math.floor(Math.random() * 5) + 3);
    }, 3500);

    return () => clearInterval(interval);
  }, [isSimulating, isLiveAvailable, serviceStatus, activePolyline.length]);

  // Second ticker for "Updated X sec ago"
  useEffect(() => {
    const timer = setInterval(() => {
      setLastUpdated((prev) => (prev < 45 ? prev + 1 : 45));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  // Build reactive BusState
  const busState: BusState | null = useMemo(() => {
    if (!isLiveAvailable) {
      return null; // NO LIVE DATA state
    }

    const safeIndex = Math.min(coordIndex, activePolyline.length - 1);
    const currentPoint = activePolyline[safeIndex];
    const nextPoint = activePolyline[Math.min(safeIndex + 1, activePolyline.length - 1)] || currentPoint;

    const heading = calculateBearing(currentPoint[0], currentPoint[1], nextPoint[0], nextPoint[1]);
    const { currentStopId, nextStopId, etaMinutes, progressPercent } = getStopStatusForIndex(
      safeIndex,
      selectedRoute.stops,
      activePolyline.length
    );

    let confidence: ConfidenceLevel = 'High confidence';
    if (trackingSource === 'DRIVER') {
      confidence = 'High confidence';
    } else if (trackingSource === 'SCHEDULED' || trackingSource === 'LAST_KNOWN') {
      confidence = 'Limited live data';
    }

    const occupancy: OccupancyLevel = progressPercent > 60 ? 'HIGH' : progressPercent > 30 ? 'MODERATE' : 'LOW';

    return {
      id: `bus-${selectedRoute.id}`,
      routeId: selectedRoute.id,
      operator: selectedRoute.operator,
      routeNumber: selectedRoute.routeNumber,
      latitude: currentPoint[0],
      longitude: currentPoint[1],
      heading,
      speedKmh: serviceStatus === 'CONFIRMED_DISRUPTION' ? 0 : 28,
      currentCoordinateIndex: safeIndex,
      currentStopId,
      nextStopId,
      etaMinutes: serviceStatus === 'CONFIRMED_DISRUPTION' ? 0 : etaMinutes,
      progressPercent,
      occupancy,
      trackingSource,
      confidence,
      serviceStatus,
      lastUpdatedSec: lastUpdated,
      disruptionMessage:
        serviceStatus === 'CONFIRMED_DISRUPTION'
          ? 'Confirmed service disruption. Operator confirmed bus breakdown.'
          : serviceStatus === 'POSSIBLE_DISRUPTION'
          ? 'Possible service disruption. Unusual stop detected, awaiting operator confirmation.'
          : serviceStatus === 'DETOUR'
          ? 'This bus is following a temporary route due to road blockage.'
          : undefined,
    };
  }, [
    isLiveAvailable,
    coordIndex,
    activePolyline,
    selectedRoute,
    getStopStatusForIndex,
    trackingSource,
    serviceStatus,
    lastUpdated,
  ]);

  // Driver controls
  const startDriverTrip = useCallback(() => {
    setDriverModeActive(true);
    setTrackingSource('DRIVER');
    setServiceStatus('NORMAL');
    setIsLiveAvailable(true);
  }, []);

  const endDriverTrip = useCallback(() => {
    setDriverModeActive(false);
    setTrackingSource('CROWD');
  }, []);

  const reportDriverBreakdown = useCallback(() => {
    setServiceStatus('CONFIRMED_DISRUPTION');
  }, []);

  const reportPassengerProblem = useCallback((_problemType: string) => {
    // Passenger reports problem -> system enters POSSIBLE_DISRUPTION pending operator confirmation
    setServiceStatus('POSSIBLE_DISRUPTION');
  }, []);

  const triggerDetour = useCallback((active: boolean) => {
    setServiceStatus(active ? 'DETOUR' : 'NORMAL');
    setCoordIndex(0);
  }, []);

  const toggleLiveAvailable = useCallback(() => {
    setIsLiveAvailable((prev) => !prev);
    setTrackingSource((prev) => (prev === 'NO_LIVE_DATA' ? 'CROWD' : 'NO_LIVE_DATA'));
  }, []);

  const resetSimulation = useCallback(() => {
    setCoordIndex(initialCoordIndex);
    setServiceStatus('NORMAL');
    setIsLiveAvailable(true);
    setTrackingSource('CROWD');
  }, [initialCoordIndex]);

  const setSelectedRouteById = useCallback((routeId: string) => {
    const found = ALL_ROUTES[routeId] || ALL_ROUTES['tmt-50'];
    setSelectedRoute(found);
    setCoordIndex(0);
  }, []);

  return (
    <TransitContext.Provider
      value={{
        selectedRoute,
        busState,
        isSimulating,
        setIsSimulating,
        trackingSource,
        serviceStatus,
        userLocation,
        requestUserLocation,
        followBus,
        setFollowBus,
        destinationStopId,
        setDestinationStopId,
        driverModeActive,
        startDriverTrip,
        endDriverTrip,
        reportDriverBreakdown,
        reportPassengerProblem,
        triggerDetour,
        toggleLiveAvailable,
        resetSimulation,
        setSelectedRouteById,
        activePolyline,
      }}
    >
      {children}
    </TransitContext.Provider>
  );
};

export const useTransit = () => {
  const context = useContext(TransitContext);
  if (!context) {
    throw new Error('useTransit must be used within a TransitProvider');
  }
  return context;
};
