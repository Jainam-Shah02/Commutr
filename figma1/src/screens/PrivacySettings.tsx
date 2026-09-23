import { useState } from 'react';
import BackHeader from '../components/BackHeader';

export default function PrivacySettings() {
  const [locationAccess, setLocationAccess] = useState(true);
  const [background, setBackground] = useState(false);
  const [notifications, setNotifications] = useState(true);
  const [rideSharing, setRideSharing] = useState(true);

  const settings = [
    { label: 'Location access', desc: 'Allow app to access location', val: locationAccess, set: setLocationAccess },
    { label: 'Background location', desc: 'Only needed while app is open', val: background, set: setBackground },
    { label: 'Notifications', desc: 'Bus alerts and arrival updates', val: notifications, set: setNotifications },
    { label: 'Ride location sharing', desc: 'Share location while travelling', val: rideSharing, set: setRideSharing },
  ];

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC]">
      <BackHeader title="Privacy & Permissions" />

      <div className="px-4 py-4 flex flex-col gap-4">
        <div className="bg-blue-50 border border-blue-100 rounded-xl p-4">
          <p className="text-xs font-semibold text-blue-800 mb-1">How we use your location</p>
          <p className="text-xs text-blue-700 leading-relaxed">
            We use aggregated and verified movement signals to estimate bus movement. Individual passenger locations are not shown on the map or shared with other users.
          </p>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl overflow-hidden">
          {settings.map((s, i) => (
            <div key={s.label}>
              {i > 0 && <div className="h-px bg-slate-100 mx-4" />}
              <div className="flex items-center justify-between px-4 py-4">
                <div>
                  <p className="text-sm font-medium text-slate-800">{s.label}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{s.desc}</p>
                </div>
                <button
                  onClick={() => s.set(!s.val)}
                  className={`w-11 h-6 rounded-full transition-colors relative flex-shrink-0 ${s.val ? 'bg-blue-600' : 'bg-slate-200'}`}
                >
                  <div
                    className={`bg-white rounded-full absolute top-0.5 transition-transform shadow-sm ${s.val ? 'translate-x-5' : 'translate-x-0.5'}`}
                    style={{ width: 18, height: 18 }}
                  />
                </button>
              </div>
            </div>
          ))}
        </div>

        <div className="flex gap-3">
          <button className="flex-1 border border-slate-200 bg-white text-slate-700 font-medium text-sm py-3 rounded-xl">
            Manage Permissions
          </button>
          <button className="flex-1 border border-red-200 bg-red-50 text-red-600 font-medium text-sm py-3 rounded-xl">
            Stop Sharing
          </button>
        </div>
      </div>
    </div>
  );
}
