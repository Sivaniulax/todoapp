import { createContext } from 'react'

// The context object lives in its own file so AuthProvider.jsx only exports
// a component (keeps React Fast Refresh happy).
export const AuthContext = createContext(null)
