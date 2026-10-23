<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import ErrorMessage from '@/components/ErrorMessage.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

const form = reactive({ name: '', email: '', password: '', password_confirmation: '' })
const error = ref('')
const details = ref(null)
const busy = ref(false)

async function submit() {
  if (form.password !== form.password_confirmation) {
    error.value = 'The two passwords do not match'
    return
  }

  busy.value = true
  error.value = ''
  try {
    await auth.signup({ ...form })
    router.push('/todos')
  } catch (err) {
    error.value = err.message
    details.value = err.details
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <section class="card card-narrow">
    <h1 class="display">Create an account</h1>

    <ErrorMessage :message="error" :details="details" @dismiss="error = ''" />

    <form class="stack" @submit.prevent="submit">
      <label>
        Name
        <input v-model="form.name" required autocomplete="name" />
      </label>
      <label>
        Email
        <input v-model="form.email" type="email" required autocomplete="email" />
      </label>
      <label>
        Password <span class="muted">(8 characters or more)</span>
        <input v-model="form.password" type="password" required minlength="8" autocomplete="new-password" />
      </label>
      <label>
        Confirm password
        <input v-model="form.password_confirmation" type="password" required autocomplete="new-password" />
      </label>
      <button type="submit" class="btn btn-ink" :disabled="busy">Create account</button>
    </form>

    <p class="muted">
      Already registered? <RouterLink to="/login">Sign in</RouterLink>.
    </p>
  </section>
</template>
