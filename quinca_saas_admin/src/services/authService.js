import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
} from 'firebase/auth'
import { doc, getDoc } from 'firebase/firestore'

import { auth, db } from './firebase'

const SUPER_ADMIN_ROLE = 'super_admin'

async function chargerProfilSuperAdmin(user) {
  const profilRef = doc(db, 'users', user.uid)
  const profilSnap = await getDoc(profilRef)

  if (!profilSnap.exists()) {
    throw new Error('Profil super admin introuvable dans Firestore.')
  }

  const profil = profilSnap.data()

  if (profil.role !== SUPER_ADMIN_ROLE) {
    throw new Error('Ce compte Firebase n a pas le role super admin.')
  }

  return {
    uid: user.uid,
    email: user.email,
    nom: profil.nom ?? '',
    prenom: profil.prenom ?? '',
    role: profil.role,
  }
}

export async function connecterSuperAdmin(email, password) {
  const credentials = await signInWithEmailAndPassword(auth, email, password)

  try {
    return await chargerProfilSuperAdmin(credentials.user)
  } catch (error) {
    await signOut(auth)
    throw error
  }
}

export function ecouterSessionSuperAdmin(callback) {
  return onAuthStateChanged(auth, async (user) => {
    if (!user) {
      callback(null)
      return
    }

    try {
      callback(await chargerProfilSuperAdmin(user))
    } catch {
      await signOut(auth)
      callback(null)
    }
  })
}

export function deconnecterSuperAdmin() {
  return signOut(auth)
}
