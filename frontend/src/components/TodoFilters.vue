<script setup>
import { computed } from 'vue'
import { PRIORITIES } from '@/utils/format'

const props = defineProps({
  filters: { type: Object, required: true },
  counts: { type: Object, default: () => ({}) },
  categories: { type: Array, default: () => [] },
})

const emit = defineEmits(['change', 'search'])

const TABS = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'To do' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'completed', label: 'Done' },
  { value: 'overdue', label: 'Overdue' },
]

const tabs = computed(() => TABS)

function pick(field, event) {
  emit('change', { [field]: event.target.value })
}
</script>

<template>
  <section class="filters">
    <div class="tabs" role="tablist">
      <button
        v-for="tab in tabs"
        :key="tab.value"
        type="button"
        role="tab"
        class="tab"
        :class="{ 'tab-on': props.filters.status === tab.value }"
        :aria-selected="props.filters.status === tab.value"
        @click="emit('change', { status: tab.value })"
      >
        {{ tab.label }}
        <span v-if="counts[tab.value] !== undefined" class="tally">{{ counts[tab.value] }}</span>
      </button>
    </div>

    <div class="filter-row">
      <input
        type="search"
        placeholder="Search todos"
        aria-label="Search todos"
        :value="props.filters.q"
        @input="emit('search', $event.target.value)"
      />

      <select :value="props.filters.priority" aria-label="Priority" @change="pick('priority', $event)">
        <option value="">Any priority</option>
        <option v-for="priority in PRIORITIES" :key="priority" :value="priority">{{ priority }}</option>
      </select>

      <select
        v-if="categories.length"
        :value="props.filters.category_id"
        aria-label="Category"
        @change="pick('category_id', $event)"
      >
        <option value="">Any category</option>
        <option v-for="category in categories" :key="category.id" :value="category.id">
          {{ category.name }}
        </option>
      </select>

      <select :value="props.filters.sort" aria-label="Sort" @change="pick('sort', $event)">
        <option value="newest">Newest first</option>
        <option value="oldest">Oldest first</option>
        <option value="due_date">By due date</option>
        <option value="priority">By priority</option>
      </select>
    </div>
  </section>
</template>
