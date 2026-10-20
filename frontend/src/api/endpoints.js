import { api } from './client'

export const authApi = {
  signup: (user) => api.post('/auth/signup', { user }),
  login: (email, password) => api.post('/auth/login', { email, password }),
  guest: () => api.post('/auth/guest'),
  upgrade: (user) => api.post('/auth/upgrade', { user }),
  me: () => api.get('/me'),
}

export const todosApi = {
  list: (params) => api.get('/todos', params),
  create: (todo) => api.post('/todos', { todo }),
  update: (id, todo) => api.patch(`/todos/${id}`, { todo }),
  toggle: (id) => api.patch(`/todos/${id}/toggle`),
  remove: (id) => api.delete(`/todos/${id}`),
  clearCompleted: () => api.delete('/todos/clear_completed'),
}

export const categoriesApi = {
  list: () => api.get('/categories'),
  create: (category) => api.post('/categories', { category }),
  update: (id, category) => api.patch(`/categories/${id}`, { category }),
  remove: (id) => api.delete(`/categories/${id}`),
}

export const adminApi = {
  stats: () => api.get('/admin/stats'),
  users: (params) => api.get('/admin/users', params),
}
