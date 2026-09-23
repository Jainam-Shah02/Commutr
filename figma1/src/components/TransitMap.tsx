import React, { useEffect, useRef } from 'react';
import L from 'leaflet';
import { TransitRoute, TransitStop, BusState, ServiceStatus } from '../services/transitData';

interface TransitMapProps {
  route: TransitRoute;
  bus: BusState | null;
  stops: TransitStop[];
  userLocation: { latitude: number; longitude: number } | null;
  destinationStopId?: string;
  followBus?: boolean;
  onStopSelect?: (stop: TransitStop) => void;
  activePolyline?: [number, number][];
  serviceStatus?: ServiceStatus;
  height?: string | number;
}

export default function TransitMap({
  route,
  bus,
  stops,
  userLocation,
  destinationStopId,
  followBus = false,
  onStopSelect,
  activePolyline,
  serviceStatus = 'NORMAL',
  height = '100%',
}: TransitMapProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<L.Map | null>(null);
  const primaryLineRef = useRef<L.Polyline | null>(null);
  const detourLineRef = useRef<L.Polyline | null>(null);
  const stopMarkersRef = useRef<L.Marker[]>([]);
  const busMarkerRef = useRef<L.Marker | null>(null);
  const userMarkerRef = useRef<L.Marker | null>(null);
  const hasFittedBoundsRef = useRef<boolean>(false);

  // Initialize Map
  useEffect(() => {
    if (!containerRef.current || mapRef.current) return;

    // Default center on Thane
    const map = L.map(containerRef.current, {
      center: [19.205, 72.975],
      zoom: 13,
      zoomControl: false,
      attributionControl: false,
    });

    // Add minimal OpenStreetMap tile layer
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      subdomains: ['a', 'b', 'c'],
    }).addTo(map);

    // Zoom control in top right
    L.control
      .zoom({
        position: 'topright',
      })
      .addTo(map);

    mapRef.current = map;

    return () => {
      map.remove();
      mapRef.current = null;
    };
  }, []);

  // Update Route Polyline
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    // Remove existing lines
    if (primaryLineRef.current) {
      primaryLineRef.current.remove();
      primaryLineRef.current = null;
    }
    if (detourLineRef.current) {
      detourLineRef.current.remove();
      detourLineRef.current = null;
    }

    const coordsToDraw = activePolyline || route.coordinates;

    // If DETOUR is active and detour coordinates exist, draw original route in subtle dashed grey
    if (serviceStatus === 'DETOUR' && route.detourCoordinates) {
      detourLineRef.current = L.polyline(route.coordinates, {
        color: '#94A3B8',
        weight: 4,
        dashArray: '6, 8',
        opacity: 0.8,
        lineCap: 'round',
        lineJoin: 'round',
      }).addTo(map);
    }

    // Main route line: #2563EB rounded 5px
    primaryLineRef.current = L.polyline(coordsToDraw, {
      color: '#2563EB',
      weight: 5,
      opacity: 0.95,
      lineCap: 'round',
      lineJoin: 'round',
    }).addTo(map);

    // Auto fit bounds on route load if not already fitted
    if (!hasFittedBoundsRef.current && primaryLineRef.current) {
      map.fitBounds(primaryLineRef.current.getBounds(), {
        padding: [45, 45],
        maxZoom: 15,
      });
      hasFittedBoundsRef.current = true;
    }
  }, [route, activePolyline, serviceStatus]);

  // Update Stop Markers
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    // Clear previous stop markers
    stopMarkersRef.current.forEach((m) => m.remove());
    stopMarkersRef.current = [];

    // Identify current stop index
    const currentStopIndex = stops.findIndex((s) => s.id === bus?.currentStopId);

    stops.forEach((stop, index) => {
      let markerClass = 'stop-marker-upcoming';
      if (stop.id === destinationStopId) {
        markerClass = 'stop-marker-dest';
      } else if (bus && stop.id === bus.currentStopId) {
        markerClass = 'stop-marker-current';
      } else if (currentStopIndex >= 0 && index < currentStopIndex) {
        markerClass = 'stop-marker-passed';
      }

      const icon = L.divIcon({
        className: 'custom-stop-icon',
        html: `<div class="${markerClass}"></div>`,
        iconSize: [16, 16],
        iconAnchor: [8, 8],
      });

      const marker = L.marker([stop.latitude, stop.longitude], { icon }).addTo(map);

      // Compact popup
      const isDestination = stop.id === destinationStopId;
      const etaText = index === currentStopIndex ? 'Bus here now' : index > currentStopIndex ? `ETA ~${Math.max(2, (index - Math.max(0, currentStopIndex)) * 3)} min` : 'Passed';

      const popupHtml = `
        <div style="padding: 10px 12px; min-width: 170px;">
          <div style="font-weight: 700; font-size: 13px; color: #0F172A; margin-bottom: 3px;">
            ${stop.name}
          </div>
          <div style="font-size: 11px; color: #64748B; margin-bottom: 6px;">
            ${isDestination ? '📍 Your Destination' : 'Bus Stop'}
          </div>
          <div style="display: flex; align-items: center; justify-content: space-between; padding: 4px 0; border-top: 1px solid #F1F5F9; margin-bottom: 8px;">
            <span style="font-size: 11px; font-weight: 600; color: #2563EB;">${route.operator} ${route.routeNumber}</span>
            <span style="font-size: 11px; font-weight: 600; color: #16A34A;">${etaText}</span>
          </div>
          <button id="btn-stop-${stop.id}" style="width: 100%; font-size: 11px; font-weight: 600; background: #EFF6FF; color: #2563EB; border: 1px solid #BFDBFE; border-radius: 6px; padding: 4px 8px; cursor: pointer;">
            View Stop
          </button>
        </div>
      `;

      marker.bindPopup(popupHtml, {
        offset: [0, -10],
        closeButton: false,
      });

      marker.on('popupopen', () => {
        const btn = document.getElementById(`btn-stop-${stop.id}`);
        if (btn && onStopSelect) {
          btn.onclick = () => {
            marker.closePopup();
            onStopSelect(stop);
          };
        }
      });

      stopMarkersRef.current.push(marker);
    });
  }, [stops, bus?.currentStopId, destinationStopId, route, onStopSelect]);

  // Update Bus Marker & Camera Follow
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    if (!bus) {
      // If no live data, remove bus marker
      if (busMarkerRef.current) {
        busMarkerRef.current.remove();
        busMarkerRef.current = null;
      }
      return;
    }

    const busLatLng: [number, number] = [bus.latitude, bus.longitude];
    const isDisrupted = bus.serviceStatus === 'CONFIRMED_DISRUPTION';
    const badgeText = isDisrupted ? 'Stopped' : bus.trackingSource === 'DRIVER' ? 'Driver Verified' : 'Estimated';
    const pillBg = isDisrupted ? '#DC2626' : '#2563EB';

    const busIconHtml = `
      <div class="transit-bus-marker-container">
        <div class="transit-bus-pill" style="background-color: ${pillBg};">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor">
            <path d="M4 16c0 .88.39 1.67 1 2.22V20a1 1 0 001 1h1a1 1 0 001-1v-1h8v1a1 1 0 001 1h1a1 1 0 001-1v-1.78c.61-.55 1-1.34 1-2.22V6c0-3.5-3.58-4-8-4s-8 .5-8 4v10zm3.5 1c-.83 0-1.5-.67-1.5-1.5S6.67 14 7.5 14s1.5.67 1.5 1.5S8.33 17 7.5 17zm9 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm1.5-6H6V6h12v5z"/>
          </svg>
          <span>${bus.operator} ${bus.routeNumber}</span>
        </div>
        <span class="transit-bus-badge">${badgeText}</span>
      </div>
    `;

    const icon = L.divIcon({
      className: 'custom-bus-icon',
      html: busIconHtml,
      iconSize: [80, 42],
      iconAnchor: [40, 21],
    });

    if (!busMarkerRef.current) {
      busMarkerRef.current = L.marker(busLatLng, { icon, zIndexOffset: 1000 }).addTo(map);
    } else {
      busMarkerRef.current.setIcon(icon);
      busMarkerRef.current.setLatLng(busLatLng);
    }

    // Follow bus camera
    if (followBus && map) {
      map.panTo(busLatLng, { animate: true, duration: 0.8 });
    }
  }, [bus, followBus]);

  // Update User Location Marker
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    if (!userLocation) {
      if (userMarkerRef.current) {
        userMarkerRef.current.remove();
        userMarkerRef.current = null;
      }
      return;
    }

    const icon = L.divIcon({
      className: 'custom-user-icon',
      html: `<div class="user-location-marker"></div>`,
      iconSize: [16, 16],
      iconAnchor: [8, 8],
    });

    if (!userMarkerRef.current) {
      userMarkerRef.current = L.marker([userLocation.latitude, userLocation.longitude], {
        icon,
        zIndexOffset: 500,
      }).addTo(map);
    } else {
      userMarkerRef.current.setLatLng([userLocation.latitude, userLocation.longitude]);
    }
  }, [userLocation]);

  return (
    <div className="relative w-full overflow-hidden" style={{ height }}>
      <div ref={containerRef} className="w-full h-full" />
    </div>
  );
}
