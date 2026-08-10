export function Toolbar({ title, subtitle, children }) {
  return (
    <div className="flex flex-col gap-4 rounded-xl border border-quinca-border bg-white p-4 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <h2 className="text-lg font-black">{title}</h2>
        <p className="mt-1 text-sm text-quinca-muted">{subtitle}</p>
      </div>
      {children}
    </div>
  )
}
