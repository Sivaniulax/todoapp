import { api } from './client'

export const authApi = {
  signup: (user) => api.post('/auth/signup', { user }),
  login: (email, password) => api.post('/auth/login', { email, password }),
  logout: () => api.delete('/auth/logout'),
  guest: () => api.post('/auth/guest'),
  upgrade: (user) => api.post('/auth/upgrade', { user }),
  me: () => api.get('/me'),
}

export const todosApi = {
  list: (params) => api.get('/todos', params),
  trash: (params) => api.get('/todos/trash', params),
  create: (todo) => api.post('/todos', { todo }),
  bulkCreate: (todos) => api.post('/todos/bulk', { todos }),
  update: (id, todo) => api.patch(`/todos/${id}`, { todo }),
  remove: (id) => api.delete(`/todos/${id}`),
  clearCompleted: () => api.delete('/todos/clear_completed'),
  // One route per state transition; the model decides if it is allowed.
  transition: (id, event) => api.patch(`/todos/${id}/${event}`),
  moveToTrash: (id) => api.patch(`/todos/${id}/trash`),
  restore: (id) => api.patch(`/todos/${id}/restore`),
}

export const categoriesApi = {
  list: () => api.get('/categories'),
  create: (category) => api.post('/categories', { category }),
  update: (id, category) => api.patch(`/categories/${id}`, { category }),
  remove: (id) => api.delete(`/categories/${id}`),
}

export const tagsApi = {
  list: () => api.get('/tags'),
  remove: (id) => api.delete(`/tags/${id}`),
}

export const adminApi = {
  stats: () => api.get('/admin/stats'),
  users: (params) => api.get('/admin/users', params),
}
