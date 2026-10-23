import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { useTodosStore } from '../todos'

vi.mock('@/api/endpoints', () => ({
  todosApi: {
    list: vi.fn(),
    transition: vi.fn(),
    clearCompleted: vi.fn(),
  },
}))

const { todosApi } = await import('@/api/endpoints')

function page(todos) {
  return { todos, meta: { page: 1, per_page: 10, total_pages: 1, total_count: todos.length, counts: {} } }
}

describe('todos store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('loads a page of todos', async () => {
    todosApi.list.mockResolvedValue(page([{ id: 1, title: 'One', status: 'pending' }]))
    const store = useTodosStore()

    await store.load()

    expect(store.items).toHaveLength(1)
    expect(store.loading).toBe(false)
  })

  it('keeps a failed load off the list', async () => {
    todosApi.list.mockRejectedValue(new Error('Cannot reach the server'))
    const store = useTodosStore()

    await store.load()

    expect(store.error).toBe('Cannot reach the server')
    expect(store.items).toEqual([])
  })

  it('ignores a stale response that lands after a newer one', async () => {
    const store = useTodosStore()
    let releaseFirst
    todosApi.list.mockReturnValueOnce(new Promise((resolve) => {
      releaseFirst = resolve
    }))
    todosApi.list.mockResolvedValueOnce(page([{ id: 2, title: 'Newest', status: 'pending' }]))

    const first = store.load()
    await store.load()
    releaseFirst(page([{ id: 1, title: 'Stale', status: 'pending' }]))
    await first

    expect(store.items.map((todo) => todo.title)).toEqual(['Newest'])
  })

  it('flips the status before the API answers', async () => {
    todosApi.list.mockResolvedValue(page([{ id: 1, title: 'One', status: 'pending' }]))
    todosApi.transition.mockResolvedValue({ todo: { id: 1, title: 'One', status: 'completed' } })
    const store = useTodosStore()
    await store.load()

    const settled = store.transition(1, 'complete')
    expect(store.items[0].status).toBe('completed')

    await settled
    expect(store.items[0].status).toBe('completed')
  })

  it('puts the status back when the API refuses the transition', async () => {
    todosApi.list.mockResolvedValue(page([{ id: 1, title: 'One', status: 'pending' }]))
    todosApi.transition.mockRejectedValue(new Error('Cannot archive a todo that is pending'))
    const store = useTodosStore()
    await store.load()

    await store.transition(1, 'archive')

    expect(store.items[0].status).toBe('pending')
    expect(store.error).toMatch(/cannot archive/i)
  })

  it('resets to the first page when a filter changes', async () => {
    todosApi.list.mockResolvedValue(page([]))
    const store = useTodosStore()
    store.filters.page = 4

    await store.applyFilters({ status: 'completed' })

    expect(store.filters.page).toBe(1)
    expect(store.filters.status).toBe('completed')
  })
})
