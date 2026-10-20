import { useEffect, useState } from 'react'
import { adminApi } from '../api/endpoints'
import ErrorMessage from '../components/ErrorMessage'
import Pagination from '../components/Pagination'
import Spinner from '../components/Spinner'
import { formatDateTime } from '../utils/format'

export default function AdminPage() {
  const [stats, setStats] = useState(null)
  const [users, setUsers] = useState([])
  const [meta, setMeta] = useState({ page: 1, total_pages: 1 })
  const [page, setPage] = useState(1)
  const [error, setError] = useState(null)

  useEffect(() => {
    adminApi.stats().then(setStats).catch((err) => setError(err.message))
  }, [])

  useEffect(() => {
    adminApi
      .users({ page })
      .then((data) => {
        setUsers(data.users)
        setMeta(data.meta)
      })
      .catch((err) => setError(err.message))
  }, [page])

  return (
    <section>
      <h1>Admin</h1>
      <ErrorMessage error={error} />

      {!stats ? (
        <Spinner />
      ) : (
        <div className="stat-grid">
          <Stat label="Users" value={stats.users.total} />
          <Stat label="Members" value={stats.users.members} />
          <Stat label="Guests" value={stats.users.guests} />
          <Stat label="Todos" value={stats.todos.total} />
          <Stat label="Completed" value={stats.todos.completed} />
          <Stat label="Completion rate" value={`${stats.todos.completion_rate}%`} />
        </div>
      )}

      <div className="card">
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
              <th>Todos</th>
              <th>Joined</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr key={u.id}>
                <td>{u.name}</td>
                <td>{u.email}</td>
                <td>
                  <span className={`role-badge role-${u.role}`}>{u.role}</span>
                </td>
                <td>{u.todos_count}</td>
                <td>{formatDateTime(u.created_at)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pagination page={meta.page} totalPages={meta.total_pages} onPageChange={setPage} />
      </div>
    </section>
  )
}

function Stat({ label, value }) {
  return (
    <div className="card stat">
      <div className="stat-value">{value}</div>
      <div className="muted small">{label}</div>
    </div>
  )
}
