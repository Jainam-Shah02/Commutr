import { useNavigate } from 'react-router-dom';

export default function Onboarding() {
  const navigate = useNavigate();
  return (
    <div className="flex flex-col min-h-screen bg-white px-6">
      <div className="flex-1 flex flex-col justify-center items-center text-center">
        {/* Minimal bus icon */}
        <div className="w-20 h-20 rounded-2xl bg-blue-50 border border-blue-100 flex items-center justify-center mb-8">
          <svg width="44" height="44" viewBox="0 0 44 44" fill="none">
            <rect x="6" y="10" width="32" height="22" rx="3" fill="#2563EB" opacity="0.12" stroke="#2563EB" strokeWidth="1.8" />
            <path d="M6 18h32" stroke="#2563EB" strokeWidth="1.5" />
            <circle cx="13" cy="34" r="3" fill="#2563EB" />
            <circle cx="31" cy="34" r="3" fill="#2563EB" />
            <path d="M13 32v-1M31 32v-1" stroke="#2563EB" strokeWidth="1.5" />
            <rect x="10" y="13" width="8" height="5" rx="1" fill="#2563EB" opacity="0.3" />
            <rect x="22" y="13" width="8" height="5" rx="1" fill="#2563EB" opacity="0.3" />
            <circle cx="33" cy="20" r="3" fill="#16A34A" />
            <circle cx="33" cy="20" r="1.2" fill="white" />
          </svg>
        </div>

        <div className="mb-3">
          <span className="text-xs font-semibold tracking-widest text-blue-600 uppercase">SmartCrowd Transit</span>
        </div>

        <h1 className="text-2xl font-bold text-slate-900 leading-tight mb-4">
          Track your bus<br />in real time
        </h1>
        <p className="text-sm text-slate-500 leading-relaxed max-w-xs">
          See estimated bus locations and arrival times using verified passenger signals.
        </p>
      </div>

      <div className="pb-12 flex flex-col gap-3">
        <button
          onClick={() => navigate('/location-permission')}
          className="w-full bg-blue-600 text-white font-semibold text-sm py-3.5 rounded-xl active:bg-blue-700"
        >
          Get Started
        </button>
        <button
          onClick={() => navigate('/home')}
          className="w-full text-slate-500 font-medium text-sm py-3"
        >
          Skip
        </button>
      </div>
    </div>
  );
}
