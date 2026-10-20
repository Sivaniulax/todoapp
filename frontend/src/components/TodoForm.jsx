import { useState } from 'react'
import { PRIORITIES } from '../utils/format'

const EMPTY = { title: '', description: '', due_date: '', priority: 'medium', category_id: '' }

// Controlled form used for both "create" and "edit".
export default function TodoForm({ initialValues, categories = [], onSubmit, onCancel, submitLabel = 'Add todo' }) {
  const [form, setForm] = useState(() => ({ ...EMPTY, ...normalise(initialValues) }))
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState(null)

  const handleChange = (event) => {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
  }

  const handleSubmit = async (event) => {
    event.preventDefault()
    if (!form.title.trim()) {
      setError('Title is required')
      return
    }
    setSubmitting(true)
    setError(null)
    try {
      await onSubmit({
        ...form,
        title: form.title.trim(),
        due_date: form.due_date || null,
        category_id: form.category_id || null,
      })
      if (!initialValues) setForm(EMPTY) // reset after creating
    } catch (err) {
      setError(err.details ? Object.values(err.details).flat().join(', ') : err.message)
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <form className="todo-form" onSubmit={handleSubmit}>
      <div className="form-row">
        <input
          name="title"
          value={form.title}
          onChange={handleChange}
          placeholder="What needs to be done?"
          aria-label="Title"
          maxLength={120}
        />
        <button className="btn btn-primary" type="submit" disabled={submitting}>
          {submitting ? 'Saving…' : submitLabel}
        </button>
        {onCancel && (
          <button className="btn btn-ghost" type="button" onClick={onCancel}>
            Cancel
          </button>
        )}
      </div>

      <div className="form-row form-row-small">
        <label>
          Due
          <input type="date" name="due_date" value={form.due_date} onChange={handleChange} />
        </label>
        <label>
          Priority
          <select name="priority" value={form.priority} onChange={handleChange}>
            {PRIORITIES.map((p) => (
              <option key={p} value={p}>
                {p}
              </option>
            ))}
          </select>
        </label>
        {categories.length > 0 && (
          <label>
            Category
            <select name="category_id" value={form.category_id} onChange={handleChange}>
              <option value="">None</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </label>
        )}
      </div>

      <textarea
        name="description"
        value={form.description}
        onChange={handleChange}
        placeholder="Notes (optional)"
        aria-label="Description"
        rows={2}
      />

      {error && (
        <p className="field-error" role="alert">
          {error}
        </p>
      )}
    </form>
  )
}

function normalise(todo) {
  if (!todo) return {}
  return {
    title: todo.title ?? '',
    description: todo.description ?? '',
    due_date: todo.due_date ?? '',
    priority: todo.priority ?? 'medium',
    category_id: todo.category?.id ? String(todo.category.id) : '',
  }
}
