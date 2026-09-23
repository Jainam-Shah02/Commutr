import { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import StatusBadge from '../components/StatusBadge';
import BottomNav from '../components/BottomNav';
import { useTransit } from '../context/TransitContext';

export default function SearchResults() {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('50');

  const { selectedRoute, busState, serviceStatus } = useTransit();

  const nextStop = selectedRoute.stops.find((s) => s.id === busState?.nextStopId);

  // Available routes for search
  const routesData = useMemo(
    () => [
      {
        id: selectedRoute.id,
        routeId: 'tmt-50',
        no: `${selectedRoute.operator} ${selectedRoute.routeNumber}`,
        route: selectedRoute.name,
        destination: selectedRoute.destination,
        origin: selectedRoute.origin,
        stops: selectedRoute.stops.map((s) => s.name),
        status: (serviceStatus === 'CONFIRMED_DISRUPTION'
          ? 'CONFIRMED DISRUPTION'
          : busState
          ? 'LIVE'
          : 'SCHEDULED') as 'LIVE' | 'SCHEDULED' | 'CONFIRMED DISRUPTION',
        eta: busState ? `${busState.etaMinutes} min` : '10:25 AM',
        nextStop: nextStop?.name || 'Majiwada',
        confidence: busState ? busState.confidence : null,
      },
      {
        id: 'tmt2-1',
        routeId: 'tmt-2',
        no: 'TMT 2',
        route: 'Thane Station West → Balkum',
        destination: 'Balkum',
        origin: 'Thane Station West',
        stops: ['Thane Station West', 'Panchpakhadi', 'Majiwada Junction', 'Balkum Naka'],
        status: 'SCHEDULED' as const,
        eta: '10:35 AM',
        nextStop: null,
        confidence: null,
      },
      {
        id: 'tmt1-1',
        routeId: 'tmt-1',
        no: 'TMT 1',
        route: 'Thane Station West → Wagle Naka',
        destination: 'Wagle Naka',
        origin: 'Thane Station West',
        stops: ['Thane Station West', 'Teen Hath Naka', 'Wagle Circle', 'Wagle Naka'],
        status: 'SCHEDULED' as const,
        eta: '10:50 AM',
        nextStop: null,
        confidence: null,
      },
    ],
    [selectedRoute, busState, serviceStatus, nextStop]
  );

  // Filter based on input search term
  const filteredResults = useMemo(() => {
    if (!searchTerm.trim()) return routesData;
    const term = searchTerm.toLowerCase();
    return routesData.filter(
      (r) =>
        r.no.toLowerCase().includes(term) ||
        r.route.toLowerCase().includes(term) ||
        r.destination.toLowerCase().includes(term) ||
        r.origin.toLowerCase().includes(term) ||
        r.stops.some((s) => s.toLowerCase().includes(term))
    );
  }, [searchTerm, routesData]);

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-4">
        <div className="flex items-center gap-2 mb-3">
          <button
            onClick={() => navigate(-1)}
            className="p-1.5 rounded-lg text-slate-500 hover:bg-slate-100"
            aria-label="Back"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
            </svg>
          </button>
          <div className="flex-1 flex items-center gap-2 bg-slate-100 rounded-xl px-3 py-2">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
              <circle cx="11" cy="11" r="7" stroke="#94A3B8" strokeWidth="2" />
              <path d="M16.5 16.5l4 4" stroke="#94A3B8" strokeWidth="2" strokeLinecap="round" />
            </svg>
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search bus, route, stop or destination..."
              className="bg-transparent text-sm text-slate-800 placeholder-slate-400 w-full outline-none font-medium"
              autoFocus
            />
            {searchTerm && (
              <button
                onClick={() => setSearchTerm('')}
                className="text-slate-400 hover:text-slate-600 text-xs font-bold"
              >
                ✕
              </button>
            )}
          </div>
        </div>
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-semibold text-slate-800">
            {filteredResults.length} {filteredResults.length === 1 ? 'route' : 'routes'} found
          </h2>
          <span className="text-xs text-slate-400">Live + Scheduled</span>
        </div>
      </div>

      <div className="px-4 py-4 flex flex-col gap-3">
        {filteredResults.map((r) => (
          <div
            key={r.id}
            className="w-full bg-white border border-slate-200 rounded-xl p-4 text-left shadow-sm hover:border-blue-300 transition-colors"
          >
            <div
              onClick={() => navigate(`/bus/${r.routeId}`)}
              className="cursor-pointer"
            >
              <div className="flex items-start justify-between mb-2">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-base font-bold text-slate-900">{r.no}</span>
                    <StatusBadge status={r.status} />
                  </div>
                  <p className="text-xs text-slate-500 mt-0.5">{r.route}</p>
                </div>
                <div className="text-right">
                  <p className="text-xl font-bold text-blue-600">{r.eta}</p>
                  <p className="text-[10px] text-slate-400">
                    {r.status === 'LIVE' ? 'Estimated arrival' : 'Scheduled'}
                  </p>
                </div>
              </div>

              {r.nextStop && (
                <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-100">
                  <div className="flex items-center gap-1.5">
                    <div className="w-1.5 h-1.5 rounded-full bg-blue-500" />
                    <span className="text-xs text-slate-500">
                      Next stop: <span className="text-slate-700 font-medium">{r.nextStop}</span>
                    </span>
                  </div>
                  {r.confidence && (
                    <span className="text-[10px] text-green-700 font-medium bg-green-50 px-2 py-0.5 rounded">
                      {r.confidence}
                    </span>
                  )}
                </div>
              )}
            </div>

            <div className="flex gap-2 mt-3 pt-2 border-t border-slate-100">
              <button
                onClick={() => navigate(`/bus/${r.routeId}`)}
                className="flex-1 text-xs font-semibold py-2 px-3 bg-slate-100 text-slate-700 rounded-lg hover:bg-slate-200 transition-colors text-center"
              >
                Bus Details
              </button>
              {r.status === 'LIVE' && (
                <button
                  onClick={() => navigate('/live-map')}
                  className="flex-1 text-xs font-semibold py-2 px-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-center flex items-center justify-center gap-1"
                >
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                    <path d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l5.447 2.724A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                  View Live Map
                </button>
              )}
            </div>
          </div>
        ))}

        {filteredResults.length === 0 && (
          <div className="bg-white border border-slate-200 rounded-xl p-8 text-center">
            <p className="text-sm font-semibold text-slate-800 mb-1">No matching routes</p>
            <p className="text-xs text-slate-400">
              Try searching "50", "Manpada", "Cadbury", or "Thane"
            </p>
          </div>
        )}
      </div>

      <BottomNav />
    </div>
  );
}
