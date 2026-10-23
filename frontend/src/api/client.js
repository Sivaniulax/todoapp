export const API_URL = (import.meta.env.VITE_API_URL || 'http://localhost:3000').replace(/\/$/, '')

// The session lives in a cookie the API sets, so every request has to opt
// into sending it.
const CREDENTIALS = 'include'

// A 401 from one of these means "wrong details", not "session gone".
const SIGN_IN_PATHS = ['/auth/login', '/auth/signup', '/auth/guest']

export class ApiError extends Error {
  constructor(message, status, details = {}) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.details = details
  }
}

const unauthorizedListeners = new Set()

// Fires when the API says the session is gone, so the auth store can clear it.
export function onUnauthorized(listener) {
  unauthorizedListeners.add(listener)
  return () => unauthorizedListeners.delete(listener)
}

function buildQuery(params = {}) {
  const search = new URLSearchParams()
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && value !== '') search.append(key, value)
  }
  const query = search.toString()
  return query ? `?${query}` : ''
}

export async function request(path, { method = 'GET', body, params } = {}) {
  const headers = { Accept: 'application/json' }
  if (body !== undefined) headers['Content-Type'] = 'application/json'

  let response
  try {
    response = await fetch(`${API_URL}/api/v1${path}${buildQuery(params)}`, {
      method,
      headers,
      credentials: CREDENTIALS,
      body: body !== undefined ? JSON.stringify(body) : undefined,
    })
  } catch {
    throw new ApiError('Cannot reach the server. Is the API running?', 0)
  }

  if (response.status === 204) return null

  const data = await response.json().catch(() => ({}))

  if (!response.ok) {
    if (response.status === 401 && !SIGN_IN_PATHS.includes(path)) {
      unauthorizedListeners.forEach((listener) => listener())
    }
    throw new ApiError(data.error || `Request failed (${response.status})`, response.status, data.details)
  }

  return data
}

export const api = {
  get: (path, params) => request(path, { params }),
  post: (path, body) => request(path, { method: 'POST', body: body ?? {} }),
  patch: (path, body) => request(path, { method: 'PATCH', body: body ?? {} }),
  delete: (path) => request(path, { method: 'DELETE' }),
}
