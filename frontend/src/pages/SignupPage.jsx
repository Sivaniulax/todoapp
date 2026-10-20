import { Link, useNavigate } from 'react-router-dom'
import AccountForm from '../components/AccountForm'
import { useAuth } from '../hooks/useAuth'

export default function SignupPage() {
  const { signup } = useAuth()
  const navigate = useNavigate()

  return (
    <div className="auth-card card">
      <h1>Create your account</h1>
      <AccountForm
        submitLabel="Sign up"
        onSubmit={async (form) => {
          await signup(form)
          navigate('/todos', { replace: true })
        }}
      />
      <p className="muted small">
        Already have an account? <Link to="/login">Log in</Link>
      </p>
    </div>
  )
}
