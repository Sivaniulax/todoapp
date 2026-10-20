import { Navigate, Route, Routes } from 'react-router-dom'
import Layout from './components/Layout'
import ProtectedRoute from './components/ProtectedRoute'
import PublicOnlyRoute from './components/PublicOnlyRoute'
import AccountPage from './pages/AccountPage'
import AdminPage from './pages/AdminPage'
import CategoriesPage from './pages/CategoriesPage'
import LoginPage from './pages/LoginPage'
import NotFoundPage from './pages/NotFoundPage'
import SignupPage from './pages/SignupPage'
import TodosPage from './pages/TodosPage'

// Routing table. Nested routes share the <Layout> (navbar + banner).
export default function App() {
  return (
    <Routes>
      <Route element={<Layout />}>
        <Route index element={<Navigate to="/todos" replace />} />

        <Route element={<PublicOnlyRoute />}>
          <Route path="login" element={<LoginPage />} />
          <Route path="signup" element={<SignupPage />} />
        </Route>

        <Route element={<ProtectedRoute />}>
          <Route path="todos" element={<TodosPage />} />
          <Route path="account" element={<AccountPage />} />
        </Route>

        {/* Role-based routes: guests can't manage categories, only admins see /admin */}
        <Route element={<ProtectedRoute roles={['member', 'admin']} />}>
          <Route path="categories" element={<CategoriesPage />} />
        </Route>
        <Route element={<ProtectedRoute roles={['admin']} />}>
          <Route path="admin" element={<AdminPage />} />
        </Route>

        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  )
}
