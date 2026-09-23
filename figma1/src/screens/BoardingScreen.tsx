import { useNavigate } from 'react-router-dom';
import BackHeader from '../components/BackHeader';

export default function BoardingScreen() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col min-h-screen bg-white">
      <BackHeader title="TMT 50" subtitle="Thane Station West → Manpada" />

      <div className="flex-1 flex flex-col justify-center items-center px-6 text-center">
        <div className="w-16 h-16 rounded-2xl bg-blue-50 border border-blue-100 flex items-center justify-center mb-6">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
            <rect x="2" y="8" width="20" height="10" rx="2" stroke="#2563EB" strokeWidth="1.8" />
            <circle cx="6" cy="18" r="2" fill="#2563EB" />
            <circle cx="18" cy="18" r="2" fill="#2563EB" />
            <path d="M7 8V6a5 5 0 0110 0v2" stroke="#2563EB" strokeWidth="1.8" />
          </svg>
        </div>

        <h2 className="text-xl font-bold text-slate-900 mb-2">Did you board this bus?</h2>
        <p className="text-sm text-slate-500 leading-relaxed mb-2">
          Your location helps improve the bus estimate for everyone.
        </p>
        <p className="text-xs text-slate-400 mb-8">
          Sharing stops automatically when your ride ends.
        </p>

        <div className="flex items-center gap-2 mb-8 bg-slate-50 border border-slate-200 rounded-xl px-4 py-3">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <rect x="3" y="11" width="18" height="11" rx="2" stroke="#64748B" strokeWidth="1.8" />
            <path d="M7 11V7a5 5 0 0110 0v4" stroke="#64748B" strokeWidth="1.8" />
            <circle cx="12" cy="16" r="1.5" fill="#64748B" />
          </svg>
          <p className="text-xs text-slate-500">Your individual location is not visible to other passengers</p>
        </div>

        <div className="w-full flex flex-col gap-3">
          <button
            onClick={() => navigate('/ride-verification')}
            className="w-full bg-blue-600 text-white font-semibold text-sm py-3.5 rounded-xl"
          >
            Start Sharing
          </button>
          <button
            onClick={() => navigate(-1)}
            className="w-full border border-slate-200 text-slate-600 font-medium text-sm py-3.5 rounded-xl"
          >
            Not Now
          </button>
        </div>
      </div>
    </div>
  );
}
