import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTransit } from '../context/TransitContext';

type DriverState = 'active' | 'confirm-breakdown' | 'breakdown-reported' | 'deviation';

export default function DriverMode() {
  const navigate = useNavigate();
  const [state, setState] = useState<DriverState>('active');
  const [tripStatus, setTripStatus] = useState('Running');

  const {
    selectedRoute,
    busState,
    driverModeActive,
    startDriverTrip,
    endDriverTrip,
    reportDriverBreakdown,
    triggerDetour,
  } = useTransit();

  const nextStop = selectedRoute.stops.find((s) => s.id === busState?.nextStopId);

  // Breakdown Confirmation Screen
  if (state === 'confirm-breakdown') {
    return (
      <div className="flex flex-col min-h-screen bg-white px-6">
        <div className="flex-1 flex flex-col justify-center items-center text-center">
          <div className="w-16 h-16 rounded-full bg-red-50 border border-red-100 flex items-center justify-center mb-6">
            <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
              <path d="M12 9v4M12 17h.01" stroke="#DC2626" strokeWidth="2" strokeLinecap="round" />
              <path
                d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"
                stroke="#DC2626"
                strokeWidth="2"
              />
            </svg>
          </div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Confirm bus breakdown?</h2>
          <p className="text-sm text-slate-500 mb-8">
            This will immediately publish a <b>CONFIRMED SERVICE DISRUPTION</b> alert to all passengers on this route and notify transit dispatch.
          </p>
          <div className="w-full flex flex-col gap-3">
            <button
              onClick={() => {
                reportDriverBreakdown();
                setState('breakdown-reported');
              }}
              className="w-full bg-red-600 hover:bg-red-700 text-white font-semibold text-sm py-4 rounded-xl shadow-sm transition-colors"
            >
              Confirm Breakdown
            </button>
            <button
              onClick={() => setState('active')}
              className="w-full border border-slate-200 text-slate-600 font-medium text-sm py-4 rounded-xl hover:bg-slate-50 transition-colors"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Breakdown Reported Screen
  if (state === 'breakdown-reported') {
    return (
      <div className="flex flex-col min-h-screen bg-white px-6">
        <div className="flex-1 flex flex-col justify-center items-center text-center">
          <div className="w-16 h-16 rounded-full bg-red-50 border border-red-100 flex items-center justify-center mb-6 text-2xl">
            🔴
          </div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Breakdown Confirmed</h2>
          <p className="text-sm text-slate-500 mb-2">
            Passengers on {selectedRoute.operator} {selectedRoute.routeNumber} have been alerted with high priority.
          </p>
          <p className="text-xs text-slate-400 mb-8">
            Depot assistance dispatch ticket #BK-5082 generated.
          </p>
          <div className="w-full bg-red-50 border border-red-100 rounded-xl p-4 mb-6 text-left">
            <p className="text-xs font-semibold text-red-700">
              {selectedRoute.operator} {selectedRoute.routeNumber} — Disruption Active
            </p>
            <p className="text-xs text-red-600 mt-1">
              Last GPS position: {nextStop?.name || 'Majiwada'} vicinity
            </p>
          </div>
          <button
            onClick={() => {
              navigate('/home');
            }}
            className="w-full bg-slate-800 hover:bg-slate-900 text-white font-semibold text-sm py-4 rounded-xl transition-colors"
          >
            Return to Home
          </button>
        </div>
      </div>
    );
  }

  // Route Deviation Screen
  if (state === 'deviation') {
    return (
      <div className="flex flex-col min-h-screen bg-white px-6">
        <div className="flex-1 flex flex-col justify-center items-center text-center">
          <div className="w-16 h-16 rounded-full bg-amber-50 border border-amber-100 flex items-center justify-center mb-6 text-2xl">
            🔀
          </div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Route Detour Required?</h2>
          <p className="text-sm text-slate-500 mb-8">
            Confirm detour to notify passengers that this bus is temporarily routing via Pokhran Road diversion.
          </p>
          <div className="w-full flex flex-col gap-3">
            <button
              onClick={() => {
                triggerDetour(true);
                setState('active');
                setTripStatus('Detour active');
              }}
              className="w-full bg-amber-500 hover:bg-amber-600 text-white font-semibold text-sm py-4 rounded-xl shadow-sm transition-colors"
            >
              Confirm Detour
            </button>
            <button
              onClick={() => {
                triggerDetour(false);
                setState('active');
              }}
              className="w-full border border-slate-200 text-slate-600 font-medium text-sm py-4 rounded-xl hover:bg-slate-50 transition-colors"
            >
              Stay on Standard Route
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC]">
      {/* Driver Header */}
      <div className="bg-slate-800 text-white px-4 pt-12 pb-5">
        <div className="flex items-center justify-between mb-4">
          <button
            onClick={() => navigate('/home')}
            className="p-1.5 rounded-lg text-slate-400 hover:text-white"
            aria-label="Back"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
            </svg>
          </button>
          <span className="text-sm font-semibold text-slate-300">Driver Mode</span>
          <div className="w-8" />
        </div>

        <div className="flex items-start justify-between">
          <div>
            <p className="text-xs text-slate-400">Assigned Route</p>
            <h1 className="text-2xl font-bold text-white">
              {selectedRoute.operator} {selectedRoute.routeNumber}
            </h1>
            <p className="text-xs text-slate-400 mt-0.5">{selectedRoute.name}</p>
          </div>
          <div className="text-right">
            {driverModeActive ? (
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 bg-green-700 rounded-lg text-xs font-semibold text-green-100">
                <span className="w-1.5 h-1.5 rounded-full bg-green-300 animate-pulse" />
                TRIP ACTIVE
              </span>
            ) : (
              <span className="inline-flex items-center px-2.5 py-1 bg-slate-700 rounded-lg text-xs font-semibold text-slate-300">
                STANDBY
              </span>
            )}
            <p className="text-xs text-slate-400 mt-2">{tripStatus}</p>
          </div>
        </div>
      </div>

      <div className="px-4 py-5 flex flex-col gap-3">
        {/* Current Trip telemetry */}
        <div className="bg-white border border-slate-200 rounded-xl p-4 flex items-center justify-between shadow-sm">
          <div>
            <p className="text-xs text-slate-400">Next scheduled stop</p>
            <p className="text-sm font-semibold text-slate-800">
              {nextStop?.name || 'Majiwada'}
            </p>
          </div>
          <div className="text-right">
            <p className="text-xs text-slate-400">Telemetry Source</p>
            <p className="text-sm font-semibold text-blue-600">
              {driverModeActive ? 'DRIVER GPS (Verified)' : 'Passenger Crowd'}
            </p>
          </div>
        </div>

        {/* Start / Stop Trip Toggle */}
        {!driverModeActive ? (
          <button
            onClick={() => {
              startDriverTrip();
              setTripStatus('Running');
            }}
            className="w-full bg-green-600 hover:bg-green-700 text-white font-bold text-sm py-4 rounded-xl shadow-md transition-colors flex items-center justify-center gap-2"
          >
            <span>▶️</span> Start Trip (Broadcast Driver GPS)
          </button>
        ) : (
          <div className="bg-green-50 border border-green-200 rounded-xl p-3 text-xs text-green-800 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-green-600 animate-ping" />
            <span>Driver telemetry active. Passenger LiveMap is synced to your trip.</span>
          </div>
        )}

        <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-wider mt-2">
          Driver Controls
        </h2>

        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={() => setState('confirm-breakdown')}
            className="bg-white hover:bg-red-50 border border-red-200 text-red-600 font-semibold text-sm py-4 rounded-xl flex flex-col items-center gap-1.5 shadow-sm transition-colors"
          >
            <span className="text-xl">🔴</span>
            Report Breakdown
          </button>
          <button
            onClick={() => setTripStatus('Temporary stop')}
            className="bg-white hover:bg-amber-50 border border-amber-200 text-amber-700 font-semibold text-sm py-4 rounded-xl flex flex-col items-center gap-1.5 shadow-sm transition-colors"
          >
            <span className="text-xl">⏸</span>
            Temporary Stop
          </button>
          <button
            onClick={() => setState('deviation')}
            className="bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 font-semibold text-sm py-4 rounded-xl flex flex-col items-center gap-1.5 shadow-sm transition-colors"
          >
            <span className="text-xl">🔀</span>
            Route Blocked / Detour
          </button>
          <button
            onClick={() => {
              setTripStatus('Running');
              triggerDetour(false);
            }}
            className="bg-white hover:bg-green-50 border border-green-200 text-green-700 font-semibold text-sm py-4 rounded-xl flex flex-col items-center gap-1.5 shadow-sm transition-colors"
          >
            <span className="text-xl">▶️</span>
            Resume Standard
          </button>
        </div>

        {/* View on LiveMap shortcut */}
        <button
          onClick={() => navigate('/live-map')}
          className="w-full border border-blue-200 bg-blue-50 hover:bg-blue-100 text-blue-600 font-semibold text-sm py-3.5 rounded-xl transition-colors mt-1"
        >
          Inspect Live Passenger Map
        </button>

        {driverModeActive && (
          <button
            onClick={() => {
              endDriverTrip();
              setTripStatus('Trip ended');
            }}
            className="w-full border border-slate-300 text-slate-700 hover:bg-slate-100 font-semibold text-sm py-3.5 rounded-xl bg-white transition-colors"
          >
            End Trip
          </button>
        )}
      </div>
    </div>
  );
}
