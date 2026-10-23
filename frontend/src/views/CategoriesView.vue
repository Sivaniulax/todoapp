<script setup>
import { onMounted, reactive, ref } from 'vue'
import ErrorMessage from '@/components/ErrorMessage.vue'
import { useCategoriesStore } from '@/stores/categories'

const categories = useCategoriesStore()

const draft = reactive({ name: '', color: '#6366f1' })
const editing = ref(null)
const error = ref('')

onMounted(categories.load)

async function create() {
  error.value = ''
  try {
    await categories.add({ ...draft })
    draft.name = ''
  } catch (err) {
    error.value = err.message
  }
}

async function save(category) {
  error.value = ''
  try {
    await categories.rename(category.id, { name: category.name, color: category.color })
    editing.value = null
  } catch (err) {
    error.value = err.message
  }
}
</script>

<template>
  <section class="stack-wide">
    <h1 class="display">Categories</h1>

    <ErrorMessage :message="error" @dismiss="error = ''" />

    <div class="card">
      <form class="filter-row" @submit.prevent="create">
        <input v-model="draft.name" placeholder="New category" maxlength="30" required />
        <input v-model="draft.color" type="color" aria-label="Colour" />
        <button type="submit" class="btn btn-ink">Add</button>
      </form>
    </div>

    <ul class="plain-list">
      <li v-for="category in categories.items" :key="category.id" class="row">
        <template v-if="editing === category.id">
          <input v-model="category.name" maxlength="30" />
          <input v-model="category.color" type="color" aria-label="Colour" />
          <button type="button" class="btn btn-ink" @click="save(category)">Save</button>
          <button type="button" class="btn btn-quiet" @click="editing = null">Cancel</button>
        </template>
        <template v-else>
          <span class="swatch" :style="{ background: category.color }" />
          <span class="row-name">{{ category.name }}</span>
          <span class="muted">{{ category.todos_count }} todos</span>
          <button type="button" class="btn btn-quiet" @click="editing = category.id">Rename</button>
          <button type="button" class="btn btn-quiet" @click="categories.remove(category.id)">Delete</button>
        </template>
      </li>
    </ul>

    <p v-if="!categories.items.length" class="empty">No categories yet.</p>
  </section>
</template>
