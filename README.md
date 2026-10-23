# TodoApp

A full-stack todo app: a Rails 8 API and a React (Vite) frontend, with roles
(guest / member / admin), JWT auth, tests, CI, and a free-tier deployment on
Render + Vercel.

```
todoapp/
├── backend/      Rails 8 API (PostgreSQL, JWT, RSpec)
├── frontend/     React 19 + Vite + React Router
├── render.yaml   Render Blueprint (API + Postgres)
└── .github/      GitHub Actions CI
```

## Features

- Sign up / log in with email + password (JWT)
- Guest mode: try the app without an account (24h session, max 10 todos, no categories), then upgrade to a real account and keep the todos
- Roles: `guest`, `member`, `admin`. Admins get a stats and users dashboard
- Todos with priority, due date, notes, category; toggle, edit, delete, "clear completed"
- Filter by status (all / pending / completed / overdue), priority and category, search, sort, paginate
- Categories with colors (members only)
- Tags: free-form, created on demand, shared across a user's todos, filterable
- Trash: deleting a todo is reversible, with its own list and a restore action
- Bulk add: paste one title per line and they are created all-or-nothing
- A welcome email on signup, and a daily digest of what is due today

## How it's put together

**Backend** is a Rails 8 API, no view layer. Auth is Devise over a session
cookie: `database_authenticatable` for the password, `validatable` for the
email and password rules, `timeoutable` for the 24h expiry. Devise's own
controllers are skipped (`devise_for :users, skip: :all`) because
`Api::V1::AuthController` answers in JSON, and `concerns/authentication.rb`
wraps it so controllers still read `require_role :admin`. Controllers stay thin: filtering and
sorting live in `queries/todos_query.rb`, the guest upgrade in
`services/accounts/upgrade_guest.rb`, and responses go through plain-Ruby
serializers so nothing leaks by accident. Errors are raised as `ApiError`
subclasses and rendered in one place (`concerns/error_handling.rb`).
Pagination is 20 lines in a concern rather than a gem.

Soft delete and tagging are model concerns (`Trashable`, `Taggable`), tags
hang off a polymorphic join table so anything can be tagged later, and the
hex-colour rule is a reusable `HexColorValidator`. Bulk add is an ActiveModel
form object that writes the whole batch in one transaction. Concurrent edits
are caught by optimistic locking, which comes back as a 409. Background jobs
run on Solid Queue — Postgres-backed, so no Redis — scheduled from
`config/recurring.yml`, and mail goes through ActionMailer with previews at
`/rails/mailers`. User-facing strings live in `config/locales/en.yml`, and
the admin stats are cached rather than recounted on every request.

**Frontend** is React 19 on Vite. `AuthProvider` asks `/me` on startup, since
the session cookie is not readable from JavaScript, and clears the user on any
401; `useTodos` owns fetching, pagination and the optimistic toggle; filter
state is a reducer in `utils/filters.js` and the search box is debounced.
`api/client.js` is the only place that knows the base URL, the `credentials:
"include"` the cookie needs, and how an error comes back.

**Tests**: RSpec (models, requests, query, service, job) with FactoryBot and
shoulda-matchers; Vitest + Testing Library on the frontend. Both run in CI
along with RuboCop and Brakeman.

## API

All endpoints are under `/api/v1`. Everything except signup/login/guest needs the session cookie from one of those, so browser clients must send `credentials: "include"`.

| Method | Path | Who |
|---|---|---|
| POST | `/auth/signup` `/auth/login` `/auth/guest` | anyone |
| DELETE | `/auth/logout` | logged in |
| POST | `/auth/upgrade` | guest |
| GET | `/me` | logged in |
| GET/POST | `/todos` | logged in |
| GET/PATCH/DELETE | `/todos/:id` | owner |
| PATCH | `/todos/:id/toggle` | owner |
| PATCH | `/todos/:id/trash`, `/todos/:id/restore` | owner |
| GET | `/todos/trash` | logged in |
| POST | `/todos/bulk` | logged in |
| DELETE | `/todos/clear_completed` | logged in |
| GET | `/categories` | logged in |
| POST/PATCH/DELETE | `/categories(/:id)` | member, admin |
| GET | `/tags` | logged in |
| DELETE | `/tags/:id` | member, admin |
| GET | `/admin/stats`, `/admin/users` | admin |

`GET /todos` accepts `status`, `q`, `priority`, `category_id`, `tag`, `sort` (`newest`, `oldest`, `due_date`, `priority`), `page`, `per_page`. It returns only
todos that are not in the trash. `PATCH /todos/:id` accepts a `lock_version`; send the one you read and
you get a 409 instead of silently overwriting someone else's edit.

## Run locally (Windows PowerShell)

Needs Ruby 3.2+, Rails 8, Node 20.19+ and PostgreSQL running locally.

**Backend** (terminal 1)

```powershell
cd backend
bundle install
$env:DB_PASSWORD = "your-postgres-password"   # DB_USERNAME defaults to "postgres"
$env:DB_PORT = "5433"                         # only if Postgres is not on 5432 (PGPORT is also respected)
ruby bin/rails db:prepare                     # create + migrate + seed
ruby bin/rails server                         # http://localhost:3000
```

Seeded demo login: `demo@todoapp.dev` / `password123`.
To make an admin locally, set `$env:ADMIN_EMAIL` and `$env:ADMIN_PASSWORD` and run `ruby bin/rails db:seed`.

Run tests: `bundle exec rspec` · lint: `bundle exec rubocop` · security: `bundle exec brakeman`

Mail is never delivered in development — read it at <http://localhost:3000/rails/mailers>.
Jobs run in-process in development (`:async`), because Solid Queue's supervisor needs `fork`,
which Windows does not have. Production uses Solid Queue inside Puma; on Linux or macOS you can
also run a dedicated worker with `bin/jobs`. To run a scheduled job by hand:
`ruby bin/rails runner "DailyDigestJob.perform_now"`.

> On PostgreSQL 18, `db:prepare` can abort with "server closed the connection unexpectedly" when the
> database does not exist yet. Run `ruby bin/rails db:create` first, then `db:migrate` and `db:seed`.
> If `localhost` resolves to IPv6 and Postgres only listens on IPv4, set `$env:DB_HOST = "127.0.0.1"`.

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
   - Fill in the prompted env vars: `FRONTEND_ORIGINS` (your Vercel URL, which you can set after step 3), and optionally `ADMIN_EMAIL` / `ADMIN_PASSWORD`.
   - Check `https://<your-api>.onrender.com/up` returns green.

3. **Frontend on Vercel**
   - Vercel → **Add New → Project** → import the repo → set **Root Directory** to `frontend`.
   - Add env var `VITE_API_URL=https://<your-api>.onrender.com` → Deploy.
   - Copy the Vercel URL into Render's `FRONTEND_ORIGINS` (comma-separate multiple URLs) and redeploy the API.

Free-tier notes: the Render API sleeps after ~15 min idle (the first request
then takes 30-60s), and the free Postgres database expires after 30 days
unless upgraded.

### Serve the app and the API from one domain

This matters more than it looks. Login is a session cookie, so
`todoapp.vercel.app` calling `todoapp-api.onrender.com` is a third-party
cookie: Safari blocks those outright and Chrome is phasing them out, so a
split deployment logs people out immediately. Working around it with
`SESSION_COOKIE_SAME_SITE=none` also throws away the CSRF protection that
`SameSite=Lax` is providing - Lax is the reason this app needs no CSRF
tokens, because the browser never attaches the cookie to a cross-site write.

One origin fixes both. The easiest version is a Vercel rewrite:

```json
"rewrites": [
  { "source": "/api/:path*", "destination": "https://<your-api>.onrender.com/api/:path*" },
  { "source": "/(.*)", "destination": "/index.html" }
]
```

The API rule has to come first, or the catch-all swallows it.

Then drop `VITE_API_URL` so the client calls its own origin, and put the
Vercel URL in `FRONTEND_ORIGINS`. Locally nothing is needed: `localhost:5173`
and `localhost:3000` count as the same site.
