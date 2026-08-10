export function Panel({ children, className = '' }) {
  return (
    <div className={`rounded-xl border border-quinca-border bg-white p-4 ${className}`}>
      {children}
    </div>
  )
}
