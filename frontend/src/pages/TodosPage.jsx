import { useMemo, useReducer, useState } from 'react'
import ErrorMessage from '../components/ErrorMessage'
import Pagination from '../components/Pagination'
import Spinner from '../components/Spinner'
import TodoFilters from '../components/TodoFilters'
import TodoForm from '../components/TodoForm'
import TodoItem from '../components/TodoItem'
import { useAuth } from '../hooks/useAuth'
import { useCategories } from '../hooks/useCategories'
import { useDebounce } from '../hooks/useDebounce'
import { useTodos } from '../hooks/useTodos'
import { INITIAL_FILTERS, filtersReducer } from '../utils/filters'

export default function TodosPage() {
  const { user, isGuest, refreshUser } = useAuth()
  const [filters, dispatch] = useReducer(filtersReducer, INITIAL_FILTERS)
  const [search, setSearch] = useState('')
  const debouncedSearch = useDebounce(search)

  // useMemo keeps the same object between renders unless something changed,
  // so useTodos' effect only refetches when it should.
  const query = useMemo(() => ({ ...filters, q: debouncedSearch, per_page: 10 }), [filters, debouncedSearch])

  const { todos, meta, initialLoading, loading, error, setError, addTodo, updateTodo, toggleTodo, deleteTodo, clearCompleted } =
    useTodos(query)
  const { categories } = useCategories()

  const handleSearchChange = (value) => {
    setSearch(value)
    if (filters.page !== 1) dispatch({ type: 'page', page: 1 })
  }

  const handleAdd = async (values) => {
    await addTodo(values)
    if (isGuest) refreshUser() // keeps the guest "x / 10" counter in sync
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this todo?')) return
    try {
      await deleteTodo(id)
      if (isGuest) refreshUser()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleClearCompleted = async () => {
    try {
      await clearCompleted()
      if (isGuest) refreshUser()
    } catch (err) {
      setError(err.message)
    }
  }

  const counts = meta.counts || {}
  const guestLimitReached = isGuest && user.todos_count >= user.limits.max_todos

  return (
    <section>
      <div className="page-header">
        <h1>My todos</h1>
        {counts.completed > 0 && (
          <button type="button" className="btn btn-ghost" onClick={handleClearCompleted}>
            Clear completed ({counts.completed})
          </button>
        )}
      </div>

      <div className="card">
        {guestLimitReached ? (
          <p className="muted">
            Guest limit reached ({user.limits.max_todos} todos). Create an account to add more.
          </p>
        ) : (
          <TodoForm categories={categories} onSubmit={handleAdd} />
        )}
        {isGuest && (
          <p className="muted small">
            {user.todos_count} / {user.limits.max_todos} guest todos used
          </p>
        )}
      </div>

      <TodoFilters
        filters={filters}
        search={search}
        onSearchChange={handleSearchChange}
        onChange={(changes) => dispatch({ type: 'update', changes })}
        categories={categories}
        counts={counts}
      />

      <ErrorMessage error={error} onDismiss={() => setError(null)} />

      {initialLoading ? (
        <Spinner />
      ) : todos.length === 0 ? (
        <div className="empty">
          <p>Nothing here.</p>
          {(filters.status !== 'all' || filters.priority || filters.category_id || search) && (
            <button
              type="button"
              className="btn btn-ghost"
              onClick={() => {
                setSearch('')
                dispatch({ type: 'reset' })
              }}
            >
              Clear filters
            </button>
          )}
        </div>
      ) : (
        <ul className={`todo-list ${loading ? 'stale' : ''}`} aria-busy={loading}>
          {todos.map((todo) => (
            <TodoItem
              key={todo.id}
              todo={todo}
              categories={categories}
              onToggle={toggleTodo}
              onUpdate={updateTodo}
              onDelete={handleDelete}
            />
          ))}
        </ul>
      )}

      <Pagination
        page={meta.page}
        totalPages={meta.total_pages}
        onPageChange={(page) => dispatch({ type: 'page', page })}
      />
    </section>
  )
}
