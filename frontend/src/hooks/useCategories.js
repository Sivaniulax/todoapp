import { useCallback, useEffect, useState } from 'react'
import { categoriesApi } from '../api/endpoints'

export function useCategories() {
  const [reloadKey, setReloadKey] = useState(0)
  const [state, setState] = useState({ loaded: false, categories: [], error: null })

  useEffect(() => {
    let ignore = false
    categoriesApi
      .list()
      .then((data) => !ignore && setState({ loaded: true, categories: data.categories, error: null }))
      .catch((err) => !ignore && setState((current) => ({ ...current, loaded: true, error: err.message })))
    return () => {
      ignore = true
    }
  }, [reloadKey])

  const reload = useCallback(() => setReloadKey((key) => key + 1), [])

  const createCategory = useCallback(
    async (category) => {
      await categoriesApi.create(category)
      reload()
    },
    [reload],
  )

  const updateCategory = useCallback(
    async (id, category) => {
      await categoriesApi.update(id, category)
      reload()
    },
    [reload],
  )

  const deleteCategory = useCallback(
    async (id) => {
      await categoriesApi.remove(id)
      reload()
    },
    [reload],
  )

  return {
    categories: state.categories,
    loading: !state.loaded,
    error: state.error,
    createCategory,
    updateCategory,
    deleteCategory,
    reload,
  }
}
