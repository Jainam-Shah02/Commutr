import { useNavigate, useLocation } from 'react-router-dom';

const tabs = [
  { label: 'Home', path: '/home', icon: HomeIcon },
  { label: 'Live', path: '/live-map', icon: LiveIcon },
  { label: 'Trips', path: '/trips', icon: TripsIcon },
  { label: 'Alerts', path: '/alerts', icon: AlertsIcon },
  { label: 'Profile', path: '/profile', icon: ProfileIcon },
];

function HomeIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M3 9.5L12 3l9 6.5V20a1 1 0 01-1 1H4a1 1 0 01-1-1V9.5z"
        stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" fill={active ? '#DBEAFE' : 'none'} />
      <path d="M9 21V12h6v9" stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" />
    </svg>
  );
}

function LiveIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="2" y="8" width="20" height="10" rx="2" stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" fill={active ? '#DBEAFE' : 'none'} />
      <circle cx="7" cy="18" r="2" fill={active ? '#2563EB' : '#94A3B8'} />
      <circle cx="17" cy="18" r="2" fill={active ? '#2563EB' : '#94A3B8'} />
      <path d="M8 8V6a4 4 0 018 0v2" stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" />
    </svg>
  );
}

function TripsIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"
        stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" />
      <rect x="9" y="3" width="6" height="4" rx="1" stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" />
      <path d="M9 12h6M9 16h4" stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  );
}

function AlertsIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0"
        stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  );
}

function ProfileIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="8" r="4" stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" />
      <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke={active ? '#2563EB' : '#94A3B8'} strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  );
}

export default function BottomNav() {
  const navigate = useNavigate();
  const { pathname } = useLocation();

  return (
    <div className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[390px] bg-white border-t border-slate-200 flex z-50">
      {tabs.map(({ label, path, icon: Icon }) => {
        const active = pathname === path || (path === '/live-map' && pathname === '/live-map');
        return (
          <button
            key={path}
            onClick={() => navigate(path)}
            className="flex-1 flex flex-col items-center gap-1 py-2.5 min-h-[56px]"
          >
            <Icon active={active} />
            <span className={`text-[10px] font-medium ${active ? 'text-blue-600' : 'text-slate-400'}`}>{label}</span>
          </button>
        );
      })}
    </div>
  );
}
