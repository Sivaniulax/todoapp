import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import ErrorMessage from '../components/ErrorMessage'
import { useAuth } from '../hooks/useAuth'

export default function LoginPage() {
  const { login, continueAsGuest } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const redirectTo = location.state?.from?.pathname || '/todos'

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  const run = async (action) => {
    setSubmitting(true)
    setError(null)
    try {
      await action()
      navigate(redirectTo, { replace: true })
    } catch (err) {
      setError(err.message)
      setSubmitting(false)
    }
  }

  const handleSubmit = (event) => {
    event.preventDefault()
    run(() => login(email, password))
  }

  return (
    <div className="auth-card card">
      <h1>Welcome back</h1>
      <ErrorMessage error={error} />

      <form onSubmit={handleSubmit} className="stack">
        <label>
          Email
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
        </label>
        <label>
          Password
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            autoComplete="current-password"
          />
        </label>
        <button type="submit" className="btn btn-primary" disabled={submitting}>
          {submitting ? 'Logging in…' : 'Log in'}
        </button>
      </form>

      <div className="divider">or</div>

      <button type="button" className="btn btn-secondary" disabled={submitting} onClick={() => run(continueAsGuest)}>
        Continue as guest
      </button>

      <p className="muted small">
        No account? <Link to="/signup">Sign up</Link>
      </p>
    </div>
  )
}
