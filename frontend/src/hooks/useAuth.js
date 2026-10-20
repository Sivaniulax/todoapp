import { useContext } from 'react'
import { AuthContext } from '../context/auth-context'

// Custom hook: a friendlier way to read the AuthContext.
export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used inside <AuthProvider>')
  return context
}
