import { Link } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'
import { formatDateTime } from '../utils/format'

// Conditional rendering: only shown to guest users.
export default function GuestBanner() {
  const { user, isGuest } = useAuth()
  if (!isGuest) return null

  return (
    <div className="guest-banner" role="status">
      You're exploring as a <strong>guest</strong> — up to {user.limits.max_todos} todos, no categories. This
      session expires {formatDateTime(user.guest_expires_at)}. <Link to="/account">Create an account</Link> to
      keep your todos.
    </div>
  )
}
