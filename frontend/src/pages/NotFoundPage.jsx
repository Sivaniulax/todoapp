import { Link } from 'react-router-dom'

export default function NotFoundPage() {
  return (
    <div className="card">
      <h1>404</h1>
      <p>That page doesn't exist.</p>
      <Link to="/">Go home</Link>
    </div>
  )
}
