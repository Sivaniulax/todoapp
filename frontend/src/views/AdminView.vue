<script setup>
import { onMounted, ref } from 'vue'
import ErrorMessage from '@/components/ErrorMessage.vue'
import LoadingDots from '@/components/LoadingDots.vue'
import PaginationNav from '@/components/PaginationNav.vue'
import { adminApi } from '@/api/endpoints'
import { formatDate } from '@/utils/format'

const stats = ref(null)
const users = ref([])
const meta = ref({ page: 1, total_pages: 1 })
const error = ref('')
const loading = ref(true)

async function load(page = 1) {
  loading.value = true
  try {
    const [statsData, usersData] = await Promise.all([adminApi.stats(), adminApi.users({ page })])
    stats.value = statsData
    users.value = usersData.users
    meta.value = usersData.meta
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(() => load())
</script>

<template>
  <section class="stack-wide">
    <h1 class="display">Admin</h1>

    <ErrorMessage :message="error" @dismiss="error = ''" />
    <LoadingDots v-if="loading" label="Counting" />

    <template v-else-if="stats">
      <div class="tiles">
        <div class="tile">
          <span class="tile-figure">{{ stats.users.total }}</span>
          <span class="tile-label">Accounts</span>
          <span class="muted">
            {{ stats.users.members }} members, {{ stats.users.guests }} guests,
            {{ stats.users.admins }} admins
          </span>
        </div>
        <div class="tile">
          <span class="tile-figure">{{ stats.todos.total }}</span>
          <span class="tile-label">Todos</span>
          <span class="muted">{{ stats.todos.trashed }} in the trash</span>
        </div>
        <div class="tile">
          <span class="tile-figure">{{ stats.todos.completion_rate }}%</span>
          <span class="tile-label">Finished</span>
          <span class="muted">{{ stats.todos.overdue }} overdue</span>
        </div>
      </div>

      <h2>Accounts</h2>
      <table class="table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th>Todos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td>{{ user.name }}</td>
            <td>{{ user.email ?? 'guest' }}</td>
            <td>{{ user.role }}</td>
            <td>{{ user.todos_count }}</td>
          </tr>
        </tbody>
      </table>

      <PaginationNav :page="meta.page" :total-pages="meta.total_pages" @change="load" />
    </template>
  </section>
</template>
