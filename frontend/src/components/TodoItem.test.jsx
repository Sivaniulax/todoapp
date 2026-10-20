import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import TodoItem from './TodoItem'

const todo = {
  id: 1,
  title: 'Write specs',
  description: 'request + model specs',
  completed: false,
  priority: 'high',
  due_date: '2026-01-01',
  overdue: true,
  category: { id: 3, name: 'Work', color: '#6366f1' },
}

describe('TodoItem', () => {
  it('renders the todo details', () => {
    render(<TodoItem todo={todo} categories={[]} onToggle={vi.fn()} onUpdate={vi.fn()} onDelete={vi.fn()} />)

    expect(screen.getByText('Write specs')).toBeInTheDocument()
    expect(screen.getByText('request + model specs')).toBeInTheDocument()
    expect(screen.getByText('high')).toBeInTheDocument()
    expect(screen.getByText('Work')).toBeInTheDocument()
    expect(screen.getByText(/Overdue/)).toBeInTheDocument()
  })

  it('calls onToggle and onDelete with the todo id', async () => {
    const user = userEvent.setup()
    const onToggle = vi.fn()
    const onDelete = vi.fn()
    render(<TodoItem todo={todo} categories={[]} onToggle={onToggle} onUpdate={vi.fn()} onDelete={onDelete} />)

    await user.click(screen.getByRole('checkbox'))
    await user.click(screen.getByRole('button', { name: 'Delete' }))

    expect(onToggle).toHaveBeenCalledWith(1)
    expect(onDelete).toHaveBeenCalledWith(1)
  })

  it('switches to an edit form and submits changes', async () => {
    const user = userEvent.setup()
    const onUpdate = vi.fn().mockResolvedValue({})
    render(<TodoItem todo={todo} categories={[]} onToggle={vi.fn()} onUpdate={onUpdate} onDelete={vi.fn()} />)

    await user.click(screen.getByRole('button', { name: 'Edit' }))
    const title = screen.getByLabelText('Title')
    await user.clear(title)
    await user.type(title, 'Write more specs')
    await user.click(screen.getByRole('button', { name: 'Save' }))

    expect(onUpdate).toHaveBeenCalledWith(1, expect.objectContaining({ title: 'Write more specs', priority: 'high' }))
  })
})
