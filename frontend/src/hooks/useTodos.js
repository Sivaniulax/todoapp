import { useCallback, useEffect, useState } from 'react'
import { todosApi } from '../api/endpoints'

const EMPTY_META = { page: 1, per_page: 10, total_pages: 1, total_count: 0, counts: {} }

// Custom hook that owns all todo state: fetching, filters, pagination and
// mutations. Components stay small and just call these functions.
export function useTodos(filters) {
  const [reloadKey, setReloadKey] = useState(0)
  // Every distinct (filters, reload) pair is one "request". We remember which
  // request the current data belongs to, so `loading` can be derived instead
  // of being set by hand inside the effect.
  const requestKey = `${JSON.stringify(filters)}#${reloadKey}`
  const [result, setResult] = useState({ key: null, todos: [], meta: EMPTY_META, error: null })
  const [actionError, setActionError] = useState(null)

  useEffect(() => {
    let ignore = false // avoids applying a stale response after filters changed
    todosApi
      .list(filters)
      .then((data) => !ignore && setResult({ key: requestKey, todos: data.todos, meta: data.meta, error: null }))
      .catch((err) => !ignore && setResult((current) => ({ ...current, key: requestKey, error: err.message })))
    return () => {
      ignore = true
    }
  }, [filters, requestKey])

  const reload = useCallback(() => setReloadKey((key) => key + 1), [])

  const setTodos = (updater) => setResult((current) => ({ ...current, todos: updater(current.todos) }))

  const addTodo = useCallback(
    async (todo) => {
      await todosApi.create(todo)
      reload()
    },
    [reload],
  )

  const updateTodo = useCallback(async (id, changes) => {
    const { todo } = await todosApi.update(id, changes)
    setTodos((todos) => todos.map((t) => (t.id === id ? todo : t)))
    return todo
  }, [])

  // Optimistic update: flip the checkbox immediately, roll back on failure.
  const toggleTodo = useCallback(
    async (id) => {
      const flip = (todos) => todos.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t))
      setTodos(flip)
      try {
        await todosApi.toggle(id)
        reload() // counts and the current filter may have changed
      } catch (err) {
        setTodos(flip)
        setActionError(err.message)
      }
    },
    [reload],
  )

  const deleteTodo = useCallback(
    async (id) => {
      await todosApi.remove(id)
      reload()
    },
    [reload],
  )

  const clearCompleted = useCallback(async () => {
    const data = await todosApi.clearCompleted()
    reload()
    return data.deleted_count
  }, [reload])

  return {
    todos: result.todos,
    meta: result.meta,
    initialLoading: result.key === null,
    loading: result.key !== requestKey,
    error: actionError || result.error,
    setError: setActionError,
    addTodo,
    updateTodo,
    toggleTodo,
    deleteTodo,
    clearCompleted,
    reload,
  }
}
