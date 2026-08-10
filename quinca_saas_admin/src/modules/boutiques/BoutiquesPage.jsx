import { Toolbar } from '../../components/ui/Toolbar'
import { BoutiqueTable } from './BoutiqueTable'

export function BoutiquesPage({ boutiques, recherche, setRecherche }) {
  return (
    <section className="grid gap-4">
      <Toolbar
        title="Quincailleries"
        subtitle="Suivi des boutiques clientes et de leur statut SaaS."
      >
        <div className="flex w-full items-center gap-2 rounded-xl border border-quinca-border bg-quinca-bg px-3 sm:max-w-md">
          <span className="font-bold text-quinca-muted">R</span>
          <input
            className="w-full bg-transparent py-3 outline-none"
            value={recherche}
            onChange={(event) => setRecherche(event.target.value)}
            placeholder="Rechercher boutique, ville, telephone"
          />
        </div>
      </Toolbar>
      <BoutiqueTable boutiques={boutiques} />
    </section>
  )
}
