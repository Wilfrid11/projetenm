import { formatMoney } from '../../app/formatters'
import { Panel } from '../../components/ui/Panel'
import { Toolbar } from '../../components/ui/Toolbar'

export function PaiementsPage({ paiements }) {
  return (
    <section className="grid gap-4">
      <Toolbar
        title="Paiements SaaS"
        subtitle="Historique des paiements recus pour les abonnements."
      >
        <button
          type="button"
          className="rounded-xl bg-quinca-blue px-4 py-2 font-bold text-white"
        >
          Nouveau paiement
        </button>
      </Toolbar>

      <Panel className="overflow-auto p-0">
        <table className="min-w-[760px] w-full border-collapse">
          <thead>
            <tr className="border-b border-quinca-border text-left text-xs uppercase text-quinca-muted">
              <th className="px-4 py-3">Reference</th>
              <th className="px-4 py-3">Boutique</th>
              <th className="px-4 py-3">Date</th>
              <th className="px-4 py-3">Mode</th>
              <th className="px-4 py-3">Periode</th>
              <th className="px-4 py-3">Montant</th>
            </tr>
          </thead>
          <tbody>
            {paiements.length === 0 && (
              <tr>
                <td className="px-4 py-8 text-center font-bold text-quinca-muted" colSpan={6}>
                  Aucun paiement SaaS enregistre.
                </td>
              </tr>
            )}
            {paiements.map((paiement) => (
              <tr key={paiement.id} className="border-b border-quinca-border">
                <td className="px-4 py-3">{paiement.id}</td>
                <td className="px-4 py-3">{paiement.boutique}</td>
                <td className="px-4 py-3">{paiement.date}</td>
                <td className="px-4 py-3">{paiement.mode}</td>
                <td className="px-4 py-3">{paiement.periode}</td>
                <td className="px-4 py-3 font-bold">{formatMoney(paiement.montant)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Panel>
    </section>
  )
}
