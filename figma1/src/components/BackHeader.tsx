import { useNavigate } from 'react-router-dom';

export default function BackHeader({ title, subtitle }: { title: string; subtitle?: string }) {
  const navigate = useNavigate();
  return (
    <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-4 flex items-start gap-3">
      <button onClick={() => navigate(-1)} className="mt-0.5 p-1.5 -ml-1.5 rounded-lg text-slate-500 hover:bg-slate-100">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
      <div>
        <h1 className="text-lg font-semibold text-slate-900">{title}</h1>
        {subtitle && <p className="text-sm text-slate-500 mt-0.5">{subtitle}</p>}
      </div>
    </div>
  );
}
