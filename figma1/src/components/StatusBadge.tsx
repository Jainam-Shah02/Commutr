type Status = 'LIVE' | 'SCHEDULED' | 'LIMITED DATA' | 'HIGH CONFIDENCE' | 'MEDIUM CONFIDENCE' | 'POSSIBLE DISRUPTION' | 'CONFIRMED DISRUPTION' | 'VERIFYING' | 'VERIFIED' | 'ACTIVE' | 'COMPLETED';

const config: Record<Status, { cls: string; dot?: string }> = {
  'LIVE': { cls: 'status-live', dot: 'bg-green-500' },
  'SCHEDULED': { cls: 'status-scheduled' },
  'LIMITED DATA': { cls: 'status-limited' },
  'HIGH CONFIDENCE': { cls: 'status-live' },
  'MEDIUM CONFIDENCE': { cls: 'status-scheduled' },
  'POSSIBLE DISRUPTION': { cls: 'status-possible' },
  'CONFIRMED DISRUPTION': { cls: 'status-disruption' },
  'VERIFYING': { cls: 'status-scheduled' },
  'VERIFIED': { cls: 'status-live' },
  'ACTIVE': { cls: 'status-live', dot: 'bg-green-500' },
  'COMPLETED': { cls: 'bg-slate-100 text-slate-600' },
};

export default function StatusBadge({ status }: { status: Status }) {
  const { cls, dot } = config[status] ?? { cls: 'bg-slate-100 text-slate-600' };
  return (
    <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-semibold uppercase tracking-wide ${cls}`}>
      {dot && <span className={`w-1.5 h-1.5 rounded-full ${dot} animate-pulse`} />}
      {status}
    </span>
  );
}
