<script setup>
const props = defineProps({
  message: { type: String, default: '' },
  details: { type: Object, default: null },
})

defineEmits(['dismiss'])

// Rails sends field errors as { email: ["has already been taken"] }.
const fields = () => Object.entries(props.details ?? {})
</script>

<template>
  <div v-if="message" class="notice notice-error" role="alert">
    <div>
      <strong>{{ message }}</strong>
      <ul v-if="details">
        <li v-for="[field, messages] in fields()" :key="field">
          {{ field.replaceAll('_', ' ') }} {{ [].concat(messages).join(', ') }}
        </li>
      </ul>
    </div>
    <button type="button" class="btn btn-quiet" aria-label="Dismiss" @click="$emit('dismiss')">&times;</button>
  </div>
</template>
