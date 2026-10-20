import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'
import Spinner from './Spinner'

// Login/signup pages: if you're already logged in, go to your todos.
export default function PublicOnlyRoute() {
  const { user, loading } = useAuth()
  if (loading) return <Spinner />
  return user ? <Navigate to="/todos" replace /> : <Outlet />
}
