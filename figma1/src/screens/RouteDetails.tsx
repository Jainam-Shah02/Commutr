import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import StatusBadge from '../components/StatusBadge';
import BottomNav from '../components/BottomNav';
import { useTransit } from '../context/TransitContext';
import { ALL_ROUTES } from '../services/transitData';

type Tab = 'live' | 'timetable' | 'stops';

export default function RouteDetails() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [tab, setTab] = useState<Tab>('live');

  const { selectedRoute: activeRoute, busState, serviceStatus, setSelectedRouteById } = useTransit();

  // Pick route from param or fallback to current
  const route = (id && ALL_ROUTES[id]) || activeRoute;

  const currentStop = route.stops.find((s) => s.id === busState?.currentStopId);
  const nextStop = route.stops.find((s) => s.id === busState?.nextStopId);

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-0">
        <div className="flex items-center gap-2 pb-3 border-b border-slate-100">
          <button
            onClick={() => navigate(-1)}
            className="p-1.5 -ml-1.5 rounded-lg text-slate-500 hover:bg-slate-100"
            aria-label="Back"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
            </svg>
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">
                {route.operator} {route.routeNumber}
              </h1>
              <StatusBadge
                status={
                  serviceStatus === 'CONFIRMED_DISRUPTION'
                    ? 'CONFIRMED DISRUPTION'
                    : !busState
                    ? 'SCHEDULED'
                    : 'LIVE'
                }
              />
            </div>
            <p className="text-xs text-slate-500">{route.name}</p>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="flex">
          {(['live', 'timetable', 'stops'] as Tab[]).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`flex-1 py-3 text-sm font-semibold capitalize border-b-2 transition-colors ${
                tab === t
                  ? 'border-blue-600 text-blue-600'
                  : 'border-transparent text-slate-500 hover:text-slate-700'
              }`}
            >
              {t.charAt(0).toUpperCase() + t.slice(1)}
            </button>
          ))}
        </div>
      </div>

      <div className="px-4 py-4">
        {/* LIVE TAB */}
        {tab === 'live' && (
          <div className="flex flex-col gap-3">
            {busState ? (
              <>
                <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm">
                  <div className="flex justify-between mb-3">
                    <div>
                      <p className="text-xs text-slate-400">Estimated arrival</p>
                      <p className="text-3xl font-bold text-blue-600">
                        {serviceStatus === 'CONFIRMED_DISRUPTION' ? 'Delayed' : `${busState.etaMinutes} min`}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-slate-400">Next stop</p>
                      <p className="text-sm font-semibold text-slate-800">
                        {nextStop?.name || 'Majiwada'}
                      </p>
                      <p className="text-[10px] text-slate-400">Current: {currentStop?.name || 'Thane'}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 pt-2 border-t border-slate-100">
                    <span className="text-[10px] bg-green-50 text-green-700 font-semibold px-2 py-0.5 rounded">
                      {busState.confidence}
                    </span>
                    <span className="text-[10px] text-slate-400">
                      Updated {busState.lastUpdatedSec} sec ago
                    </span>
                    <span className="text-[10px] text-slate-500 ml-auto">
                      {busState.occupancy} occupancy
                    </span>
                  </div>
                </div>

                <button
                  onClick={() => navigate('/live-map')}
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm py-3.5 rounded-xl shadow-sm transition-colors flex items-center justify-center gap-2"
                >
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <path d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l5.447 2.724A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                  Open Live Map
                </button>
              </>
            ) : (
              <div className="bg-white border border-slate-200 rounded-xl p-4 text-center">
                <p className="text-sm font-semibold text-slate-800 mb-1">Live tracking unavailable</p>
                <p className="text-xs text-slate-500 mb-4">
                  Check the timetable tab for scheduled departures.
                </p>
                <button
                  onClick={() => setTab('timetable')}
                  className="bg-blue-50 text-blue-600 font-semibold text-xs py-2 px-4 rounded-lg"
                >
                  View Timetable
                </button>
              </div>
            )}

            <div className="bg-slate-50 border border-slate-200 rounded-xl p-3.5">
              <p className="text-xs font-semibold text-slate-700 mb-1">Live Data Verification</p>
              <p className="text-xs text-slate-500 leading-relaxed">
                SmartCrowd aggregates multiple authenticated passenger location pings with road geometry to guarantee high confidence estimates without tracking individual identities.
              </p>
            </div>
          </div>
        )}

        {/* TIMETABLE TAB */}
        {tab === 'timetable' && (
          <div className="flex flex-col gap-4">
            {route.timetable.length > 0 ? (
              route.timetable.map((section) => (
                <section key={section.period}>
                  <h3 className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">
                    {section.period}
                  </h3>
                  <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
                    {section.times.map((item, i) => (
                      <div key={item.time}>
                        {i > 0 && <div className="h-px bg-slate-100 mx-4" />}
                        <div className="flex items-center justify-between px-4 py-3">
                          <span className="text-sm font-semibold text-slate-800">{item.time}</span>
                          <StatusBadge status={item.status} />
                        </div>
                      </div>
                    ))}
                  </div>
                </section>
              ))
            ) : (
              <div className="bg-white border border-slate-200 rounded-xl p-6 text-center text-slate-500 text-xs">
                No timetable data available for this route.
              </div>
            )}
          </div>
        )}

        {/* STOPS TAB */}
        {tab === 'stops' && (
          <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
            {route.stops.map((stop, i) => {
              const isCurrent = busState?.currentStopId === stop.id;
              const isNext = busState?.nextStopId === stop.id;
              const isPassed =
                busState &&
                route.stops.findIndex((s) => s.id === busState.currentStopId) > i;

              return (
                <div key={stop.id}>
                  {i > 0 && <div className="h-px bg-slate-100 mx-4" />}
                  <button
                    onClick={() => navigate(`/stop/${stop.id}`)}
                    className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-slate-50 transition-colors"
                  >
                    <div
                      className={`w-2.5 h-2.5 rounded-full flex-shrink-0 ${
                        isCurrent
                          ? 'bg-blue-600 ring-4 ring-blue-100'
                          : isNext
                          ? 'bg-blue-400'
                          : isPassed
                          ? 'bg-slate-300'
                          : i === route.stops.length - 1
                          ? 'bg-red-500'
                          : 'bg-slate-400'
                      }`}
                    />
                    <div className="flex-1">
                      <p
                        className={`text-sm ${
                          isCurrent
                            ? 'font-bold text-blue-600'
                            : isNext
                            ? 'font-semibold text-slate-900'
                            : 'text-slate-700'
                        }`}
                      >
                        {stop.name}
                      </p>
                      {isCurrent && (
                        <p className="text-[10px] text-blue-500">Bus estimated here</p>
                      )}
                      {isNext && (
                        <p className="text-[10px] text-slate-400">Next approaching stop</p>
                      )}
                    </div>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                      <path d="M9 18l6-6-6-6" stroke="#CBD5E1" strokeWidth="2" strokeLinecap="round" />
                    </svg>
                  </button>
                </div>
              );
            })}
          </div>
        )}
      </div>

      <BottomNav />
    </div>
  );
}
