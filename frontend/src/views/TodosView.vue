<script setup>
import { computed, onMounted, ref } from 'vue'
import ErrorMessage from '@/components/ErrorMessage.vue'
import LoadingDots from '@/components/LoadingDots.vue'
import PaginationNav from '@/components/PaginationNav.vue'
import TodoFilters from '@/components/TodoFilters.vue'
import TodoForm from '@/components/TodoForm.vue'
import TodoItem from '@/components/TodoItem.vue'
import { useAuthStore } from '@/stores/auth'
import { useCategoriesStore } from '@/stores/categories'
import { useTodosStore } from '@/stores/todos'
import { debounce } from '@/utils/format'

const auth = useAuthStore()
const todos = useTodosStore()
const categories = useCategoriesStore()

const editing = ref(null)
const bulkText = ref('')
const showBulk = ref(false)

onMounted(() => {
  todos.load()
  if (!auth.isGuest) categories.load()
})

const search = debounce((value) => todos.applyFilters({ q: value }), 400)

const atGuestLimit = computed(() => {
  const limit = auth.user?.limits?.max_todos
  return Boolean(limit) && todos.meta.counts?.all >= limit
})

async function add(values) {
  await todos.add(values)
  if (auth.isGuest) auth.refresh()
}

async function saveEdit(values) {
  await todos.update(editing.value.id, values)
  editing.value = null
}

async function addMany() {
  await todos.addMany({ titles_text: bulkText.value })
  bulkText.value = ''
  showBulk.value = false
}
</script>

<template>
  <section class="stack-wide">
    <header class="page-head">
      <h1 class="display">Todos</h1>
      <button type="button" class="btn btn-quiet" @click="showBulk = !showBulk">
        {{ showBulk ? 'Single todo' : 'Paste a list' }}
      </button>
    </header>

    <div class="card">
      <form v-if="showBulk" class="stack" @submit.prevent="addMany">
        <label>
          One title per line
          <textarea v-model="bulkText" rows="4" placeholder="Buy milk, then walk the dog" />
        </label>
        <button type="submit" class="btn btn-ink" :disabled="!bulkText.trim()">Add them all</button>
      </form>

      <TodoForm v-else :categories="categories.items" @submit="add" />

      <p v-if="atGuestLimit" class="muted">
        That is the guest limit. <RouterLink to="/account">Create an account</RouterLink> for more.
      </p>
    </div>

    <TodoFilters
      :filters="todos.filters"
      :counts="todos.meta.counts"
      :categories="categories.items"
      @change="todos.applyFilters"
      @search="search"
    />

    <ErrorMessage :message="todos.error ?? ''" @dismiss="todos.error = null" />

    <LoadingDots v-if="todos.loading && !todos.items.length" label="Fetching your todos" />

    <p v-else-if="!todos.items.length" class="empty">Nothing here yet.</p>

    <ul v-else class="todo-list">
      <template v-for="todo in todos.items" :key="todo.id">
        <li v-if="editing?.id === todo.id" class="todo">
          <TodoForm
            :todo="todo"
            :categories="categories.items"
            submit-label="Save changes"
            can-cancel
            @submit="saveEdit"
            @cancel="editing = null"
          />
        </li>
        <TodoItem
          v-else
          :todo="todo"
          @fire="todos.transition(todo.id, $event)"
          @edit="editing = todo"
          @trash="todos.moveToTrash(todo.id)"
        />
      </template>
    </ul>

    <PaginationNav :page="todos.meta.page" :total-pages="todos.meta.total_pages" @change="todos.goToPage" />

    <footer v-if="todos.meta.counts?.completed" class="page-foot">
      <button type="button" class="btn btn-outline" @click="todos.clearCompleted()">
        Delete the {{ todos.meta.counts.completed }} finished todos
      </button>
    </footer>
  </section>
</template>
