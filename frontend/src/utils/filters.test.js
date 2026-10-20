import { describe, expect, it } from 'vitest'
import { filtersReducer } from './filters'

describe('filtersReducer', () => {
  const state = { status: 'all', priority: '', category_id: '', sort: 'newest', page: 3 }

  it('resets to page 1 when a filter changes', () => {
    expect(filtersReducer(state, { type: 'update', changes: { status: 'completed' } })).toEqual({
      ...state,
      status: 'completed',
      page: 1,
    })
  })

  it('changes page without touching filters', () => {
    expect(filtersReducer(state, { type: 'page', page: 5 })).toEqual({ ...state, page: 5 })
  })

  it('throws on unknown actions', () => {
    expect(() => filtersReducer(state, { type: 'nope' })).toThrow('Unknown action')
  })
})
