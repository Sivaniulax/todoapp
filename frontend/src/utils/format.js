export const PRIORITIES = ['low', 'medium', 'high']

// Mirrors the AASM states on the Rails side.
export const STATUSES = [
  { value: 'pending', label: 'To do' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'completed', label: 'Done' },
  { value: 'archived', label: 'Archived' },
]

export function statusLabel(status) {
  return STATUSES.find((s) => s.value === status)?.label ?? status
}

export function formatDate(value) {
  if (!value) return ''
  // Dates from Rails look like "2026-10-20"; parse as local, not UTC.
  const [year, month, day] = value.split('-').map(Number)
  return new Date(year, month - 1, day).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

export function formatDateTime(value) {
  if (!value) return ''
  return new Date(value).toLocaleString(undefined, {
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
}

export function debounce(fn, delay = 400) {
  let timer
  const debounced = (...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => fn(...args), delay)
  }
  debounced.cancel = () => clearTimeout(timer)
  return debounced
}
