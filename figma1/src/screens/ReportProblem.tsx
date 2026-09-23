import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import BackHeader from '../components/BackHeader';
import { useTransit } from '../context/TransitContext';

const problems = [
  { id: 'stopped', label: 'Bus stopped unexpectedly', icon: '⏸' },
  { id: 'blocked', label: 'Route blocked / heavy obstruction', icon: '🚧' },
  { id: 'emergency', label: 'Accident / emergency on route', icon: '🚨' },
  { id: 'other', label: 'Other service issue', icon: '💬' },
];

export default function ReportProblem() {
  const navigate = useNavigate();
  const [selected, setSelected] = useState<string | null>(null);
  const [submitted, setSubmitted] = useState(false);

  const { selectedRoute, reportPassengerProblem } = useTransit();

  const handleSubmit = () => {
    if (!selected) return;
    reportPassengerProblem(selected);
    setSubmitted(true);
  };

  if (submitted) {
    return (
      <div className="flex flex-col min-h-screen bg-white">
        <BackHeader title="Report a Problem" />
        <div className="flex-1 flex flex-col items-center justify-center px-6 text-center">
          <div className="w-16 h-16 rounded-full bg-blue-50 border border-blue-100 flex items-center justify-center mb-6">
            <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
              <path d="M5 13l4 4L19 7" stroke="#2563EB" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Report received</h2>
          <p className="text-sm text-slate-500 mb-3 leading-relaxed">
            Your report has been received and flagged for operator verification.
          </p>
          <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 border border-amber-200 rounded-lg text-xs text-amber-800 font-semibold mb-6">
            ⏳ Waiting for operator confirmation
          </span>
          <div className="bg-slate-50 border border-slate-200 rounded-xl p-3.5 mb-8 text-left w-full text-xs text-slate-500 leading-relaxed">
            Passengers will see <b>Possible Service Disruption</b> while this incident is under review. A confirmed disruption alert is issued only after driver or transit operator confirmation.
          </div>
          <button
            onClick={() => navigate('/live-map')}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm py-3.5 rounded-xl transition-colors"
          >
            Back to Live Map
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC]">
      <BackHeader
        title="Report a Problem"
        subtitle={`${selectedRoute.operator} ${selectedRoute.routeNumber} · ${selectedRoute.name}`}
      />

      <div className="px-4 py-4 flex flex-col gap-3">
        <p className="text-sm text-slate-600 font-medium">What seems to be the problem?</p>
        {problems.map((p) => (
          <button
            key={p.id}
            onClick={() => setSelected(p.id)}
            className={`w-full flex items-center gap-3 bg-white border rounded-xl px-4 py-4 text-left transition-colors shadow-sm ${
              selected === p.id ? 'border-blue-500 bg-blue-50/50' : 'border-slate-200 hover:border-slate-300'
            }`}
          >
            <span className="text-xl">{p.icon}</span>
            <span className={`text-sm font-medium ${selected === p.id ? 'text-blue-700 font-semibold' : 'text-slate-700'}`}>
              {p.label}
            </span>
            {selected === p.id && (
              <svg className="ml-auto" width="18" height="18" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="10" fill="#2563EB" />
                <path d="M8 12l3 3 5-5" stroke="white" strokeWidth="2" strokeLinecap="round" />
              </svg>
            )}
          </button>
        ))}
      </div>

      <div className="px-4 pb-8 mt-auto">
        <div className="bg-slate-50 border border-slate-200 rounded-xl p-3.5 mb-4">
          <p className="text-xs text-slate-500 leading-relaxed">
            Reports are verified against GPS sensor signals and driver telemetry before publishing route-wide alerts.
          </p>
        </div>
        <button
          onClick={handleSubmit}
          disabled={!selected}
          className={`w-full font-semibold text-sm py-3.5 rounded-xl transition-colors ${
            selected ? 'bg-blue-600 hover:bg-blue-700 text-white shadow-sm' : 'bg-slate-200 text-slate-400 cursor-not-allowed'
          }`}
        >
          Submit Report
        </button>
      </div>
    </div>
  );
}
