import { useEffect, useMemo, useState } from 'react'

import { AdminLayout } from './components/layout/AdminLayout'
import { AbonnementsPage } from './modules/abonnements/AbonnementsPage'
import { LoginPage } from './modules/auth/LoginPage'
import { BoutiquesPage } from './modules/boutiques/BoutiquesPage'
import { DashboardPage } from './modules/dashboard/DashboardPage'
import { PaiementsPage } from './modules/paiements/PaiementsPage'
import { deconnecterSuperAdmin, ecouterSessionSuperAdmin } from './services/authService'
import { ecouterBoutiques, ecouterPaiementsSaas } from './services/saasService'

function App() {
  const [page, setPage] = useState('dashboard')
  const [recherche, setRecherche] = useState('')
  const [session, setSession] = useState(null)
  const [chargementSession, setChargementSession] = useState(true)
  const [boutiques, setBoutiques] = useState([])
  const [paiements, setPaiements] = useState([])
  const [erreurDonnees, setErreurDonnees] = useState('')

  useEffect(() => {
    return ecouterSessionSuperAdmin((profil) => {
      setSession(profil)
      setChargementSession(false)
    })
  }, [])

  useEffect(() => {
    if (!session) return undefined

    setErreurDonnees('')

    const unsubscribeBoutiques = ecouterBoutiques(
      setBoutiques,
      () => setErreurDonnees('Lecture des boutiques impossible. Verifie les regles Firestore.'),
    )
    const unsubscribePaiements = ecouterPaiementsSaas(
      setPaiements,
      () => setErreurDonnees('Lecture des paiements SaaS impossible.'),
    )

    return () => {
      unsubscribeBoutiques()
      unsubscribePaiements()
    }
  }, [session])

  const boutiquesFiltrees = useMemo(() => {
    const value = recherche.trim().toLowerCase()
    if (!value) return boutiques

    return boutiques.filter((boutique) =>
      [
        boutique.nom,
        boutique.admin,
        boutique.adresse,
        boutique.ville,
        boutique.telephone,
        boutique.adminTelephone,
      ].some(
        (champ) => String(champ).toLowerCase().includes(value),
      ),
    )
  }, [boutiques, recherche])

  if (chargementSession) {
    return (
      <main className="grid min-h-screen place-items-center bg-quinca-bg text-quinca-blue">
        <p className="rounded-2xl border border-quinca-border bg-white px-5 py-4 font-black">
          Verification de la session...
        </p>
      </main>
    )
  }

  if (!session) {
    return <LoginPage />
  }

  return (
    <AdminLayout
      page={page}
      setPage={setPage}
      session={session}
      onLogout={deconnecterSuperAdmin}
    >
      {erreurDonnees && (
        <p className="mb-4 rounded-xl border border-orange-200 bg-orange-50 px-4 py-3 text-sm font-bold text-orange-700">
          {erreurDonnees}
        </p>
      )}
      {page === 'dashboard' && <DashboardPage boutiques={boutiques} />}
      {page === 'boutiques' && (
        <BoutiquesPage
          boutiques={boutiquesFiltrees}
          recherche={recherche}
          setRecherche={setRecherche}
        />
      )}
      {page === 'abonnements' && (
        <AbonnementsPage boutiques={boutiques} session={session} />
      )}
      {page === 'paiements' && <PaiementsPage paiements={paiements} />}
    </AdminLayout>
  )
}

export default App
