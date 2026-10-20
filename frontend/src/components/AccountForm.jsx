import { useState } from 'react'
import ErrorMessage from './ErrorMessage'

const EMPTY = { name: '', email: '', password: '', password_confirmation: '' }

// Shared by the signup page and the "upgrade guest account" page.
export default function AccountForm({ onSubmit, submitLabel }) {
  const [form, setForm] = useState(EMPTY)
  const [error, setError] = useState(null)
  const [details, setDetails] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  const handleChange = (event) => setForm({ ...form, [event.target.name]: event.target.value })

  const handleSubmit = async (event) => {
    event.preventDefault()
    if (form.password !== form.password_confirmation) {
      setError("Passwords don't match")
      setDetails(null)
      return
    }
    setSubmitting(true)
    setError(null)
    try {
      await onSubmit(form)
    } catch (err) {
      setError(err.message)
      setDetails(err.details)
      setSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="stack">
      <ErrorMessage error={error} details={details} />
      <label>
        Name
        <input name="name" value={form.name} onChange={handleChange} required autoComplete="name" />
      </label>
      <label>
        Email
        <input type="email" name="email" value={form.email} onChange={handleChange} required autoComplete="email" />
      </label>
      <label>
        Password <span className="muted small">(min 8 characters)</span>
        <input
          type="password"
          name="password"
          value={form.password}
          onChange={handleChange}
          required
          minLength={8}
          autoComplete="new-password"
        />
      </label>
      <label>
        Confirm password
        <input
          type="password"
          name="password_confirmation"
          value={form.password_confirmation}
          onChange={handleChange}
          required
          autoComplete="new-password"
        />
      </label>
      <button type="submit" className="btn btn-primary" disabled={submitting}>
        {submitting ? 'Saving…' : submitLabel}
      </button>
    </form>
  )
}
