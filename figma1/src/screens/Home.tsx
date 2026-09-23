import { useNavigate } from 'react-router-dom';
import BottomNav from '../components/BottomNav';
import StatusBadge from '../components/StatusBadge';
import { useTransit } from '../context/TransitContext';

export default function Home() {
  const navigate = useNavigate();
  const { selectedRoute, busState, serviceStatus } = useTransit();

  const nearbyStops = [
    { id: 'stop-1', name: 'Thane Station West', count: 4, time: '2 min walk' },
    { id: 'stop-5', name: 'Majiwada Junction', count: 3, time: '5 min walk' },
  ];

  const savedPlaces = [
    { label: 'Home', address: 'Ghodbunder Rd, Manpada' },
    { label: 'College', address: 'Cadbury Junction, Thane' },
  ];

  const popularRoutes = [
    {
      id: selectedRoute.id,
      no: `${selectedRoute.operator} ${selectedRoute.routeNumber}`,
      dest: selectedRoute.name,
      status: (serviceStatus === 'CONFIRMED_DISRUPTION'
        ? 'CONFIRMED DISRUPTION'
        : busState
        ? 'LIVE'
        : 'SCHEDULED') as 'LIVE' | 'SCHEDULED' | 'CONFIRMED DISRUPTION',
      eta: busState ? `${busState.etaMinutes} min` : '10:25 AM',
    },
    {
      id: 'tmt-2',
      no: 'TMT 2',
      dest: 'Thane Stn → Balkum',
      status: 'SCHEDULED' as const,
      eta: '10:35 AM',
    },
    {
      id: 'tmt-1',
      no: 'TMT 1',
      dest: 'Thane Stn → Wagle Naka',
      status: 'SCHEDULED' as const,
      eta: '10:50 AM',
    },
    {
      id: 'best-251',
      no: 'BEST 251',
      dest: 'Vesava → Andheri Stn',
      status: 'LIMITED DATA' as const,
      eta: 'Sch. 11:15 AM',
    },
  ];

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      {/* Header */}
      <div className="bg-white px-4 pt-12 pb-4 border-b border-slate-200">
        <div className="flex items-center justify-between mb-1">
          <div>
            <p className="text-xs text-slate-500 font-medium">SmartCrowd Transit</p>
            <h1 className="text-xl font-bold text-slate-900">Where are you going?</h1>
          </div>
          <button
            onClick={() => navigate('/driver')}
            className="text-xs text-blue-600 border border-blue-200 rounded-lg px-2.5 py-1.5 font-semibold bg-blue-50 hover:bg-blue-100 transition-colors flex items-center gap-1"
          >
            <span>Driver</span>
            <span className="w-1.5 h-1.5 rounded-full bg-blue-500" />
          </button>
        </div>

        {/* Search Bar */}
        <button
          onClick={() => navigate('/search')}
          className="mt-3 w-full flex items-center gap-2.5 bg-slate-100 hover:bg-slate-200/80 transition-colors rounded-xl px-4 py-3 text-sm text-slate-400 text-left"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <circle cx="11" cy="11" r="7" stroke="#94A3B8" strokeWidth="2" />
            <path d="M16.5 16.5l4 4" stroke="#94A3B8" strokeWidth="2" strokeLinecap="round" />
          </svg>
          <span className="text-slate-500">Search bus, stop or destination...</span>
        </button>
      </div>

      <div className="px-4 py-4 flex flex-col gap-5">
        {/* Nearby Stops */}
        <section>
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">
            Nearby Stops
          </h2>
          {nearbyStops.map((stop) => (
            <button
              key={stop.id}
              onClick={() => navigate(`/stop/${stop.id}`)}
              className="w-full flex items-center justify-between bg-white border border-slate-200 rounded-xl px-4 py-3 mb-2 text-left shadow-sm hover:border-blue-300 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="3" fill="#2563EB" />
                    <path
                      d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"
                      stroke="#2563EB"
                      strokeWidth="1.6"
                    />
                  </svg>
                </div>
                <div>
                  <p className="text-sm font-medium text-slate-900">{stop.name}</p>
                  <p className="text-xs text-slate-400">
                    {stop.count} buses serving this stop · {stop.time}
                  </p>
                </div>
              </div>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                <path d="M9 18l6-6-6-6" stroke="#CBD5E1" strokeWidth="2" strokeLinecap="round" />
              </svg>
            </button>
          ))}
        </section>

        {/* Saved Places */}
        <section>
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">
            Saved Places
          </h2>
          <div className="flex gap-2">
            {savedPlaces.map((place) => (
              <button
                key={place.label}
                onClick={() => navigate('/search')}
                className="flex-1 flex items-center gap-2.5 bg-white border border-slate-200 rounded-xl px-3 py-3 text-left shadow-sm hover:border-blue-300 transition-colors"
              >
                <div className="w-7 h-7 rounded-lg bg-blue-50 flex items-center justify-center flex-shrink-0">
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none">
                    <path
                      d="M3 9.5L12 3l9 6.5V20a1 1 0 01-1 1H4a1 1 0 01-1-1V9.5z"
                      stroke="#2563EB"
                      strokeWidth="2"
                    />
                    <path d="M9 21V12h6v9" stroke="#2563EB" strokeWidth="2" />
                  </svg>
                </div>
                <div className="overflow-hidden">
                  <p className="text-xs font-semibold text-slate-800">{place.label}</p>
                  <p className="text-[10px] text-slate-400 truncate">{place.address}</p>
                </div>
              </button>
            ))}
          </div>
        </section>

        {/* Popular Routes */}
        <section>
          <div className="flex items-center justify-between mb-2">
            <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Popular Routes
            </h2>
            <span className="text-[10px] text-blue-600 font-semibold cursor-pointer" onClick={() => navigate('/search')}>
              View all
            </span>
          </div>

          <div className="flex flex-col gap-2">
            {popularRoutes.map((route) => (
              <button
                key={route.id}
                onClick={() => navigate(`/bus/${route.id}`)}
                className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3.5 flex items-center justify-between text-left shadow-sm hover:border-blue-300 transition-colors"
              >
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-sm font-bold text-slate-900">{route.no}</span>
                    <StatusBadge status={route.status} />
                  </div>
                  <p className="text-xs text-slate-500">{route.dest}</p>
                </div>
                <div className="text-right">
                  <p className="text-base font-bold text-blue-600">{route.eta}</p>
                  <p className="text-[10px] text-slate-400">
                    {route.status === 'LIVE' ? 'Live ETA' : 'Scheduled'}
                  </p>
                </div>
              </button>
            ))}
          </div>
        </section>
      </div>

      <BottomNav />
    </div>
  );
}
