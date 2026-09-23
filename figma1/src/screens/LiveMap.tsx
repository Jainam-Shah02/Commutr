import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import StatusBadge from '../components/StatusBadge';
import BottomNav from '../components/BottomNav';
import TransitMap from '../components/TransitMap';
import { useTransit } from '../context/TransitContext';
import { TransitStop } from '../services/transitData';

export default function LiveMap() {
  const navigate = useNavigate();
  const [notified, setNotified] = useState(false);

  const {
    selectedRoute,
    busState,
    activePolyline,
    userLocation,
    destinationStopId,
    followBus,
    setFollowBus,
    serviceStatus,
    trackingSource,
  } = useTransit();

  // Find next stop object from route
  const nextStopObj = selectedRoute.stops.find((s) => s.id === busState?.nextStopId);
  const currentStopObj = selectedRoute.stops.find((s) => s.id === busState?.currentStopId);

  // List of upcoming stops after current stop
  const currentStopIndex = selectedRoute.stops.findIndex((s) => s.id === busState?.currentStopId);
  const upcomingStops = selectedRoute.stops.slice(
    Math.max(0, currentStopIndex >= 0 ? currentStopIndex + 1 : 1)
  );

  const handleStopSelect = (stop: TransitStop) => {
    navigate(`/stop/${stop.id}`);
  };

  const getOccupancyLabel = (occ?: 'LOW' | 'MODERATE' | 'HIGH') => {
    switch (occ) {
      case 'LOW':
        return 'Seats likely available';
      case 'MODERATE':
        return 'Some seats available';
      case 'HIGH':
        return 'Standing room likely';
      default:
        return 'Moderate occupancy';
    }
  };

  const getBadgeStatus = () => {
    if (serviceStatus === 'CONFIRMED_DISRUPTION') return 'CONFIRMED DISRUPTION';
    if (serviceStatus === 'POSSIBLE_DISRUPTION') return 'POSSIBLE DISRUPTION';
    if (!busState || trackingSource === 'NO_LIVE_DATA') return 'LIMITED DATA';
    if (trackingSource === 'SCHEDULED') return 'SCHEDULED';
    return 'LIVE';
  };

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC]">
      {/* Real Map Area */}
      <div className="relative flex-1 min-h-[380px] bg-slate-100">
        {/* Header overlay */}
        <div className="absolute top-0 left-0 right-0 pt-12 px-4 z-[500] pointer-events-none">
          <div className="flex items-center gap-2 pointer-events-auto">
            <button
              onClick={() => navigate(-1)}
              className="p-2 bg-white rounded-xl shadow-md border border-slate-200 text-slate-700 hover:bg-slate-50 transition-colors"
              aria-label="Back"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              </svg>
            </button>

            <div className="flex-1 bg-white rounded-xl shadow-md border border-slate-200 px-3.5 py-2">
              <div className="flex items-center gap-2">
                <span className="text-sm font-bold text-slate-900">
                  {selectedRoute.operator} {selectedRoute.routeNumber}
                </span>
                <StatusBadge status={getBadgeStatus()} />
                <span className="text-[11px] text-slate-400 ml-auto">
                  {busState ? `Updated ${busState.lastUpdatedSec}s ago` : 'Live unavailable'}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Real Interactive Leaflet Map */}
        <TransitMap
          route={selectedRoute}
          bus={busState}
          stops={selectedRoute.stops}
          userLocation={userLocation}
          destinationStopId={destinationStopId}
          followBus={followBus}
          onStopSelect={handleStopSelect}
          activePolyline={activePolyline}
          serviceStatus={serviceStatus}
          height="100%"
        />

        {/* Floating Map Controls */}
        <div className="absolute top-28 right-3 flex flex-col gap-2 z-[500]">
          {/* Center / Follow Bus Button */}
          {busState && (
            <button
              onClick={() => setFollowBus(!followBus)}
              className={`p-2.5 rounded-xl shadow-md border transition-all flex items-center justify-center ${
                followBus
                  ? 'bg-blue-600 text-white border-blue-700'
                  : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
              }`}
              title={followBus ? 'Following Bus (Click to free pan)' : 'Center on Bus'}
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="7" stroke="currentColor" strokeWidth="2" />
                <circle cx="12" cy="12" r="3" fill="currentColor" />
                <path d="M12 2v3M12 19v3M2 12h3M19 12h3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              </svg>
            </button>
          )}

          {/* Recenter / Fit Route Button */}
          <button
            onClick={() => {
              setFollowBus(false);
              // Trigger a small resize or fit
              window.dispatchEvent(new Event('resize'));
            }}
            className="p-2.5 bg-white rounded-xl shadow-md border border-slate-200 text-slate-700 hover:bg-slate-50 transition-colors"
            title="Reset Map View"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <path d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
        </div>

        {/* Legend */}
        <div className="absolute bottom-3 right-3 bg-white/95 backdrop-blur-sm border border-slate-200 rounded-xl px-2.5 py-2 shadow-sm z-[500] text-[10px] text-slate-600 flex flex-col gap-1">
          <div className="flex items-center gap-1.5">
            <div className="w-3 h-1 bg-blue-600 rounded" />
            <span>Route</span>
          </div>
          {serviceStatus === 'DETOUR' && (
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-1 bg-slate-400 rounded" style={{ borderTop: '1px dashed' }} />
              <span>Original route</span>
            </div>
          )}
          <div className="flex items-center gap-1.5">
            <div className="w-2.5 h-2.5 rounded-full bg-blue-600 border border-white" />
            <span>Bus Live</span>
          </div>
          <div className="flex items-center gap-1.5">
            <div className="w-2.5 h-2.5 rounded-full bg-white border-2 border-blue-600" />
            <span>Stop</span>
          </div>
        </div>
      </div>

      {/* Disruption / Detour Notification Banner */}
      {serviceStatus === 'CONFIRMED_DISRUPTION' && (
        <div className="bg-red-600 text-white px-4 py-3 flex items-start gap-3">
          <span className="text-xl">🔴</span>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider">Confirmed Service Disruption</p>
            <p className="text-xs text-red-100 mt-0.5">
              Bus breakdown confirmed by operator near {currentStopObj?.name || 'Majiwada'}. Expect significant delays or take alternate routes.
            </p>
          </div>
        </div>
      )}

      {serviceStatus === 'POSSIBLE_DISRUPTION' && (
        <div className="bg-amber-500 text-white px-4 py-3 flex items-start gap-3">
          <span className="text-xl">⚠️</span>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider">Possible Service Disruption</p>
            <p className="text-xs text-amber-100 mt-0.5">
              Unusual long stop detected outside normal schedule. Awaiting operator confirmation.
            </p>
          </div>
        </div>
      )}

      {serviceStatus === 'DETOUR' && (
        <div className="bg-blue-700 text-white px-4 py-2.5 flex items-center gap-2.5">
          <span className="text-base">🔀</span>
          <p className="text-xs font-medium">
            Temporary route active: this bus is following an alternate path.
          </p>
        </div>
      )}

      {/* Bottom Info Sheet */}
      <div className="bg-white border-t border-slate-200 px-4 pt-4 pb-24 shadow-lg">
        {busState ? (
          <>
            <div className="flex items-start justify-between mb-3">
              <div>
                <div className="flex items-center gap-2 mb-0.5">
                  <span className="text-base font-bold text-slate-900">
                    {selectedRoute.operator} {selectedRoute.routeNumber}
                  </span>
                  <StatusBadge status={getBadgeStatus()} />
                </div>
                <p className="text-xs text-slate-500">{selectedRoute.name}</p>
              </div>

              <div className="text-right">
                <p className="text-2xl font-bold text-blue-600">
                  {serviceStatus === 'CONFIRMED_DISRUPTION' ? 'Delayed' : `${busState.etaMinutes} min`}
                </p>
                <p className="text-[10px] text-slate-400">Estimated arrival</p>
              </div>
            </div>

            <div className="flex items-center gap-4 mb-3 pb-3 border-b border-slate-100">
              <div className="flex-1">
                <p className="text-[10px] text-slate-400">Next stop</p>
                <p className="text-sm font-semibold text-slate-800">
                  {nextStopObj?.name || 'Majiwada'}
                </p>
              </div>
              <div className="w-px h-8 bg-slate-200" />
              <div className="flex-1">
                <p className="text-[10px] text-slate-400">Data quality</p>
                <p className="text-sm font-semibold text-green-700">{busState.confidence}</p>
              </div>
              <div className="w-px h-8 bg-slate-200" />
              <div className="flex-1">
                <p className="text-[10px] text-slate-400">Occupancy</p>
                <p className="text-xs font-semibold text-slate-700">
                  {getOccupancyLabel(busState.occupancy)}
                </p>
              </div>
            </div>

            <p className="text-[10px] text-slate-400 mb-3">
              {trackingSource === 'DRIVER'
                ? 'Direct driver telemetry verified'
                : 'Based on multiple verified passenger signals'}
            </p>

            {/* Compact Upcoming Stops */}
            <div className="mb-4 bg-slate-50 border border-slate-200 rounded-xl p-3">
              <div className="flex items-center justify-between mb-2">
                <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider">
                  Upcoming Stops
                </span>
                <span className="text-[10px] text-blue-600 font-semibold">
                  {busState.progressPercent}% route completed
                </span>
              </div>
              <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
                {nextStopObj && (
                  <div className="flex items-center gap-1 bg-blue-100 text-blue-800 px-2 py-1 rounded-md text-xs font-semibold flex-shrink-0 border border-blue-200">
                    <span className="w-1.5 h-1.5 rounded-full bg-blue-600 animate-pulse" />
                    <span>Next: {nextStopObj.name}</span>
                  </div>
                )}
                {upcomingStops.slice(1, 4).map((s) => (
                  <div
                    key={s.id}
                    className="flex items-center gap-1 bg-white border border-slate-200 text-slate-600 px-2 py-1 rounded-md text-xs flex-shrink-0"
                  >
                    <span>{s.name}</span>
                  </div>
                ))}
              </div>
            </div>
          </>
        ) : (
          /* NO LIVE DATA STATE */
          <div className="mb-4">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-base font-bold text-slate-900">
                {selectedRoute.operator} {selectedRoute.routeNumber}
              </span>
              <StatusBadge status="LIMITED DATA" />
            </div>
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-3.5 mb-3">
              <div className="flex items-center gap-2 text-amber-800 font-semibold text-xs mb-1">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <path d="M12 9v4m0 4h.01M12 3a9 9 0 100 18 9 9 0 000-18z" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                </svg>
                <span>Live bus location is currently unavailable</span>
              </div>
              <p className="text-xs text-amber-700 leading-relaxed">
                No active passenger or driver signals on this route. Scheduled arrival times are shown below.
              </p>
            </div>
            <div className="flex justify-between text-xs py-2 border-b border-slate-100 text-slate-600">
              <span>Next scheduled departure:</span>
              <span className="font-semibold text-slate-800">10:25 AM (Thane West)</span>
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-3">
          <button
            onClick={() => setNotified(!notified)}
            className={`flex-1 font-semibold text-sm py-3 rounded-xl transition-colors ${
              notified
                ? 'bg-green-50 text-green-700 border border-green-200'
                : 'bg-blue-600 text-white hover:bg-blue-700'
            }`}
          >
            {notified ? '✓ Notification Set' : 'Notify Me'}
          </button>
          <button
            onClick={() => navigate(`/route/${selectedRoute.id}`)}
            className="flex-1 border border-slate-200 text-slate-700 hover:bg-slate-50 font-semibold text-sm py-3 rounded-xl transition-colors"
          >
            View Route
          </button>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
