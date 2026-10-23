<script setup>
defineProps({
  page: { type: Number, required: true },
  totalPages: { type: Number, required: true },
})

defineEmits(['change'])
</script>

<template>
  <nav v-if="totalPages > 1" class="pagination" aria-label="Pagination">
    <button type="button" class="btn btn-quiet" :disabled="page <= 1" @click="$emit('change', page - 1)">
      &larr; Previous
    </button>
    <span class="pagination-label">Page {{ page }} of {{ totalPages }}</span>
    <button
      type="button"
      class="btn btn-quiet"
      :disabled="page >= totalPages"
      @click="$emit('change', page + 1)"
    >
      Next &rarr;
    </button>
  </nav>
</template>
