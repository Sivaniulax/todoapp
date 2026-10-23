import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { onUnauthorized } from '@/api/client'
import { authApi } from '@/api/endpoints'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  // False until we have asked the API who we are.
  const loaded = ref(false)

  const isAuthenticated = computed(() => Boolean(user.value))
  const isGuest = computed(() => user.value?.role === 'guest')
  const isAdmin = computed(() => user.value?.role === 'admin')

  function remember({ user: signedIn }) {
    user.value = signedIn
    loaded.value = true
    return signedIn
  }

  // The session cookie is httponly, so asking /me is the only way to know.
  async function restore() {
    try {
      remember(await authApi.me())
    } catch {
      user.value = null
      loaded.value = true
    }
  }

  async function logout() {
    try {
      await authApi.logout()
    } finally {
      user.value = null
    }
  }

  async function refresh() {
    user.value = (await authApi.me()).user
  }

  onUnauthorized(() => {
    user.value = null
  })

  return {
    user,
    loaded,
    isAuthenticated,
    isGuest,
    isAdmin,
    restore,
    refresh,
    logout,
    login: (email, password) => authApi.login(email, password).then(remember),
    signup: (form) => authApi.signup(form).then(remember),
    continueAsGuest: () => authApi.guest().then(remember),
    upgrade: (form) => authApi.upgrade(form).then(remember),
  }
})
