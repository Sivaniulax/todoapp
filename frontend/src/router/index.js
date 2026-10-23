import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import AccountView from '@/views/AccountView.vue'
import AdminView from '@/views/AdminView.vue'
import CategoriesView from '@/views/CategoriesView.vue'
import LoginView from '@/views/LoginView.vue'
import NotFoundView from '@/views/NotFoundView.vue'
import SignupView from '@/views/SignupView.vue'
import TodosView from '@/views/TodosView.vue'

const routes = [
  { path: '/', redirect: '/todos' },
  { path: '/login', component: LoginView, meta: { signedOutOnly: true } },
  { path: '/signup', component: SignupView, meta: { signedOutOnly: true } },
  { path: '/todos', component: TodosView, meta: { auth: true } },
  { path: '/account', component: AccountView, meta: { auth: true } },
  { path: '/categories', component: CategoriesView, meta: { auth: true, roles: ['member', 'admin'] } },
  { path: '/admin', component: AdminView, meta: { auth: true, roles: ['admin'] } },
  { path: '/:pathMatch(.*)*', component: NotFoundView },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()

  // One /me call on the first navigation tells us whether the cookie is good.
  if (!auth.loaded) await auth.restore()

  if (to.meta.auth && !auth.isAuthenticated) {
    return { path: '/login', query: { next: to.fullPath } }
  }

  if (to.meta.signedOutOnly && auth.isAuthenticated) return '/todos'

  if (to.meta.roles && !to.meta.roles.includes(auth.user.role)) return '/todos'

  return true
})

export default router
