import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import BottomNav from '../components/BottomNav';

export default function Profile() {
  const navigate = useNavigate();
  const [locationSharing, setLocationSharing] = useState(true);
  const [notifications, setNotifications] = useState(true);

  const sections = [
    {
      title: 'Account',
      items: [
        { label: 'Saved Stops', icon: '📍', action: () => {} },
        { label: 'Saved Routes', icon: '🗺', action: () => {} },
      ],
    },
    {
      title: 'Preferences',
      items: [
        { label: 'Notifications', icon: '🔔', toggle: true, val: notifications, setVal: setNotifications },
        { label: 'Location Sharing', icon: '📡', toggle: true, val: locationSharing, setVal: setLocationSharing },
      ],
    },
    {
      title: 'Privacy',
      items: [
        { label: 'Location Permissions', icon: '🔒', action: () => navigate('/privacy') },
        { label: 'Privacy Settings', icon: '🛡', action: () => navigate('/privacy') },
      ],
    },
    {
      title: 'Support',
      items: [
        { label: 'Help & Support', icon: '💬', action: () => {} },
        { label: 'About SmartCrowd', icon: 'ℹ️', action: () => {} },
      ],
    },
  ];

  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-6">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-full bg-blue-100 flex items-center justify-center">
            <span className="text-xl font-bold text-blue-600">P</span>
          </div>
          <div>
            <p className="text-base font-bold text-slate-900">Passenger</p>
            <p className="text-xs text-slate-500">Member since 2024</p>
          </div>
        </div>
      </div>

      <div className="px-4 py-4 flex flex-col gap-4">
        <div className="bg-slate-50 border border-slate-200 rounded-xl p-3 flex gap-3">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="flex-shrink-0 mt-0.5">
            <rect x="3" y="11" width="18" height="11" rx="2" stroke="#64748B" strokeWidth="1.8" />
            <path d="M7 11V7a5 5 0 0110 0v4" stroke="#64748B" strokeWidth="1.8" />
            <circle cx="12" cy="16" r="1.5" fill="#64748B" />
          </svg>
          <p className="text-xs text-slate-500 leading-relaxed">
            Your individual location is not shown to other passengers. Only aggregated, verified signals are used for bus tracking.
          </p>
        </div>

        {sections.map((section) => (
          <section key={section.title}>
            <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">{section.title}</h2>
            <div className="bg-white border border-slate-200 rounded-xl overflow-hidden">
              {section.items.map((item: any, i) => (
                <div key={item.label}>
                  {i > 0 && <div className="h-px bg-slate-100 mx-4" />}
                  <div
                    className={`flex items-center justify-between px-4 py-3.5 ${!item.toggle ? 'cursor-pointer active:bg-slate-50' : ''}`}
                    onClick={item.action}
                  >
                    <div className="flex items-center gap-3">
                      <span>{item.icon}</span>
                      <span className="text-sm font-medium text-slate-700">{item.label}</span>
                    </div>
                    {item.toggle ? (
                      <button
                        onClick={(e) => { e.stopPropagation(); item.setVal(!item.val); }}
                        className={`w-11 h-6 rounded-full transition-colors relative ${item.val ? 'bg-blue-600' : 'bg-slate-200'}`}
                      >
                        <div className={`w-4.5 h-4.5 bg-white rounded-full absolute top-0.5 transition-transform ${item.val ? 'translate-x-5' : 'translate-x-0.5'}`}
                          style={{ width: 18, height: 18 }}
                        />
                      </button>
                    ) : (
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                        <path d="M9 18l6-6-6-6" stroke="#CBD5E1" strokeWidth="2" strokeLinecap="round" />
                      </svg>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))}

        {locationSharing && (
          <p className="text-xs text-slate-400 text-center">
            Location sharing: <span className="text-slate-600 font-medium">Only while travelling</span>
          </p>
        )}
      </div>

      <BottomNav />
    </div>
  );
}
