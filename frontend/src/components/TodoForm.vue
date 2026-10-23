<script setup>
import { reactive, ref } from 'vue'
import ErrorMessage from '@/components/ErrorMessage.vue'
import { PRIORITIES } from '@/utils/format'

const props = defineProps({
  // A function rather than an event: emit cannot be awaited, and this form
  // needs to know whether the save succeeded.
  save: { type: Function, required: true },
  todo: { type: Object, default: null },
  categories: { type: Array, default: () => [] },
  submitLabel: { type: String, default: 'Add todo' },
  canCancel: { type: Boolean, default: false },
})

const emit = defineEmits(['cancel'])

const form = reactive({
  title: props.todo?.title ?? '',
  description: props.todo?.description ?? '',
  due_date: props.todo?.due_date ?? '',
  priority: props.todo?.priority ?? 'medium',
  category_id: props.todo?.category?.id ?? '',
  tag_names: (props.todo?.tags ?? []).join(', '),
})

const saving = ref(false)
const error = ref('')
const details = ref(null)

async function submit() {
  if (!form.title.trim()) {
    error.value = 'A todo needs a title'
    return
  }

  saving.value = true
  error.value = ''
  try {
    await props.save({
      ...form,
      title: form.title.trim(),
      due_date: form.due_date || null,
      category_id: form.category_id || null,
      tag_names: form.tag_names,
    })
  } catch (err) {
    error.value = err.message
    details.value = err.details
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <form class="stack" @submit.prevent="submit">
    <ErrorMessage :message="error" :details="details" @dismiss="error = ''" />

    <input v-model="form.title" placeholder="What needs doing?" maxlength="120" aria-label="Title" />

    <textarea v-model="form.description" rows="2" placeholder="Notes (optional)" aria-label="Notes" />

    <div class="filter-row">
      <input v-model="form.due_date" type="date" aria-label="Due date" />

      <select v-model="form.priority" aria-label="Priority">
        <option v-for="priority in PRIORITIES" :key="priority" :value="priority">{{ priority }}</option>
      </select>

      <select v-if="categories.length" v-model="form.category_id" aria-label="Category">
        <option value="">No category</option>
        <option v-for="category in categories" :key="category.id" :value="category.id">
          {{ category.name }}
        </option>
      </select>

      <input v-model="form.tag_names" placeholder="tags, comma separated" aria-label="Tags" />
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-ink" :disabled="saving">
        {{ saving ? 'Saving...' : submitLabel }}
      </button>
      <button v-if="canCancel" type="button" class="btn btn-quiet" @click="emit('cancel')">Cancel</button>
    </div>
  </form>
</template>
