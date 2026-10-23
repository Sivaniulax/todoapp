import { mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import TodoForm from '../TodoForm.vue'

function render(props = {}) {
  return mount(TodoForm, { props: { save: vi.fn(), ...props } })
}

describe('TodoForm', () => {
  it('refuses to submit without a title', async () => {
    const save = vi.fn()
    const wrapper = render({ save })

    await wrapper.find('form').trigger('submit')

    expect(save).not.toHaveBeenCalled()
    expect(wrapper.text()).toContain('A todo needs a title')
  })

  it('trims the title and sends empty fields as null', async () => {
    const save = vi.fn()
    const wrapper = render({ save })

    await wrapper.find('input[aria-label="Title"]').setValue('  Buy milk  ')
    await wrapper.find('form').trigger('submit')

    expect(save).toHaveBeenCalledOnce()
    const payload = save.mock.calls[0][0]
    expect(payload.title).toBe('Buy milk')
    expect(payload.due_date).toBeNull()
    expect(payload.category_id).toBeNull()
  })

  it('starts from the todo it was given', () => {
    const wrapper = render({
      todo: { title: 'Existing', description: 'notes', priority: 'high', tags: ['work'], category: null },
    })

    expect(wrapper.find('input[aria-label="Title"]').element.value).toBe('Existing')
    expect(wrapper.find('input[aria-label="Tags"]').element.value).toBe('work')
  })

  it('can be cancelled when the parent allows it', async () => {
    const wrapper = render({ canCancel: true })

    await wrapper.findAll('button').at(-1).trigger('click')

    expect(wrapper.emitted('cancel')).toHaveLength(1)
  })

  // The save prop is a function, not an event, so a rejection lands here.
  it('shows the error the API sends back', async () => {
    const save = vi.fn().mockRejectedValue(
      Object.assign(new Error('Validation failed'), { details: { title: ['is too long'] } }),
    )
    const wrapper = render({ save })

    await wrapper.find('input[aria-label="Title"]').setValue('x')
    await wrapper.find('form').trigger('submit')
    await new Promise((resolve) => setTimeout(resolve))

    expect(wrapper.text()).toContain('Validation failed')
    expect(wrapper.text()).toContain('is too long')
  })
})
