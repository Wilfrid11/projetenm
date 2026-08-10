import { navigation } from '../../app/navigation'

export function Topbar({ page, session, onLogout }) {
  const titre = navigation.find((item) => item.id === page)?.label

  return (
    <header className="mb-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <p className="text-xs font-bold uppercase text-quinca-muted">Plateforme SaaS</p>
        <h1 className="mt-1 text-2xl font-black text-quinca-ink lg:text-3xl">
          {titre}
        </h1>
      </div>
      <div className="flex w-max items-center gap-2 rounded-full border border-quinca-border bg-white px-3 py-2 text-sm font-bold text-quinca-blue">
        <span className="grid h-7 w-7 place-items-center rounded-full bg-quinca-blue text-xs text-white">
          S
        </span>
        <span className="hidden max-w-[180px] truncate sm:inline">
          {session?.email ?? 'super_admin'}
        </span>
        <button
          className="rounded-full bg-quinca-bg px-3 py-1 text-xs font-black text-quinca-ink"
          type="button"
          onClick={onLogout}
        >
          Sortir
        </button>
      </div>
    </header>
  )
}
