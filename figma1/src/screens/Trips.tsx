import BottomNav from '../components/BottomNav';

const trips = [
  {
    group: 'Today',
    items: [
      { no: 'TMT 50', route: 'Thane Station → Manpada', status: 'Completed', time: '09:12 AM', duration: '18 min' },
    ],
  },
  {
    group: 'Yesterday',
    items: [
      { no: 'BEST 251', route: 'Andheri → Vesava', status: 'Completed', time: '06:45 PM', duration: '25 min' },
      { no: 'TMT 2', route: 'Thane Station → Balkum', status: 'Completed', time: '08:30 AM', duration: '22 min' },
    ],
  },
  {
    group: 'Monday',
    items: [
      { no: 'TMT 50', route: 'Manpada → Thane Station', status: 'Completed', time: '07:55 AM', duration: '20 min' },
    ],
  },
];

export default function Trips() {
  return (
    <div className="flex flex-col min-h-screen bg-[#F8FAFC] pb-20">
      <div className="bg-white border-b border-slate-200 px-4 pt-12 pb-4">
        <h1 className="text-xl font-bold text-slate-900">My Trips</h1>
        <p className="text-xs text-slate-400 mt-0.5">Recent journey history</p>
      </div>

      <div className="px-4 py-4 flex flex-col gap-4">
        {trips.map((group) => (
          <section key={group.group}>
            <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">{group.group}</h2>
            <div className="flex flex-col gap-2">
              {group.items.map((trip, i) => (
                <div key={i} className="bg-white border border-slate-200 rounded-xl p-4">
                  <div className="flex items-start justify-between">
                    <div>
                      <div className="flex items-center gap-2 mb-0.5">
                        <span className="text-sm font-bold text-slate-900">{trip.no}</span>
                        <span className="text-[10px] bg-slate-100 text-slate-600 font-medium px-2 py-0.5 rounded uppercase">{trip.status}</span>
                      </div>
                      <p className="text-xs text-slate-500">{trip.route}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-slate-500">{trip.time}</p>
                      <p className="text-xs text-slate-400">{trip.duration}</p>
                    </div>
                  </div>
                  <div className="flex gap-2 mt-3">
                    <button className="text-xs text-blue-600 font-medium border border-blue-100 bg-blue-50 px-3 py-1.5 rounded-lg">
                      View
                    </button>
                    <button className="text-xs text-slate-600 font-medium border border-slate-200 bg-white px-3 py-1.5 rounded-lg">
                      Save Route
                    </button>
                    <button className="text-xs text-slate-600 font-medium border border-slate-200 bg-white px-3 py-1.5 rounded-lg">
                      Repeat
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))}
      </div>

      <BottomNav />
    </div>
  );
}
