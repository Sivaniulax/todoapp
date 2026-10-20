export const INITIAL_FILTERS = { status: 'all', priority: '', category_id: '', sort: 'newest', page: 1 }

// useReducer: good fit when several pieces of state change together.
// Changing any filter resets to page 1; changing page keeps the filters.
export function filtersReducer(state, action) {
  switch (action.type) {
    case 'update':
      return { ...state, ...action.changes, page: 1 }
    case 'page':
      return { ...state, page: action.page }
    case 'reset':
      return INITIAL_FILTERS
    default:
      throw new Error(`Unknown action: ${action.type}`)
  }
}
