import { PRIORITIES } from '../utils/format'

const STATUSES = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'completed', label: 'Completed' },
  { value: 'overdue', label: 'Overdue' },
]

const SORTS = [
  { value: 'newest', label: 'Newest first' },
  { value: 'oldest', label: 'Oldest first' },
  { value: 'due_date', label: 'Due date' },
  { value: 'priority', label: 'Priority' },
]

// "Lifting state up": the filters live in TodosPage, this component only
// renders them and reports changes through onChange.
export default function TodoFilters({ filters, search, onSearchChange, onChange, categories, counts = {} }) {
  return (
    <div className="filters">
      <div className="status-tabs" role="tablist">
        {STATUSES.map(({ value, label }) => (
          <button
            key={value}
            type="button"
            role="tab"
            aria-selected={filters.status === value}
            className={`tab ${filters.status === value ? 'active' : ''}`}
            onClick={() => onChange({ status: value })}
          >
            {label}
            {counts[value] !== undefined && <span className="count">{counts[value]}</span>}
          </button>
        ))}
      </div>

      <div className="form-row form-row-small">
        <input
          type="search"
          placeholder="Search todos…"
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          aria-label="Search todos"
        />
        <select value={filters.priority} onChange={(e) => onChange({ priority: e.target.value })} aria-label="Priority">
          <option value="">Any priority</option>
          {PRIORITIES.map((p) => (
            <option key={p} value={p}>
              {p}
            </option>
          ))}
        </select>
        {categories.length > 0 && (
          <select
            value={filters.category_id}
            onChange={(e) => onChange({ category_id: e.target.value })}
            aria-label="Category"
          >
            <option value="">Any category</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        )}
        <select value={filters.sort} onChange={(e) => onChange({ sort: e.target.value })} aria-label="Sort">
          {SORTS.map(({ value, label }) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
      </div>
    </div>
  )
}
