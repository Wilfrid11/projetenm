import { initializeApp } from 'firebase/app'
import { getAuth } from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'

// Configuration Web du projet Firebase Quinca.
const firebaseConfig = {
  apiKey: 'AIzaSyC0emm416s0utNWAybRRhvzBy3xzcBpBHs',
  authDomain: 'quinca-944e7.firebaseapp.com',
  projectId: 'quinca-944e7',
  storageBucket: 'quinca-944e7.firebasestorage.app',
  messagingSenderId: '677835609085',
  appId: '1:677835609085:web:735e020255fb9bbe2aff94',
}

export const app = initializeApp(firebaseConfig)
export const auth = getAuth(app)
export const db = getFirestore(app)
