import { Badge } from '../../components/ui/Badge'
import { Panel } from '../../components/ui/Panel'

export function BoutiqueTable({ boutiques }) {
  return (
    <Panel className="overflow-auto p-0">
      <table className="min-w-[760px] w-full border-collapse">
        <thead>
          <tr className="border-b border-quinca-border text-left text-xs uppercase text-quinca-muted">
            <th className="px-4 py-3">Boutique</th>
            <th className="px-4 py-3">Proprietaire</th>
            <th className="px-4 py-3">Adresse</th>
            <th className="px-4 py-3">Ville</th>
            <th className="px-4 py-3">Telephone boutique</th>
            <th className="px-4 py-3">Creation</th>
            <th className="px-4 py-3">Statut</th>
          </tr>
        </thead>
        <tbody>
          {boutiques.length === 0 && (
            <tr>
              <td className="px-4 py-8 text-center font-bold text-quinca-muted" colSpan={7}>
                Aucune boutique trouvee.
              </td>
            </tr>
          )}
          {boutiques.map((boutique) => (
            <tr key={boutique.id} className="border-b border-quinca-border">
              <td className="px-4 py-3">
                <strong className="block">{boutique.nom}</strong>
                <span className="mt-1 block text-xs text-quinca-muted">{boutique.id}</span>
              </td>
              <td className="px-4 py-3">
                {boutique.admin}
                <span className="mt-1 block text-xs text-quinca-muted">
                  {boutique.adminTelephone}
                </span>
              </td>
              <td className="px-4 py-3">{boutique.adresse}</td>
              <td className="px-4 py-3">{boutique.ville}</td>
              <td className="px-4 py-3">{boutique.telephone}</td>
              <td className="px-4 py-3">{boutique.createdAt}</td>
              <td className="px-4 py-3">
                <Badge value={boutique.statut} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </Panel>
  )
}
