<script setup>
import { useAuthStore } from '@/stores/auth'
import { formatDateTime } from '@/utils/format'

const auth = useAuthStore()
</script>

<template>
  <p v-if="auth.isGuest" class="banner" role="status">
    You are browsing as a guest: up to {{ auth.user.limits.max_todos }} todos and no categories. This
    session ends {{ formatDateTime(auth.user.guest_expires_at) }}.
    <RouterLink to="/account">Create an account</RouterLink> to keep your work.
  </p>
</template>
