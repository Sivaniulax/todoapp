import { useState } from 'react'
import { formatDate } from '../utils/format'
import TodoForm from './TodoForm'

export default function TodoItem({ todo, categories, onToggle, onUpdate, onDelete }) {
  const [editing, setEditing] = useState(false)

  if (editing) {
    return (
      <li className="todo-item editing">
        <TodoForm
          initialValues={todo}
          categories={categories}
          submitLabel="Save"
          onCancel={() => setEditing(false)}
          onSubmit={async (values) => {
            await onUpdate(todo.id, values)
            setEditing(false)
          }}
        />
      </li>
    )
  }

  return (
    <li className={`todo-item ${todo.completed ? 'done' : ''} ${todo.overdue ? 'overdue' : ''}`}>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={() => onToggle(todo.id)}
        aria-label={`Mark "${todo.title}" as ${todo.completed ? 'not done' : 'done'}`}
      />

      <div className="todo-body">
        <div className="todo-title">{todo.title}</div>
        {todo.description && <div className="todo-description">{todo.description}</div>}
        <div className="todo-meta">
          <span className={`priority priority-${todo.priority}`}>{todo.priority}</span>
          {todo.category && (
            <span className="category-chip" style={{ '--chip': todo.category.color }}>
              {todo.category.name}
            </span>
          )}
          {todo.due_date && (
            <span className="due">
              {todo.overdue ? 'Overdue · ' : 'Due '}
              {formatDate(todo.due_date)}
            </span>
          )}
        </div>
      </div>

      <div className="todo-actions">
        <button type="button" className="btn btn-ghost" onClick={() => setEditing(true)}>
          Edit
        </button>
        <button type="button" className="btn btn-ghost btn-danger" onClick={() => onDelete(todo.id)}>
          Delete
        </button>
      </div>
    </li>
  )
}
