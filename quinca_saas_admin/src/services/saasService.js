import {
  Timestamp,
  collection,
  doc,
  increment,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  writeBatch,
} from 'firebase/firestore'

import { db } from './firebase'

function formatDate(value) {
  if (!value) return 'Non defini'

  const date = dateDepuisFirestore(value)
  if (Number.isNaN(date.getTime())) return 'Non defini'

  return new Intl.DateTimeFormat('fr-FR').format(date)
}

function dateDepuisFirestore(value) {
  if (!value) return null
  if (typeof value.toDate === 'function') return value.toDate()
  return new Date(value)
}

function normaliserBoutique(documentSnapshot) {
  const data = documentSnapshot.data()
  const finAbonnement = data.expireLe ?? data.finAbonnement

  return {
    id: documentSnapshot.id,
    nom: data.nom ?? 'Boutique sans nom',
    adresse: data.adresse ?? 'Non renseignee',
    ville: data.ville ?? 'Non renseignee',
    telephone: data.telephone ?? 'Non renseigne',
    ownerId: data.ownerId ?? '',
    createdAt: formatDate(data.createdAt),
    admin: 'Admin non renseigne',
    adminTelephone: 'Non renseigne',
    statut: data.statut ?? 'actif',
    plan: data.plan ?? data.typeAbonnement ?? 'Mensuel',
    abonnement: data.abonnement ?? data.statutAbonnement ?? 'actif',
    expireLe: formatDate(finAbonnement),
    finAbonnementDate: dateDepuisFirestore(finAbonnement),
    revenu: Number(data.revenu ?? data.revenuSaas ?? 0),
  }
}

function normaliserUtilisateur(documentSnapshot) {
  const data = documentSnapshot.data()

  return {
    id: documentSnapshot.id,
    nomComplet: [data.prenom, data.nom].filter(Boolean).join(' ') || 'Admin non renseigne',
    telephone: data.telephone ?? 'Non renseigne',
    role: data.role ?? '',
  }
}

function normaliserPaiement(documentSnapshot) {
  const data = documentSnapshot.data()

  return {
    id: documentSnapshot.id,
    boutique: data.boutiqueNom ?? data.boutique ?? 'Boutique non renseignee',
    montant: Number(data.montant ?? 0),
    mode: data.mode ?? data.modePaiement ?? 'Non renseigne',
    date: formatDate(data.date ?? data.createdAt),
    periode: data.periode ?? 'Non renseignee',
  }
}

export function ecouterBoutiques(callback, onError) {
  const boutiquesQuery = query(collection(db, 'boutiques'), orderBy('nom'))
  const usersQuery = query(collection(db, 'users'))
  let boutiques = []
  let users = []

  function publierBoutiques() {
    const usersParId = new Map(users.map((user) => [user.id, user]))

    callback(
      boutiques.map((boutique) => {
        const proprietaire = usersParId.get(boutique.ownerId)

        return {
          ...boutique,
          admin: proprietaire?.nomComplet ?? boutique.admin,
          adminTelephone: proprietaire?.telephone ?? boutique.adminTelephone,
        }
      }),
    )
  }

  const unsubscribeBoutiques = onSnapshot(
    boutiquesQuery,
    (snapshot) => {
      boutiques = snapshot.docs.map(normaliserBoutique)
      publierBoutiques()
    },
    onError,
  )

  const unsubscribeUsers = onSnapshot(
    usersQuery,
    (snapshot) => {
      users = snapshot.docs
        .map(normaliserUtilisateur)
        .filter((user) => user.role === 'admin' || user.role === 'super_admin')
      publierBoutiques()
    },
    onError,
  )

  return () => {
    unsubscribeBoutiques()
    unsubscribeUsers()
  }
}

export function ecouterPaiementsSaas(callback, onError) {
  const paiementsQuery = query(collection(db, 'paiements_saas'), orderBy('createdAt', 'desc'))

  return onSnapshot(
    paiementsQuery,
    (snapshot) => callback(snapshot.docs.map(normaliserPaiement)),
    onError,
  )
}

export async function prolongerAbonnementBoutique({
  boutique,
  dureeMois,
  montant,
  modePaiement,
  createdBy,
}) {
  const maintenant = new Date()
  const base = boutique.finAbonnementDate > maintenant ? boutique.finAbonnementDate : maintenant
  const nouvelleFin = new Date(base)
  nouvelleFin.setMonth(nouvelleFin.getMonth() + dureeMois)

  const batch = writeBatch(db)
  const boutiqueRef = doc(db, 'boutiques', boutique.id)
  const paiementRef = doc(collection(db, 'paiements_saas'))
  const periode = dureeMois >= 12 ? 'Annuel' : `${dureeMois} mois`
  const plan = dureeMois >= 12 ? 'Annuel' : 'Mensuel'

  batch.update(boutiqueRef, {
    statut: 'actif',
    abonnement: 'actif',
    statutAbonnement: 'actif',
    plan,
    typeAbonnement: plan,
    montantAbonnement: montant,
    dernierPaiementAt: serverTimestamp(),
    finAbonnement: Timestamp.fromDate(nouvelleFin),
    expireLe: Timestamp.fromDate(nouvelleFin),
    revenuSaas: increment(montant),
  })

  batch.set(paiementRef, {
    boutiqueId: boutique.id,
    boutiqueNom: boutique.nom,
    montant,
    modePaiement,
    periode,
    dureeMois,
    createdAt: serverTimestamp(),
    createdBy: createdBy?.uid ?? '',
    createdByEmail: createdBy?.email ?? '',
  })

  await batch.commit()
}
