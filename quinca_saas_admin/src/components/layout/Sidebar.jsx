import { navigation } from '../../app/navigation'

export function Sidebar({ page, setPage }) {
  return (
    <aside className="sticky top-0 z-10 flex flex-col gap-5 bg-slate-950 p-4 text-white lg:min-h-screen lg:gap-7 lg:p-5">
      <div className="flex items-center gap-3">
        <div className="grid h-11 w-11 place-items-center rounded-xl bg-quinca-orange font-black">
          Q
        </div>
        <div>
          <strong className="block">Quinca SaaS</strong>
          <span className="mt-0.5 block text-sm text-slate-400">Super Admin</span>
        </div>
      </div>

      <nav className="flex gap-2 overflow-x-auto lg:grid">
        {navigation.map((item) => (
          <button
            key={item.id}
            type="button"
            className={`flex min-w-max items-center gap-2 rounded-xl px-4 py-3 text-left text-sm font-semibold transition ${
              page === item.id
                ? 'bg-quinca-blue text-white'
                : 'text-slate-300 hover:bg-slate-800 hover:text-white'
            }`}
            onClick={() => setPage(item.id)}
          >
            <span className="grid h-6 w-6 place-items-center rounded-md bg-white/10 text-xs">
              {item.icon}
            </span>
            {item.label}
          </button>
        ))}
      </nav>
    </aside>
  )
}
