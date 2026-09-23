import { useNavigate } from 'react-router-dom';

export default function LocationPermission() {
  const navigate = useNavigate();
  return (
    <div className="flex flex-col min-h-screen bg-white px-6">
      <div className="flex-1 flex flex-col justify-center items-center text-center">
        <div className="w-20 h-20 rounded-full bg-blue-50 border border-blue-100 flex items-center justify-center mb-8">
          <svg width="36" height="36" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="4" fill="#2563EB" />
            <path d="M12 2v2M12 20v2M2 12h2M20 12h2" stroke="#2563EB" strokeWidth="2" strokeLinecap="round" />
            <path d="M12 8a4 4 0 014 4" stroke="#DBEAFE" strokeWidth="2" strokeLinecap="round" />
          </svg>
        </div>

        <h1 className="text-xl font-bold text-slate-900 mb-3">Allow location access</h1>
        <p className="text-sm text-slate-500 leading-relaxed max-w-xs mb-6">
          Location helps us estimate bus movement and arrival times. Your location is used only with your permission.
        </p>

        <div className="w-full bg-slate-50 border border-slate-200 rounded-xl p-4 text-left flex gap-3">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="flex-shrink-0 mt-0.5">
            <rect x="3" y="11" width="18" height="11" rx="2" stroke="#64748B" strokeWidth="1.8" />
            <path d="M7 11V7a5 5 0 0110 0v4" stroke="#64748B" strokeWidth="1.8" />
            <circle cx="12" cy="16" r="1.5" fill="#64748B" />
          </svg>
          <p className="text-xs text-slate-500 leading-relaxed">
            You can stop location sharing anytime from your profile settings.
          </p>
        </div>
      </div>

      <div className="pb-12 flex flex-col gap-3">
        <button
          onClick={() => navigate('/home')}
          className="w-full bg-blue-600 text-white font-semibold text-sm py-3.5 rounded-xl"
        >
          Allow Location
        </button>
        <button
          onClick={() => navigate('/home')}
          className="w-full border border-slate-200 text-slate-600 font-medium text-sm py-3.5 rounded-xl"
        >
          Not Now
        </button>
        <p className="text-center text-xs text-slate-400 mt-1">
          Your individual location is not shown to other passengers.
        </p>
      </div>
    </div>
  );
}
