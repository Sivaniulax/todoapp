import { mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import TodoForm from '../TodoForm.vue'

describe('TodoForm', () => {
  it('refuses to submit without a title', async () => {
    const wrapper = mount(TodoForm)

    await wrapper.find('form').trigger('submit')

    expect(wrapper.emitted('submit')).toBeUndefined()
    expect(wrapper.text()).toContain('A todo needs a title')
  })

  it('trims the title and sends empty fields as null', async () => {
    const wrapper = mount(TodoForm)

    await wrapper.find('input[aria-label="Title"]').setValue('  Buy milk  ')
    await wrapper.find('form').trigger('submit')

    const [payload] = wrapper.emitted('submit')[0]
    expect(payload.title).toBe('Buy milk')
    expect(payload.due_date).toBeNull()
    expect(payload.category_id).toBeNull()
  })

  it('starts from the todo it was given', () => {
    const wrapper = mount(TodoForm, {
      props: {
        todo: { title: 'Existing', description: 'notes', priority: 'high', tags: ['work'], category: null },
      },
    })

    expect(wrapper.find('input[aria-label="Title"]').element.value).toBe('Existing')
    expect(wrapper.find('input[aria-label="Tags"]').element.value).toBe('work')
  })

  it('can be cancelled when the parent allows it', async () => {
    const wrapper = mount(TodoForm, { props: { canCancel: true } })

    await wrapper.findAll('button').at(-1).trigger('click')

    expect(wrapper.emitted('cancel')).toHaveLength(1)
  })

  it('shows the error the API sends back', async () => {
    const onSubmit = vi.fn(() => {
      throw Object.assign(new Error('Validation failed'), { details: { title: ['is too long'] } })
    })
    const wrapper = mount(TodoForm, { attrs: { onSubmit } })

    await wrapper.find('input[aria-label="Title"]').setValue('x')
    await wrapper.find('form').trigger('submit')
    await wrapper.vm.$nextTick()

    expect(wrapper.text()).toContain('Validation failed')
  })
})
