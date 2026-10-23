import { defineStore } from 'pinia'
import { ref } from 'vue'
import { categoriesApi } from '@/api/endpoints'

export const useCategoriesStore = defineStore('categories', () => {
  const items = ref([])
  const loading = ref(false)
  const error = ref(null)

  async function load() {
    loading.value = true
    try {
      items.value = (await categoriesApi.list()).categories
      error.value = null
    } catch (err) {
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  async function add(category) {
    await categoriesApi.create(category)
    await load()
  }

  async function rename(id, category) {
    await categoriesApi.update(id, category)
    await load()
  }

  async function remove(id) {
    await categoriesApi.remove(id)
    await load()
  }

  return { items, loading, error, load, add, rename, remove }
})
