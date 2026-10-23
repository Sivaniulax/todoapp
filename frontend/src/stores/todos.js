import { defineStore } from 'pinia'
import { reactive, ref } from 'vue'
import { todosApi } from '@/api/endpoints'

const EMPTY_META = { page: 1, per_page: 10, total_pages: 1, total_count: 0, counts: {} }

export const useTodosStore = defineStore('todos', () => {
  const items = ref([])
  const meta = ref({ ...EMPTY_META })
  const loading = ref(false)
  const error = ref(null)

  const filters = reactive({
    status: 'all',
    priority: '',
    category_id: '',
    tag: '',
    sort: 'newest',
    q: '',
    page: 1,
    per_page: 10,
  })

  // Every request is numbered so a slow response cannot overwrite a newer one.
  let latestRequest = 0

  async function load() {
    const request = ++latestRequest
    loading.value = true
    try {
      const data = await todosApi.list({ ...filters })
      if (request !== latestRequest) return
      items.value = data.todos
      meta.value = data.meta
      error.value = null
    } catch (err) {
      if (request === latestRequest) error.value = err.message
    } finally {
      if (request === latestRequest) loading.value = false
    }
  }

  function applyFilters(patch) {
    Object.assign(filters, patch, { page: 1 })
    return load()
  }

  function goToPage(page) {
    filters.page = page
    return load()
  }

  async function add(values) {
    const { todo } = await todosApi.create(values)
    await load()
    return todo
  }

  async function addMany(values) {
    const { todos } = await todosApi.bulkCreate(values)
    await load()
    return todos
  }

  async function update(id, values) {
    const { todo } = await todosApi.update(id, values)
    replace(todo)
    return todo
  }

  // Flip the status straight away, put it back if the API disagrees.
  async function transition(id, event) {
    const todo = items.value.find((item) => item.id === id)
    const previous = todo?.status
    if (todo) todo.status = eventResult(event)

    try {
      replace((await todosApi.transition(id, event)).todo)
    } catch (err) {
      if (todo) todo.status = previous
      error.value = err.message
    }
  }

  async function moveToTrash(id) {
    await todosApi.moveToTrash(id)
    await load()
  }

  async function remove(id) {
    await todosApi.remove(id)
    await load()
  }

  async function clearCompleted() {
    const { deleted_count: deleted } = await todosApi.clearCompleted()
    await load()
    return deleted
  }

  function replace(todo) {
    const index = items.value.findIndex((item) => item.id === todo.id)
    if (index !== -1) items.value[index] = todo
  }

  function eventResult(event) {
    return { start: 'in_progress', complete: 'completed', reopen: 'pending', archive: 'archived' }[event]
  }

  return {
    items,
    meta,
    loading,
    error,
    filters,
    load,
    applyFilters,
    goToPage,
    add,
    addMany,
    update,
    transition,
    moveToTrash,
    remove,
    clearCompleted,
  }
})
