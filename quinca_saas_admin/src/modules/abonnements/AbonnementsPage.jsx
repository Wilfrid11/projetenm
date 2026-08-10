import { useMemo, useState } from 'react'

import { formatMoney } from '../../app/formatters'
import { Badge } from '../../components/ui/Badge'
import { Toolbar } from '../../components/ui/Toolbar'
import { prolongerAbonnementBoutique } from '../../services/saasService'

const modesPaiement = ['MTN', 'Moov', 'Celtiis', 'Especes']

export function AbonnementsPage({ boutiques, session }) {
  const [boutiqueActive, setBoutiqueActive] = useState(null)
  const [dureeMois, setDureeMois] = useState(1)
  const [montant, setMontant] = useState(15000)
  const [modePaiement, setModePaiement] = useState('MTN')
  const [chargement, setChargement] = useState(false)
  const [message, setMessage] = useState('')

  const totalRevenu = useMemo(
    () => boutiques.reduce((total, boutique) => total + boutique.revenu, 0),
    [boutiques],
  )

  function ouvrirProlongation(boutique) {
    setBoutiqueActive(boutique)
    setDureeMois(1)
    setMontant(15000)
    setModePaiement('MTN')
    setMessage('')
  }

  async function validerProlongation(event) {
    event.preventDefault()
    setMessage('')
    setChargement(true)

    try {
      await prolongerAbonnementBoutique({
        boutique: boutiqueActive,
        dureeMois: Number(dureeMois),
        montant: Number(montant),
        modePaiement,
        createdBy: session,
      })
      setBoutiqueActive(null)
    } catch (error) {
      setMessage(error.message || 'Prolongation impossible pour le moment.')
    } finally {
      setChargement(false)
    }
  }

  return (
    <section className="grid gap-4">
      <Toolbar
        title="Abonnements"
        subtitle="Plans, expirations et statuts de paiement."
      >
        <div className="rounded-xl border border-quinca-border bg-white px-4 py-2 text-sm">
          <span className="font-bold text-quinca-muted">Revenu SaaS</span>
          <strong className="ml-2 text-quinca-blue">{formatMoney(totalRevenu)}</strong>
        </div>
      </Toolbar>
      <div className="grid gap-3">
        {boutiques.length === 0 && (
          <article className="rounded-xl border border-quinca-border bg-white p-6 text-center font-bold text-quinca-muted">
            Aucun abonnement trouve.
          </article>
        )}
        {boutiques.map((boutique) => (
          <article
            className="flex flex-col gap-3 rounded-xl border border-quinca-border bg-white p-4 sm:flex-row sm:items-center sm:justify-between"
            key={boutique.id}
          >
            <div>
              <h3 className="text-base font-black">{boutique.nom}</h3>
              <p className="mt-1 text-sm text-quinca-muted">
                {boutique.plan} - expire le {boutique.expireLe}
              </p>
              <p className="mt-1 text-xs font-bold text-quinca-muted">
                {boutique.ville} - {boutique.telephone}
              </p>
            </div>
            <div className="flex flex-col gap-2 sm:items-end">
              <Badge value={boutique.abonnement} />
              <span className="text-sm font-black text-quinca-blue">
                {formatMoney(boutique.revenu)}
              </span>
            </div>
            <button
              type="button"
              className="rounded-xl border border-quinca-blue px-4 py-2 font-bold text-quinca-blue"
              onClick={() => ouvrirProlongation(boutique)}
            >
              Prolonger
            </button>
          </article>
        ))}
      </div>

      {boutiqueActive && (
        <div className="fixed inset-0 z-20 grid place-items-center bg-slate-950/40 px-4">
          <form
            className="w-full max-w-lg rounded-2xl border border-quinca-border bg-white p-5 shadow-xl"
            onSubmit={validerProlongation}
          >
            <div className="mb-5">
              <p className="text-xs font-black uppercase text-quinca-orange">
                Prolongation abonnement
              </p>
              <h2 className="mt-1 text-xl font-black">{boutiqueActive.nom}</h2>
              <p className="mt-1 text-sm text-quinca-muted">
                Expiration actuelle: {boutiqueActive.expireLe}
              </p>
            </div>

            <div className="grid gap-4 sm:grid-cols-2">
              <label className="grid gap-2 text-sm font-bold">
                Duree
                <select
                  className="rounded-xl border border-quinca-border bg-quinca-bg px-4 py-3 outline-none focus:border-quinca-blue"
                  value={dureeMois}
                  onChange={(event) => {
                    const value = Number(event.target.value)
                    setDureeMois(value)
                    setMontant(value >= 12 ? 120000 : 15000 * value)
                  }}
                >
                  <option value={1}>1 mois</option>
                  <option value={3}>3 mois</option>
                  <option value={6}>6 mois</option>
                  <option value={12}>1 an</option>
                </select>
              </label>

              <label className="grid gap-2 text-sm font-bold">
                Montant
                <input
                  className="rounded-xl border border-quinca-border bg-quinca-bg px-4 py-3 outline-none focus:border-quinca-blue"
                  min="0"
                  type="number"
                  value={montant}
                  onChange={(event) => setMontant(event.target.value)}
                  required
                />
              </label>
            </div>

            <div className="mt-4 grid gap-2 text-sm font-bold">
              Mode paiement
              <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
                {modesPaiement.map((mode) => (
                  <button
                    className={`rounded-xl border px-3 py-3 font-black ${
                      modePaiement === mode
                        ? 'border-quinca-blue bg-quinca-blue text-white'
                        : 'border-quinca-border bg-quinca-bg text-quinca-ink'
                    }`}
                    key={mode}
                    type="button"
                    onClick={() => setModePaiement(mode)}
                  >
                    {mode}
                  </button>
                ))}
              </div>
            </div>

            {message && (
              <p className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
                {message}
              </p>
            )}

            <div className="mt-5 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
              <button
                className="rounded-xl border border-quinca-border px-4 py-3 font-black"
                type="button"
                onClick={() => setBoutiqueActive(null)}
              >
                Annuler
              </button>
              <button
                className="rounded-xl bg-quinca-blue px-4 py-3 font-black text-white disabled:opacity-60"
                type="submit"
                disabled={chargement}
              >
                {chargement ? 'Enregistrement...' : 'Valider le paiement'}
              </button>
            </div>
          </form>
        </div>
      )}
    </section>
  )
}
