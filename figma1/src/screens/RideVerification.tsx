import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function RideVerification() {
  const navigate = useNavigate();
  const [step, setStep] = useState<'verifying' | 'verified'>('verifying');

  useEffect(() => {
    const t = setTimeout(() => setStep('verified'), 3000);
    return () => clearTimeout(t);
  }, []);

  return (
    <div className="flex flex-col min-h-screen bg-white">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-4">
        <button onClick={() => navigate(-1)} className="p-1.5 rounded-lg text-slate-500 -ml-1.5">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
          </svg>
        </button>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center px-6 text-center">
        {step === 'verifying' ? (
          <>
            <div className="w-20 h-20 rounded-full border-4 border-blue-100 border-t-blue-600 animate-spin mb-8" />
            <h2 className="text-xl font-bold text-slate-900 mb-2">Checking your ride</h2>
            <p className="text-sm text-slate-500 leading-relaxed mb-4">
              We're verifying your movement with the selected bus route.
            </p>
            <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 rounded-lg text-sm text-blue-700 font-medium">
              <div className="w-1.5 h-1.5 rounded-full bg-blue-500 animate-pulse" />
              Verifying
            </span>
          </>
        ) : (
          <>
            <div className="w-20 h-20 rounded-full bg-green-50 border border-green-100 flex items-center justify-center mb-8">
              <svg width="40" height="40" viewBox="0 0 24 24" fill="none">
                <path d="M5 13l4 4L19 7" stroke="#16A34A" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
            <h2 className="text-xl font-bold text-slate-900 mb-2">Ride verified</h2>
            <p className="text-sm text-slate-500 leading-relaxed mb-2">
              Your movement matches the route.
            </p>
            <p className="text-xs text-slate-400 mb-8">
              Location sharing is active. It will stop automatically when your ride ends.
            </p>

            <div className="w-full bg-slate-50 border border-slate-200 rounded-xl p-4 text-left mb-6">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-semibold text-slate-700">TMT 50</span>
                <span className="text-[10px] bg-green-50 text-green-700 font-semibold px-2 py-0.5 rounded">Active</span>
              </div>
              <p className="text-xs text-slate-400">Thane Station West → Manpada</p>
              <div className="mt-3 flex items-center gap-2">
                <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
                <span className="text-xs text-slate-500">Location sharing on · stops automatically</span>
              </div>
            </div>

            <div className="w-full flex flex-col gap-3">
              <button
                onClick={() => navigate('/live-map')}
                className="w-full bg-blue-600 text-white font-semibold text-sm py-3.5 rounded-xl"
              >
                Track Live
              </button>
              <button
                onClick={() => navigate('/home')}
                className="w-full border border-slate-200 text-slate-600 font-medium text-sm py-3 rounded-xl"
              >
                Stop Sharing Now
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
