# TodoApp — Rails API + React

A full-stack todo app built to practise the fundamentals of **Ruby on Rails** (API) and **React** (Vite), with roles (guest / member / admin), JWT auth, tests, CI and a free deployment on **Render + Vercel**.

```
todoapp/
├── backend/      Rails 8 API (PostgreSQL, JWT, RSpec)
├── frontend/     React 19 + Vite + React Router
├── render.yaml   Render Blueprint (API + Postgres)
└── .github/      GitHub Actions CI
```

## Features

- Sign up / log in with email + password (JWT)
- **Guest mode**: try the app without an account (24h session, max 10 todos, no categories), then upgrade to a real account and keep the todos
- **Roles**: `guest`, `member`, `admin` — admins get a stats + users dashboard
- Todos with priority, due date, notes, category; toggle, edit, delete, "clear completed"
- Filter by status (all / pending / completed / overdue), priority and category, search, sort, paginate
- Categories with colors (members only)

## Concepts covered

### Rails (backend/)

| Concept | Where |
|---|---|
| Migrations, indexes, FKs (`on_delete`), functional unique index | `db/migrate/*` |
| Associations, `dependent:`, `counter_cache` | `app/models/*.rb` |
| Validations, custom validations, `normalizes` | `app/models/todo.rb`, `user.rb` |
| `enum` (roles, priority) | `app/models/user.rb`, `todo.rb` |
| Scopes, `sanitize_sql_like`, ranges in `where` | `app/models/todo.rb` |
| Callbacks (`before_save`) | `Todo#sync_completed_at` |
| `has_secure_password`, `authenticate_by` | `user.rb`, `auth_controller.rb` |
| JWT auth + role authorization (concern) | `app/controllers/concerns/authentication.rb` |
| Central error handling with `rescue_from` | `concerns/error_handling.rb`, `app/errors/api_error.rb` |
| Strong params with Rails 8 `params.expect` | all controllers |
| Versioned, namespaced routes, member/collection routes | `config/routes.rb` |
| Pagination (no gem) | `concerns/pagination.rb` |
| Query object | `app/queries/todos_query.rb` |
| Service object | `app/services/accounts/upgrade_guest.rb` |
| Serializers (plain Ruby) | `app/serializers/*` |
| Background job + rake task | `app/jobs/cleanup_expired_guests_job.rb`, `lib/tasks/guests.rake` |
| Rate limiting (Rails 8 `rate_limit`) | `auth_controller.rb` |
| CORS | `config/initializers/cors.rb` |
| Seeds | `db/seeds.rb` |
| RSpec: model, request, query, service, job specs + FactoryBot + shoulda-matchers | `spec/` |

### React (frontend/)

| Concept | Where |
|---|---|
| Components, props, lists & keys, conditional rendering | `src/components/*` |
| `useState`, controlled forms | `TodoForm.jsx`, `AccountForm.jsx` |
| `useEffect` + cleanup, avoiding stale responses | `hooks/useTodos.js`, `hooks/useDebounce.js` |
| `useReducer` | `utils/filters.js`, `pages/TodosPage.jsx` |
| `useMemo`, `useCallback` | `TodosPage.jsx`, `AuthProvider.jsx` |
| Context API + custom hook | `context/AuthProvider.jsx`, `hooks/useAuth.js` |
| Custom data hooks | `hooks/useTodos.js`, `hooks/useCategories.js` |
| Optimistic UI update with rollback | `useTodos.js#toggleTodo` |
| React Router: nested routes, layout, protected + role routes, redirects | `App.jsx`, `components/ProtectedRoute.jsx` |
| API layer with fetch, auth header, error class | `api/client.js`, `api/endpoints.js` |
| Env variables (`import.meta.env`) | `api/client.js`, `.env.example` |
| Testing with Vitest + Testing Library | `*.test.jsx` |

## API

All endpoints are under `/api/v1` and (except signup/login/guest) need `Authorization: Bearer <token>`.

| Method | Path | Who |
|---|---|---|
| POST | `/auth/signup` `/auth/login` `/auth/guest` | anyone |
| POST | `/auth/upgrade` | guest |
| GET | `/me` | logged in |
| GET/POST | `/todos` | logged in |
| GET/PATCH/DELETE | `/todos/:id` | owner |
| PATCH | `/todos/:id/toggle` | owner |
| DELETE | `/todos/clear_completed` | logged in |
| GET | `/categories` | logged in |
| POST/PATCH/DELETE | `/categories(/:id)` | member, admin |
| GET | `/admin/stats`, `/admin/users` | admin |

`GET /todos` accepts `status`, `q`, `priority`, `category_id`, `sort` (`newest`, `oldest`, `due_date`, `priority`), `page`, `per_page`.

## Run locally (Windows PowerShell)

Needs Ruby 3.2+, Rails 8, Node 20.19+ and PostgreSQL running locally.

**Backend** (terminal 1)

```powershell
cd backend
bundle install
$env:DB_PASSWORD = "your-postgres-password"   # DB_USERNAME defaults to "postgres"
ruby bin/rails db:prepare                     # create + migrate + seed
ruby bin/rails server                         # http://localhost:3000
```

Seeded demo login: `demo@todoapp.dev` / `password123`.
To make an admin locally, set `$env:ADMIN_EMAIL` and `$env:ADMIN_PASSWORD` and run `ruby bin/rails db:seed`.

Run tests: `bundle exec rspec` · lint: `bundle exec rubocop` · security: `bundle exec brakeman`

> First time: after `db:prepare`, commit the generated `backend/db/schema.rb` and `backend/Gemfile.lock`.
> Also run `bundle lock --add-platform x86_64-linux` once so Render and CI can use the lockfile.

**Frontend** (terminal 2)

```powershell
cd frontend
copy .env.example .env.local
npm install
npm run dev                                   # http://localhost:5173
```

Tests: `npm test` · lint: `npm run lint` · build: `npm run build`

## Deploy

1. **Push to GitHub**

   ```powershell
   git remote add origin https://github.com/<you>/todoapp.git
   git push -u origin main
   ```

2. **Backend + database on Render**
   - Render dashboard → **New → Blueprint** → select the repo. It reads `render.yaml` and creates `todoapp-api` + `todoapp-db`.
   - Fill in the prompted env vars: `FRONTEND_ORIGINS` (your Vercel URL — you can set it after step 3), and optionally `ADMIN_EMAIL` / `ADMIN_PASSWORD`.
   - Check `https://<your-api>.onrender.com/up` returns green.

3. **Frontend on Vercel**
   - Vercel → **Add New → Project** → import the repo → set **Root Directory** to `frontend`.
   - Add env var `VITE_API_URL=https://<your-api>.onrender.com` → Deploy.
   - Copy the Vercel URL into Render's `FRONTEND_ORIGINS` (comma-separate multiple URLs) and redeploy the API.

Free-tier notes: the Render API sleeps after ~15 min idle (first request takes ~30–60s), and the free Postgres database expires after 30 days unless upgraded.
