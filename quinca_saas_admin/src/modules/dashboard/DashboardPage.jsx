import { formatMoney } from '../../app/formatters'
import { Panel } from '../../components/ui/Panel'
import { StatCard } from '../../components/ui/StatCard'
import { BoutiqueTable } from '../boutiques/BoutiqueTable'

export function DashboardPage({ boutiques }) {
  const actives = boutiques.filter((item) => item.statut === 'actif').length
  const suspendues = boutiques.filter((item) => item.statut === 'suspendu').length
  const impayes = boutiques.filter((item) => item.abonnement !== 'actif').length
  const revenu = boutiques.reduce((total, item) => total + item.revenu, 0)

  return (
    <section className="grid gap-4">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <StatCard label="Boutiques" value={boutiques.length} tone="blue" />
        <StatCard label="Actives" value={actives} tone="green" />
        <StatCard label="Suspendues" value={suspendues} tone="red" />
        <StatCard label="Impayes" value={impayes} tone="orange" />
      </div>

      <Panel>
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-lg font-black">Revenu SaaS</h2>
            <p className="mt-1 text-sm text-quinca-muted">
              Total comptabilise sur les abonnements enregistres.
            </p>
          </div>
          <strong className="text-2xl text-quinca-blue">{formatMoney(revenu)}</strong>
        </div>
      </Panel>

      <BoutiqueTable boutiques={boutiques.slice(0, 3)} />
    </section>
  )
}
