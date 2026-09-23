import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import StatusBadge from '../components/StatusBadge';
import BottomNav from '../components/BottomNav';
import { useTransit } from '../context/TransitContext';

export default function StopDetails() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [notified, setNotified] = useState<string | null>(null);

  const { selectedRoute, busState } = useTransit();

  // Find stop in current route by id or fallback to first stop
  const currentStop =
    selectedRoute.stops.find((s) => s.id === id) ||
    selectedRoute.stops.find((s) => s.name.toLowerCase().includes(id?.toLowerCase() || '')) ||
    selectedRoute.stops[0];

  const stopIndex = selectedRoute.stops.findIndex((s) => s.id === currentStop.id);
  const isCurrentBusStop = busState?.currentStopId === currentStop.id;

  // Dynamic upcoming buses for this stop
  const busesAtStop = [
    {
      no: `${selectedRoute.operator} ${selectedRoute.routeNumber}`,
      dest: selectedRoute.destination,
      status: busState ? ('LIVE' as const) : ('SCHEDULED' as const),
      eta: busState
        ? isCurrentBusStop
          ? 'At stop'
          : `${busState.etaMinutes} min`
        : '10:25 AM',
      confidence: busState ? busState.confidence : null,
      routeId: selectedRoute.id,
    },
    {
      no: 'TMT 2',
      dest: 'Balkum Naka',
      status: 'SCHEDULED' as const,
      eta: '10:35 AM',
      confidence: null,
      routeId: 'tmt-2',
    },
    {
      no: 'TMT 1',
      dest: 'Wagle Naka',
      status: 'SCHEDULED' as const,
      eta: '10:50 AM',
      confidence: null,
      routeId: 'tmt-1',
    },
  ];

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-4">
        <div className="flex items-center gap-2">
          <button
            onClick={() => navigate(-1)}
            className="p-1.5 -ml-1.5 rounded-lg text-slate-500 hover:bg-slate-100"
            aria-label="Back"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
            </svg>
          </button>
          <div className="flex-1">
            <h1 className="text-xl font-bold text-slate-900">{currentStop.name}</h1>
            <p className="text-xs text-slate-400">
              Stop #{stopIndex + 1} on {selectedRoute.operator} {selectedRoute.routeNumber} · Thane
            </p>
          </div>
          <button
            onClick={() => navigate('/live-map')}
            className="text-xs bg-blue-50 text-blue-600 border border-blue-200 px-2.5 py-1.5 rounded-lg font-semibold"
          >
            View on Map
          </button>
        </div>
      </div>

      <div className="px-4 py-4 flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
            Upcoming buses
          </h2>
          <span className="text-[10px] text-slate-400">Auto-refreshed</span>
        </div>

        {busesAtStop.map((bus) => (
          <div key={bus.no + bus.dest} className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-2 mb-0.5">
                  <span className="text-sm font-bold text-slate-900">{bus.no}</span>
                  <StatusBadge status={bus.status} />
                </div>
                <p className="text-xs text-slate-500">To {bus.dest}</p>
                {bus.confidence && (
                  <p className="text-[10px] text-green-700 font-medium mt-1 bg-green-50 px-1.5 py-0.5 rounded inline-block">
                    {bus.confidence}
                  </p>
                )}
              </div>
              <div className="text-right">
                <p className="text-xl font-bold text-blue-600">{bus.eta}</p>
                <div className="flex items-center gap-1.5 mt-1.5 justify-end">
                  {bus.status === 'LIVE' && (
                    <button
                      onClick={() => navigate('/live-map')}
                      className="text-xs px-2 py-1 rounded-lg font-medium bg-blue-600 text-white"
                    >
                      Track
                    </button>
                  )}
                  <button
                    onClick={() => setNotified(bus.no)}
                    className={`text-xs px-2.5 py-1 rounded-lg font-medium transition-colors ${
                      notified === bus.no
                        ? 'bg-green-50 text-green-700 border border-green-200'
                        : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
                    }`}
                  >
                    {notified === bus.no ? '✓ Set' : 'Notify'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}

        {/* Informational card */}
        <div className="bg-slate-50 border border-slate-200 rounded-xl p-4 mt-1">
          <p className="text-xs font-semibold text-slate-700 mb-1">How Live vs Scheduled Works</p>
          <p className="text-xs text-slate-500 leading-relaxed">
            Live ETA is computed when GPS signals from passengers or drivers are verified. When buses are still in depot or between shifts, scheduled timetable times are displayed.
          </p>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
