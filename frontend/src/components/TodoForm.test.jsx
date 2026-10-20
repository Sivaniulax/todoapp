import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import TodoForm from './TodoForm'

describe('TodoForm', () => {
  it('does not submit an empty title', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()
    render(<TodoForm onSubmit={onSubmit} />)

    await user.click(screen.getByRole('button', { name: 'Add todo' }))

    expect(onSubmit).not.toHaveBeenCalled()
    expect(screen.getByRole('alert')).toHaveTextContent('Title is required')
  })

  it('submits trimmed values and resets', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn().mockResolvedValue({})
    render(<TodoForm onSubmit={onSubmit} />)

    await user.type(screen.getByLabelText('Title'), '  Buy milk  ')
    await user.click(screen.getByRole('button', { name: 'Add todo' }))

    expect(onSubmit).toHaveBeenCalledWith({
      title: 'Buy milk',
      description: '',
      due_date: null,
      priority: 'medium',
      category_id: null,
    })
    expect(screen.getByLabelText('Title')).toHaveValue('')
  })

  it('shows server validation errors', async () => {
    const user = userEvent.setup()
    const error = Object.assign(new Error('Validation failed'), { details: { title: ['is too long'] } })
    render(<TodoForm onSubmit={vi.fn().mockRejectedValue(error)} />)

    await user.type(screen.getByLabelText('Title'), 'x')
    await user.click(screen.getByRole('button', { name: 'Add todo' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('is too long')
  })
})
