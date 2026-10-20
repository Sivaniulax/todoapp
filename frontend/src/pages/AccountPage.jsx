import { useNavigate } from 'react-router-dom'
import AccountForm from '../components/AccountForm'
import { useAuth } from '../hooks/useAuth'
import { formatDateTime } from '../utils/format'

export default function AccountPage() {
  const { user, isGuest, upgrade } = useAuth()
  const navigate = useNavigate()

  if (isGuest) {
    return (
      <div className="auth-card card">
        <h1>Keep your todos</h1>
        <p className="muted">
          Turn this guest session into a real account. Your {user.todos_count} todo(s) will move with you.
        </p>
        <AccountForm
          submitLabel="Create account"
          onSubmit={async (form) => {
            await upgrade(form)
            navigate('/todos')
          }}
        />
      </div>
    )
  }

  return (
    <div className="card">
      <h1>Account</h1>
      <dl className="details">
        <dt>Name</dt>
        <dd>{user.name}</dd>
        <dt>Email</dt>
        <dd>{user.email}</dd>
        <dt>Role</dt>
        <dd>
          <span className={`role-badge role-${user.role}`}>{user.role}</span>
        </dd>
        <dt>Todos</dt>
        <dd>{user.todos_count}</dd>
        <dt>Member since</dt>
        <dd>{formatDateTime(user.created_at)}</dd>
      </dl>
    </div>
  )
}
