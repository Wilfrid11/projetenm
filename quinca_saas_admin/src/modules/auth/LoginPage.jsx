import { useState } from 'react'

import { connecterSuperAdmin } from '../../services/authService'

const EMAIL_SUPER_ADMIN = 'otris2026@gmail.com'

export function LoginPage() {
  const [email, setEmail] = useState(EMAIL_SUPER_ADMIN)
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [erreur, setErreur] = useState('')

  async function handleSubmit(event) {
    event.preventDefault()
    setErreur('')
    setLoading(true)

    try {
      await connecterSuperAdmin(email.trim(), password)
    } catch (error) {
      setErreur(error.message || 'Connexion impossible pour le moment.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="grid min-h-screen place-items-center bg-quinca-bg px-4 py-8">
      <section className="w-full max-w-md rounded-2xl border border-quinca-border bg-white p-6 shadow-sm">
        <div className="mb-6">
          <p className="text-xs font-bold uppercase text-quinca-orange">Quinca SaaS</p>
          <h1 className="mt-2 text-2xl font-black text-quinca-ink">
            Connexion super admin
          </h1>
          <p className="mt-2 text-sm text-quinca-muted">
            Acces reserve au suivi des quincailleries clientes.
          </p>
        </div>

        <form className="grid gap-4" onSubmit={handleSubmit}>
          <label className="grid gap-2 text-sm font-bold text-quinca-ink">
            Email
            <input
              className="rounded-xl border border-quinca-border bg-quinca-bg px-4 py-3 font-medium outline-none focus:border-quinca-blue"
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              autoComplete="email"
              required
            />
          </label>

          <label className="grid gap-2 text-sm font-bold text-quinca-ink">
            Mot de passe
            <input
              className="rounded-xl border border-quinca-border bg-quinca-bg px-4 py-3 font-medium outline-none focus:border-quinca-blue"
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              autoComplete="current-password"
              required
            />
          </label>

          {erreur && (
            <p className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
              {erreur}
            </p>
          )}

          <button
            className="rounded-xl bg-quinca-blue px-4 py-3 font-black text-white disabled:cursor-not-allowed disabled:opacity-60"
            type="submit"
            disabled={loading}
          >
            {loading ? 'Connexion...' : 'Se connecter'}
          </button>
        </form>
      </section>
    </main>
  )
}
