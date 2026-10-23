<script setup>
import { computed } from 'vue'
import { formatDate, statusLabel } from '@/utils/format'

const props = defineProps({
  todo: { type: Object, required: true },
  canEdit: { type: Boolean, default: true },
})

const emit = defineEmits(['fire', 'edit', 'trash', 'destroy'])

// The API tells us which transitions are legal from the current state.
const EVENT_LABELS = {
  start: 'Start',
  complete: 'Done',
  reopen: 'Reopen',
  archive: 'Archive',
}

const events = computed(() => props.todo.allowed_events ?? [])
</script>

<template>
  <li class="todo" :class="[`todo-${todo.status}`, { 'todo-late': todo.overdue }]">
    <div class="todo-head">
      <h3 class="todo-title">{{ todo.title }}</h3>
      <span class="status" :class="`status-${todo.status}`">{{ statusLabel(todo.status) }}</span>
    </div>

    <p v-if="todo.description" class="todo-notes">{{ todo.description }}</p>

    <dl class="todo-meta">
      <div v-if="todo.due_date">
        <dt>Due</dt>
        <dd :class="{ late: todo.overdue }">{{ formatDate(todo.due_date) }}</dd>
      </div>
      <div>
        <dt>Priority</dt>
        <dd>{{ todo.priority }}</dd>
      </div>
      <div v-if="todo.category">
        <dt>Category</dt>
        <dd>
          <span class="swatch" :style="{ background: todo.category.color }" />
          {{ todo.category.name }}
        </dd>
      </div>
      <div v-if="todo.tags.length">
        <dt>Tags</dt>
        <dd>
          <span v-for="tag in todo.tags" :key="tag" class="chip">{{ tag }}</span>
        </dd>
      </div>
    </dl>

    <div v-if="canEdit" class="todo-actions">
      <button
        v-for="event in events"
        :key="event"
        type="button"
        class="btn btn-quiet"
        @click="emit('fire', event)"
      >
        {{ EVENT_LABELS[event] ?? event }}
      </button>
      <span class="spacer" />
      <button type="button" class="btn btn-quiet" @click="emit('edit')">Edit</button>
      <button type="button" class="btn btn-quiet" @click="emit('trash')">Trash</button>
    </div>
  </li>
</template>
