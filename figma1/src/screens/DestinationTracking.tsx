import { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import BackHeader from '../components/BackHeader';
import StatusBadge from '../components/StatusBadge';
import { useTransit } from '../context/TransitContext';

type NotifyOption = '5min' | 'stop';

export default function DestinationTracking() {
  const navigate = useNavigate();
  const [notifyOption, setNotifyOption] = useState<NotifyOption>('5min');
  const [trackingActive, setTrackingActive] = useState(true);

  const { selectedRoute, busState, destinationStopId } = useTransit();

  // Find destination stop
  const destinationStop =
    selectedRoute.stops.find((s) => s.id === destinationStopId) ||
    selectedRoute.stops[selectedRoute.stops.length - 1];

  // Check if bus is approaching destination (within 1 stop of destination)
  const isApproaching = useMemo(() => {
    if (!busState) return false;
    const destIndex = selectedRoute.stops.findIndex((s) => s.id === destinationStop.id);
    const currentIndex = selectedRoute.stops.findIndex((s) => s.id === busState.currentStopId);
    return destIndex - currentIndex <= 1 && currentIndex >= 0;
  }, [busState, selectedRoute.stops, destinationStop.id]);

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC]">
      <BackHeader
        title="Track my destination"
        subtitle={`${selectedRoute.operator} ${selectedRoute.routeNumber} · ${destinationStop.name}`}
      />

      <div className="px-4 py-4 flex flex-col gap-4">
        {/* Approaching Alert Banner */}
        {isApproaching && trackingActive && (
          <div className="bg-blue-600 text-white rounded-xl p-4 flex items-center gap-3 shadow-md">
            <span className="text-2xl">🔔</span>
            <div>
              <p className="text-sm font-bold">Your stop is next</p>
              <p className="text-xs text-blue-100">
                Get ready — {destinationStop.name} is approaching.
              </p>
            </div>
          </div>
        )}

        {/* ETA Card */}
        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm">
          <div className="flex justify-between mb-3">
            <div>
              <p className="text-xs text-slate-400">Destination</p>
              <p className="text-base font-bold text-slate-900">{destinationStop.name}</p>
            </div>
            <div className="text-right">
              <p className="text-xs text-slate-400">Estimated arrival</p>
              <p className="text-2xl font-bold text-blue-600">
                {busState ? `${busState.etaMinutes} min` : '10:25 AM'}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2 pt-2 border-t border-slate-100">
            <StatusBadge status={busState ? 'LIVE' : 'SCHEDULED'} />
            <span className="text-xs text-slate-400">
              {busState ? busState.confidence : 'Scheduled service'}
            </span>
          </div>
        </div>

        {/* Route Progress */}
        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm">
          <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">
            Route progress to {destinationStop.name}
          </p>
          {selectedRoute.stops.map((stop, i) => {
            const currentIndex = selectedRoute.stops.findIndex((s) => s.id === busState?.currentStopId);
            const isDestination = stop.id === destinationStop.id;
            const isCurrent = stop.id === busState?.currentStopId;
            const isPassed = currentIndex >= 0 && i < currentIndex;

            return (
              <div key={stop.id} className="flex items-start gap-3">
                <div className="flex flex-col items-center">
                  <div
                    className={`w-3.5 h-3.5 rounded-full border-2 mt-0.5 flex-shrink-0 ${
                      isDestination
                        ? 'border-red-500 bg-white shadow-sm'
                        : isCurrent
                        ? 'bg-blue-600 border-blue-600 shadow-sm'
                        : isPassed
                        ? 'bg-slate-300 border-slate-300'
                        : 'bg-white border-slate-300'
                    }`}
                  />
                  {i < selectedRoute.stops.length - 1 && (
                    <div
                      className={`w-0.5 h-6 ${
                        isPassed ? 'bg-slate-200' : 'bg-blue-100'
                      }`}
                    />
                  )}
                </div>
                <div className="pb-3 flex-1">
                  <p
                    className={`text-sm ${
                      isDestination
                        ? 'text-red-600 font-bold'
                        : isCurrent
                        ? 'text-blue-600 font-semibold'
                        : isPassed
                        ? 'text-slate-400'
                        : 'text-slate-700'
                    }`}
                  >
                    {stop.name}
                  </p>
                  {isCurrent && <p className="text-[10px] text-blue-500">Bus here now</p>}
                  {isDestination && <p className="text-[10px] text-red-400">Alighting stop</p>}
                </div>
              </div>
            );
          })}
        </div>

        {/* Notification settings */}
        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm">
          <p className="text-xs font-semibold text-slate-700 mb-2.5">Notify me before my stop</p>
          <div className="flex gap-2">
            {[
              { val: '5min' as const, label: '5 min before' },
              { val: 'stop' as const, label: 'At approaching stop' },
            ].map((opt) => (
              <button
                key={opt.val}
                onClick={() => setNotifyOption(opt.val)}
                className={`flex-1 py-2.5 text-xs font-semibold rounded-lg border transition-colors ${
                  notifyOption === opt.val
                    ? 'border-blue-600 bg-blue-50 text-blue-700'
                    : 'border-slate-200 text-slate-600 hover:bg-slate-50'
                }`}
              >
                {opt.label}
              </button>
            ))}
          </div>
        </div>

        {/* Bottom Actions */}
        <div className="flex gap-3 mt-2">
          <button
            onClick={() => navigate('/live-map')}
            className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm py-3.5 rounded-xl shadow-sm transition-colors flex items-center justify-center gap-1.5"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <path d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l5.447 2.724A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            View on Live Map
          </button>
          <button
            onClick={() => navigate(-1)}
            className="flex-1 border border-slate-200 bg-white hover:bg-slate-50 text-slate-600 font-semibold text-sm py-3.5 rounded-xl transition-colors"
          >
            Done
          </button>
        </div>
      </div>
    </div>
  );
}
