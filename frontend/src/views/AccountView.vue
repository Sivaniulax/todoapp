<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import ErrorMessage from '@/components/ErrorMessage.vue'
import { useAuthStore } from '@/stores/auth'
import { formatDateTime } from '@/utils/format'

const auth = useAuthStore()
const router = useRouter()

const form = reactive({ name: '', email: '', password: '', password_confirmation: '' })
const error = ref('')
const details = ref(null)
const busy = ref(false)

async function upgrade() {
  if (form.password !== form.password_confirmation) {
    error.value = 'The two passwords do not match'
    return
  }

  busy.value = true
  error.value = ''
  try {
    await auth.upgrade({ ...form })
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
  <section class="card">
    <h1 class="display">Account</h1>

    <dl class="ledger">
      <div>
        <dt>Name</dt>
        <dd>{{ auth.user.name }}</dd>
      </div>
      <div>
        <dt>Email</dt>
        <dd>{{ auth.user.email ?? 'none (guest)' }}</dd>
      </div>
      <div>
        <dt>Role</dt>
        <dd>{{ auth.user.role }}</dd>
      </div>
      <div>
        <dt>Todos</dt>
        <dd>{{ auth.user.todos_count }}</dd>
      </div>
      <div v-if="auth.isGuest">
        <dt>Session ends</dt>
        <dd>{{ formatDateTime(auth.user.guest_expires_at) }}</dd>
      </div>
    </dl>

    <template v-if="auth.isGuest">
      <h2>Keep your todos</h2>
      <p class="muted">
        Guest sessions are deleted when they expire. Add an email and a password and this account becomes
        a real one, with the todos you already wrote.
      </p>

      <ErrorMessage :message="error" :details="details" @dismiss="error = ''" />

      <form class="stack" @submit.prevent="upgrade">
        <label>
          Name
          <input v-model="form.name" required autocomplete="name" />
        </label>
        <label>
          Email
          <input v-model="form.email" type="email" required autocomplete="email" />
        </label>
        <label>
          Password
          <input v-model="form.password" type="password" required minlength="8" autocomplete="new-password" />
        </label>
        <label>
          Confirm password
          <input v-model="form.password_confirmation" type="password" required autocomplete="new-password" />
        </label>
        <button type="submit" class="btn btn-ink" :disabled="busy">Upgrade this account</button>
      </form>
    </template>
  </section>
</template>
