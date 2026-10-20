import { NavLink, useNavigate } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'

export default function Navbar() {
  const { user, isAuthenticated, isGuest, isAdmin, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <header className="navbar">
      <NavLink to="/" className="brand">
        ✓ TodoApp
      </NavLink>

      {isAuthenticated ? (
        <nav className="nav-links">
          <NavLink to="/todos">Todos</NavLink>
          {!isGuest && <NavLink to="/categories">Categories</NavLink>}
          {isAdmin && <NavLink to="/admin">Admin</NavLink>}
          <NavLink to="/account">Account</NavLink>
          <span className={`role-badge role-${user.role}`}>{user.role}</span>
          <button type="button" className="btn btn-ghost" onClick={handleLogout}>
            Log out
          </button>
        </nav>
      ) : (
        <nav className="nav-links">
          <NavLink to="/login">Log in</NavLink>
          <NavLink to="/signup">Sign up</NavLink>
        </nav>
      )}
    </header>
  )
}
