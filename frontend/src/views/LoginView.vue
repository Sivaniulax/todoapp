<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import ErrorMessage from '@/components/ErrorMessage.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

const email = ref('')
const password = ref('')
const error = ref('')
const busy = ref(false)

async function run(action) {
  busy.value = true
  error.value = ''
  try {
    await action()
    router.push('/todos')
  } catch (err) {
    error.value = err.message
  } finally {
    busy.value = false
  }
}

const signIn = () => run(() => auth.login(email.value, password.value))
const asGuest = () => run(() => auth.continueAsGuest())
</script>

<template>
  <section class="card card-narrow">
    <h1 class="display">Sign in</h1>

    <ErrorMessage :message="error" @dismiss="error = ''" />

    <form class="stack" @submit.prevent="signIn">
      <label>
        Email
        <input v-model="email" type="email" required autocomplete="email" />
      </label>
      <label>
        Password
        <input v-model="password" type="password" required autocomplete="current-password" />
      </label>
      <button type="submit" class="btn btn-ink" :disabled="busy">Sign in</button>
    </form>

    <p class="divider"><span>or</span></p>

    <button type="button" class="btn btn-outline" :disabled="busy" @click="asGuest">
      Try it as a guest
    </button>

    <p class="muted">
      No account? <RouterLink to="/signup">Create one</RouterLink>.
    </p>
  </section>
</template>
