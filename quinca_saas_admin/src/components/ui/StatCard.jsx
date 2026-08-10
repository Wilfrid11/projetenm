export function StatCard({ label, value, tone }) {
  const toneClass = {
    blue: 'text-quinca-blue',
    green: 'text-green-500',
    red: 'text-red-500',
    orange: 'text-quinca-orange',
  }[tone]

  return (
    <article className="rounded-xl border border-quinca-border bg-white p-4">
      <span className="text-sm font-bold text-quinca-muted">{label}</span>
      <strong className={`mt-2 block text-3xl font-black ${toneClass}`}>
        {value}
      </strong>
    </article>
  )
}
