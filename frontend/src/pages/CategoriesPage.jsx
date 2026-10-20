import { useState } from 'react'
import ErrorMessage from '../components/ErrorMessage'
import Spinner from '../components/Spinner'
import { useCategories } from '../hooks/useCategories'

const COLORS = ['#6366f1', '#ec4899', '#f59e0b', '#10b981', '#0ea5e9', '#ef4444']

export default function CategoriesPage() {
  const { categories, loading, error, createCategory, deleteCategory } = useCategories()
  const [name, setName] = useState('')
  const [color, setColor] = useState(COLORS[0])
  const [actionError, setActionError] = useState(null)

  const handleSubmit = async (event) => {
    event.preventDefault()
    setActionError(null)
    try {
      await createCategory({ name, color })
      setName('')
    } catch (err) {
      setActionError(err.details ? Object.values(err.details).flat().join(', ') : err.message)
    }
  }

  const handleDelete = async (category) => {
    if (!window.confirm(`Delete "${category.name}"? Its todos will keep existing without a category.`)) return
    try {
      await deleteCategory(category.id)
    } catch (err) {
      setActionError(err.message)
    }
  }

  return (
    <section>
      <h1>Categories</h1>

      <form className="card form-row" onSubmit={handleSubmit}>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="New category" required maxLength={30} />
        <div className="swatches" role="radiogroup" aria-label="Color">
          {COLORS.map((c) => (
            <button
              key={c}
              type="button"
              role="radio"
              aria-checked={color === c}
              aria-label={c}
              className={`swatch ${color === c ? 'selected' : ''}`}
              style={{ background: c }}
              onClick={() => setColor(c)}
            />
          ))}
        </div>
        <button className="btn btn-primary" type="submit">
          Add
        </button>
      </form>

      <ErrorMessage error={error || actionError} onDismiss={() => setActionError(null)} />

      {loading ? (
        <Spinner />
      ) : categories.length === 0 ? (
        <p className="empty">No categories yet.</p>
      ) : (
        <ul className="category-list">
          {categories.map((category) => (
            <li key={category.id} className="card category-row">
              <span className="category-chip" style={{ '--chip': category.color }}>
                {category.name}
              </span>
              <span className="muted small">{category.todos_count} todo(s)</span>
              <button type="button" className="btn btn-ghost btn-danger" onClick={() => handleDelete(category)}>
                Delete
              </button>
            </li>
          ))}
        </ul>
      )}
    </section>
  )
}
