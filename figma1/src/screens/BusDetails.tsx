import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import StatusBadge from '../components/StatusBadge';
import BottomNav from '../components/BottomNav';
import { useTransit } from '../context/TransitContext';

export default function BusDetails() {
  const navigate = useNavigate();
  const [notified, setNotified] = useState(false);

  const { selectedRoute, busState, trackingSource, serviceStatus } = useTransit();

  const currentStopIndex = selectedRoute.stops.findIndex((s) => s.id === busState?.currentStopId);
  const currentStop = selectedRoute.stops[currentStopIndex >= 0 ? currentStopIndex : 0];
  const nextStop = selectedRoute.stops.find((s) => s.id === busState?.nextStopId);

  const getStopStatus = (index: number) => {
    if (index === selectedRoute.stops.length - 1) return 'destination';
    if (!busState) return 'scheduled';
    if (index === currentStopIndex) return 'current';
    if (index < currentStopIndex) return 'passed';
    return 'upcoming';
  };

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-4">
        <div className="flex items-center gap-2 mb-3">
          <button
            onClick={() => navigate(-1)}
            className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100 transition-colors"
            aria-label="Back"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
            </svg>
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">
                {selectedRoute.operator} {selectedRoute.routeNumber}
              </h1>
              <StatusBadge
                status={
                  serviceStatus === 'CONFIRMED_DISRUPTION'
                    ? 'CONFIRMED DISRUPTION'
                    : !busState
                    ? 'LIMITED DATA'
                    : 'LIVE'
                }
              />
            </div>
            <p className="text-xs text-slate-500">{selectedRoute.name}</p>
          </div>
        </div>
      </div>

      <div className="px-4 py-4 flex flex-col gap-4">
        {/* ETA & Status Card */}
        {busState ? (
          <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm">
            <div className="flex items-center justify-between mb-3">
              <div>
                <p className="text-xs text-slate-500 font-medium">Estimated arrival</p>
                <p className="text-3xl font-bold text-blue-600">
                  {serviceStatus === 'CONFIRMED_DISRUPTION' ? 'Delayed' : `${busState.etaMinutes} min`}
                </p>
              </div>
              <div className="text-right">
                <p className="text-xs text-slate-500">Current area</p>
                <p className="text-sm font-semibold text-slate-800">
                  {currentStop?.name || 'Majiwada'}
                </p>
                {nextStop && (
                  <p className="text-[10px] text-blue-600 mt-0.5">Next: {nextStop.name}</p>
                )}
              </div>
            </div>

            <div className="flex items-center gap-2 pt-2 border-t border-slate-100">
              <span className="text-[10px] font-semibold bg-green-50 text-green-700 px-2 py-0.5 rounded">
                {busState.confidence}
              </span>
              <span className="text-[10px] text-slate-400">
                Updated {busState.lastUpdatedSec} sec ago
              </span>
              <span className="text-[10px] text-slate-500 ml-auto font-medium">
                {busState.occupancy} occupancy
              </span>
            </div>
          </div>
        ) : (
          <div className="bg-white border border-amber-200 rounded-xl p-4 shadow-sm">
            <div className="flex items-center gap-2 text-amber-800 font-semibold text-sm mb-1">
              <span className="text-base">⚠️</span>
              <span>Live bus location currently unavailable</span>
            </div>
            <p className="text-xs text-slate-500 mb-3">
              Scheduled departure: 10:25 AM from Thane Station West. Live tracking activates when passengers or driver share telemetry.
            </p>
            <button
              onClick={() => navigate(`/route/${selectedRoute.id}`)}
              className="text-xs text-blue-600 font-semibold underline"
            >
              View scheduled timetable
            </button>
          </div>
        )}

        {/* Route progress */}
        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Route Progress
            </h3>
            {busState && (
              <span className="text-[10px] font-semibold text-blue-600">
                {busState.progressPercent}% completed
              </span>
            )}
          </div>

          <div className="flex flex-col gap-0">
            {selectedRoute.stops.map((stop, i) => {
              const status = getStopStatus(i);
              return (
                <div key={stop.id} className="flex items-start gap-3">
                  <div className="flex flex-col items-center">
                    <div
                      className={`w-3.5 h-3.5 rounded-full border-2 flex-shrink-0 mt-0.5 ${
                        status === 'current'
                          ? 'border-blue-600 bg-blue-600 shadow-sm'
                          : status === 'passed'
                          ? 'border-slate-300 bg-slate-300'
                          : status === 'destination'
                          ? 'border-red-500 bg-white'
                          : 'border-slate-300 bg-white'
                      }`}
                    />
                    {i < selectedRoute.stops.length - 1 && (
                      <div
                        className={`w-0.5 h-7 ${
                          status === 'passed' ? 'bg-slate-300' : 'bg-slate-200'
                        }`}
                      />
                    )}
                  </div>
                  <div className="pb-3 flex-1 flex items-center justify-between">
                    <div>
                      <p
                        className={`text-sm font-medium ${
                          status === 'current'
                            ? 'text-blue-600 font-bold'
                            : status === 'passed'
                            ? 'text-slate-400'
                            : status === 'destination'
                            ? 'text-red-500 font-semibold'
                            : 'text-slate-700'
                        }`}
                      >
                        {stop.name}
                      </p>
                      {status === 'current' && (
                        <p className="text-[10px] text-blue-500 font-medium">Bus estimated near here</p>
                      )}
                      {status === 'destination' && (
                        <p className="text-[10px] text-red-400">Route terminal destination</p>
                      )}
                    </div>
                    <button
                      onClick={() => navigate(`/stop/${stop.id}`)}
                      className="text-[11px] text-slate-400 hover:text-blue-600"
                    >
                      View
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Confidence Explanation */}
        <div className="bg-slate-50 border border-slate-200 rounded-xl p-3.5">
          <p className="text-xs font-semibold text-slate-700 mb-1">Data Quality & Privacy</p>
          <p className="text-xs text-slate-500 leading-relaxed">
            {trackingSource === 'DRIVER'
              ? 'Real-time telemetry directly synced from driver navigation terminal.'
              : 'Aggregated from verified passenger location telemetry. Individual passenger locations are never revealed.'}
          </p>
        </div>

        {/* Primary Actions */}
        <div className="flex gap-3">
          <button
            onClick={() => navigate('/live-map')}
            className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm py-3.5 rounded-xl shadow-sm transition-colors flex items-center justify-center gap-1.5"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <path d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l5.447 2.724A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            View Live Map
          </button>
          <button
            onClick={() => setNotified(!notified)}
            className={`flex-1 border font-semibold text-sm py-3.5 rounded-xl transition-colors ${
              notified
                ? 'bg-green-50 text-green-700 border-green-200'
                : 'border-blue-200 text-blue-600 bg-blue-50 hover:bg-blue-100'
            }`}
          >
            {notified ? '✓ Notified' : 'Notify Me'}
          </button>
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => navigate('/board')}
            className="flex-1 border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-medium text-xs py-2.5 rounded-xl"
          >
            Board & Share
          </button>
          <button
            onClick={() => navigate('/report-problem')}
            className="flex-1 border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 font-medium text-xs py-2.5 rounded-xl"
          >
            Report Problem
          </button>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
