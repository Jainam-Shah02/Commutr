import { useNavigate } from 'react-router-dom';
import BottomNav from '../components/BottomNav';

const alerts = [
  {
    type: 'approach',
    icon: '🚌',
    title: 'Bus approaching',
    body: 'TMT 50 is approximately 5 minutes away from Majiwada.',
    time: '2 min ago',
    severity: 'info',
  },
  {
    type: 'eta-changed',
    icon: '⚠️',
    title: 'ETA changed',
    body: 'TMT 50 arrival changed from 6 min to 10 min.',
    time: '8 min ago',
    severity: 'warning',
  },
  {
    type: 'possible',
    icon: '⚠️',
    title: 'Possible service disruption',
    body: 'A bus has stopped unexpectedly on TMT 50 route. Operator confirmation pending.',
    time: '25 min ago',
    severity: 'warning',
    sub: 'Awaiting operator confirmation',
  },
  {
    type: 'confirmed',
    icon: '🔴',
    title: 'Confirmed service disruption',
    body: 'TMT 50 breakdown confirmed by operator. Last known position: Majiwada.',
    time: '1 hr ago',
    severity: 'danger',
    sub: 'Alternative: TMT 2 via Panchpakhadi',
  },
];

const severityStyle: Record<string, string> = {
  info: 'border-blue-100 bg-blue-50',
  warning: 'border-amber-100 bg-amber-50',
  danger: 'border-red-100 bg-red-50',
};

export default function Alerts() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-4">
        <h1 className="text-xl font-bold text-slate-900">Alerts</h1>
        <p className="text-xs text-slate-400 mt-0.5">Route and service updates</p>
      </div>

      <div className="px-4 py-4 flex flex-col gap-3">
        {alerts.map((alert, i) => (
          <div key={i} className={`border rounded-xl p-4 ${severityStyle[alert.severity]}`}>
            <div className="flex items-start justify-between mb-1">
              <div className="flex items-center gap-2">
                <span className="text-base">{alert.icon}</span>
                <span className="text-sm font-semibold text-slate-800">{alert.title}</span>
              </div>
              <span className="text-[10px] text-slate-400 flex-shrink-0">{alert.time}</span>
            </div>
            <p className="text-xs text-slate-600 leading-relaxed">{alert.body}</p>
            {alert.sub && (
              <p className="text-[10px] text-slate-500 mt-1.5 font-medium">{alert.sub}</p>
            )}
          </div>
        ))}

        <div className="text-center py-4">
          <p className="text-xs text-slate-400">No more alerts</p>
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
