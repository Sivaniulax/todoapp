<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

async function signOut() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <header class="navbar">
    <RouterLink to="/" class="brand">
      <span class="brand-mark">&#10003;</span>
      <span class="brand-name">TodoApp</span>
    </RouterLink>

    <nav v-if="auth.isAuthenticated" class="nav-links">
      <RouterLink to="/todos">Todos</RouterLink>
      <RouterLink v-if="!auth.isGuest" to="/categories">Categories</RouterLink>
      <RouterLink v-if="auth.isAdmin" to="/admin">Admin</RouterLink>
      <RouterLink to="/account">Account</RouterLink>
      <span class="role" :class="`role-${auth.user.role}`">{{ auth.user.role }}</span>
      <button type="button" class="btn btn-quiet" @click="signOut">Sign out</button>
    </nav>

    <nav v-else class="nav-links">
      <RouterLink to="/login">Sign in</RouterLink>
      <RouterLink to="/signup">Create account</RouterLink>
    </nav>
  </header>
</template>
