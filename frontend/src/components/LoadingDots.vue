<script setup>
defineProps({ label: { type: String, default: 'Loading' } })
</script>

<template>
  <p class="loading" role="status" aria-live="polite">
    <span class="dot" />
    {{ label }}&hellip;
  </p>
</template>
