import { Sidebar } from './Sidebar'
import { Topbar } from './Topbar'

export function AdminLayout({ page, setPage, session, onLogout, children }) {
  return (
    <div className="min-h-screen bg-quinca-bg text-quinca-ink lg:grid lg:grid-cols-[270px_minmax(0,1fr)]">
      <Sidebar page={page} setPage={setPage} />
      <main className="min-w-0 p-4 lg:p-6">
        <Topbar page={page} session={session} onLogout={onLogout} />
        {children}
      </main>
    </div>
  )
}
