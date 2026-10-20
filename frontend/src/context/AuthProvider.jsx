import { useCallback, useEffect, useMemo, useState } from 'react'
import { onUnauthorized, tokenStore } from '../api/client'
import { authApi } from '../api/endpoints'
import { AuthContext } from './auth-context'

// Holds the logged-in user for the whole app.
// Concepts: Context API, useState, useEffect, useCallback, useMemo.
export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  // "loading" is true while we check a token saved from a previous visit.
  const [loading, setLoading] = useState(() => Boolean(tokenStore.get()))

  const logout = useCallback(() => {
    tokenStore.clear()
    setUser(null)
  }, [])

  // Restore the session on first load.
  useEffect(() => {
    if (!tokenStore.get()) return
    authApi
      .me()
      .then((data) => setUser(data.user))
      .catch(() => tokenStore.clear())
      .finally(() => setLoading(false))
  }, [])

  // If any request comes back 401 (e.g. guest session expired) → log out.
  useEffect(() => onUnauthorized(logout), [logout])

  const handleAuthResponse = useCallback(({ token, user: nextUser }) => {
    tokenStore.set(token)
    setUser(nextUser)
    return nextUser
  }, [])

  const refreshUser = useCallback(async () => {
    const data = await authApi.me()
    setUser(data.user)
    return data.user
  }, [])

  const value = useMemo(
    () => ({
      user,
      loading,
      isAuthenticated: Boolean(user),
      isGuest: user?.role === 'guest',
      isAdmin: user?.role === 'admin',
      login: (email, password) => authApi.login(email, password).then(handleAuthResponse),
      signup: (form) => authApi.signup(form).then(handleAuthResponse),
      continueAsGuest: () => authApi.guest().then(handleAuthResponse),
      upgrade: (form) => authApi.upgrade(form).then(handleAuthResponse),
      refreshUser,
      logout,
    }),
    [user, loading, handleAuthResponse, refreshUser, logout],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
