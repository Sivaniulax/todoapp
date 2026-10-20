import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'
import Spinner from './Spinner'

// Guards a group of routes. Optionally restricts them to certain roles.
export default function ProtectedRoute({ roles }) {
  const { user, loading } = useAuth()
  const location = useLocation()

  if (loading) return <Spinner />
  if (!user) return <Navigate to="/login" replace state={{ from: location }} />
  if (roles && !roles.includes(user.role)) {
    return (
      <div className="card">
        <h2>Not allowed</h2>
        <p>Your role ({user.role}) can't access this page.</p>
      </div>
    )
  }
  return <Outlet />
}
