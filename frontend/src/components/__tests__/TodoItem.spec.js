import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import TodoItem from '../TodoItem.vue'

const RouterLink = { template: '<a><slot /></a>' }

function todo(overrides = {}) {
  return {
    id: 1,
    title: 'Post the letter',
    description: null,
    status: 'pending',
    due_date: null,
    priority: 'medium',
    overdue: false,
    tags: [],
    category: null,
    allowed_events: ['start', 'complete'],
    ...overrides,
  }
}

function render(props) {
  return mount(TodoItem, { props, global: { stubs: { RouterLink } } })
}

describe('TodoItem', () => {
  it('shows the title and the status', () => {
    const wrapper = render({ todo: todo({ status: 'in_progress' }) })

    expect(wrapper.text()).toContain('Post the letter')
    expect(wrapper.text()).toContain('In progress')
  })

  // The API decides which transitions are legal, not the component.
  it('offers a button per allowed event and nothing else', () => {
    const wrapper = render({ todo: todo({ allowed_events: ['reopen'] }) })
    const labels = wrapper.findAll('button').map((button) => button.text())

    expect(labels).toContain('Reopen')
    expect(labels).not.toContain('Done')
  })

  it('emits the event name when a transition is clicked', async () => {
    const wrapper = render({ todo: todo({ allowed_events: ['complete'] }) })

    await wrapper.findAll('button')[0].trigger('click')

    expect(wrapper.emitted('fire')[0]).toEqual(['complete'])
  })

  it('marks an overdue todo', () => {
    const wrapper = render({ todo: todo({ overdue: true, due_date: '2020-01-01' }) })

    expect(wrapper.classes()).toContain('todo-late')
  })

  it('hides the actions when editing is not allowed', () => {
    const wrapper = render({ todo: todo(), canEdit: false })

    expect(wrapper.find('.todo-actions').exists()).toBe(false)
  })

  it('lists tags and the category', () => {
    const wrapper = render({
      todo: todo({ tags: ['urgent', 'work'], category: { id: 2, name: 'Home', color: '#123456' } }),
    })

    expect(wrapper.text()).toContain('urgent')
    expect(wrapper.text()).toContain('Home')
  })
})
