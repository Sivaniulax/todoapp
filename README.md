# TodoApp

A todo app built to learn Rails past the scaffolding stage: roles and policies,
multi-tenancy, a state machine, an audit trail, background jobs and mail, with a
Vue 3 front end on top of a JSON API.

![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?logo=rubyonrails&logoColor=white)
![Vue](https://img.shields.io/badge/Vue-3.5-42B883?logo=vuedotjs&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-336791?logo=postgresql&logoColor=white)
![Tests](https://img.shields.io/badge/specs-164-success)

```
todoapp/
├── backend/      Rails 8.1 API (PostgreSQL, Devise, RSpec)
├── frontend/     Vue 3 + Vite + Pinia + Vue Router
├── docs/         How the pieces fit together
├── render.yaml   Render blueprint (API + database)
└── .github/      GitHub Actions CI
```

## What it does

- **Accounts** with email and password, or a **guest session** you can try
  without signing up (24 hours, 10 todos) and later upgrade without losing work.
- **Three roles.** Guests read, members manage their own things, admins get a
  dashboard and can tidy up anyone's todo.
- **Workspaces.** Every todo, category and tag belongs to one. Two people in the
  same workspace share its todos; nothing crosses between workspaces.
- **Todos** with a status that moves `pending → in progress → done → archived`,
  plus priority, due date, notes, categories and free-form tags.
- **Filter** by status, priority, category or tag, search the text, sort, paginate.
- **Trash** instead of deletion, with restore, and optimistic locking so two
  people editing the same todo get a conflict rather than a silent overwrite.
- **Bulk add** from pasted text, one title per line, all or nothing.
- **History** for every todo: who changed what, and when.
- **Mail**: a welcome note on signup and a daily digest of what is due.

## The stack, and what each gem is doing here

| Gem | Why it is here |
|---|---|
| [devise](https://github.com/heartcombo/devise) | Authentication over a session cookie. `database_authenticatable` for passwords, `validatable` for the email and password rules, `timeoutable` for a 24-hour session. Its controllers are skipped (`devise_for :users, skip: :all`) because the API answers in JSON. |
| [pundit](https://github.com/varvet/pundit) | Authorization. One policy class per model in `app/policies`, a scope per policy for index actions, and `after_action :verify_authorized` to catch an action that forgot to ask. |
| [acts_as_tenant](https://github.com/ErwinM/acts_as_tenant) | Multi-tenancy. The workspace is set once per request and added to every query on todos, categories and tags, so a forgotten `where` cannot leak another tenant's rows. |
| [aasm](https://github.com/aasm/aasm) | The todo status. Four states and only the sensible moves between them, which a boolean column cannot express. |
| [alba](https://github.com/okuramasafumi/alba) | Serialization. A resource per model in `app/resources`, explicit about which fields leave the API. |
| [pagy](https://github.com/ddnexus/pagy) | Pagination. Counts, slices and answers an empty last page instead of raising when a client asks for page 99. |
| [paper_trail](https://github.com/paper-trail-gem/paper_trail) | The audit trail, into `jsonb` columns so the payload stays queryable. |
| [solid_queue](https://github.com/rails/solid_queue) | Background jobs and the nightly schedule, on PostgreSQL rather than Redis, running inside Puma so the free tier needs one service. |
| [rack-cors](https://github.com/cyu/rack-cors) | Lets the Vue app call the API from another origin, with credentials so the session cookie travels. |
| [rspec-rails](https://github.com/rspec/rspec-rails), [factory_bot](https://github.com/thoughtbot/factory_bot_rails), [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers), [faker](https://github.com/faker-ruby/faker) | Tests: model, request, policy, query, job, mailer and form specs. |
| [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase), [brakeman](https://github.com/presidentbeef/brakeman), [bullet](https://github.com/flyerhzm/bullet) | Style, a security scan, and a shout in the log when a query goes N+1. |

On the front end: **Vue 3** with single-file components and the composition API,
**Pinia** for the auth and todo stores, **Vue Router** with a guard that checks
the session once, **Vitest** and **@vue/test-utils** for the tests, and
**oxlint** for linting.

## How a request travels

```
POST /api/v1/todos
  │
  ├─ authenticate!              Devise reads the session cookie
  ├─ set_current_tenant         the workspace, from the signed-in user
  ├─ set_paper_trail_whodunnit  so the version knows who did it
  ├─ authorize Todo, :create?   TodoPolicy
  ├─ Todo.create!               validations, AASM initial state, tags
  └─ TodoResource               the JSON that goes back
```

Errors never leak out raw: `ErrorHandling` turns `RecordNotFound`,
`RecordInvalid`, `StaleObjectError`, `Pundit::NotAuthorizedError` and the app's
own `ApiError` subclasses into one JSON shape.

```json
{ "error": "Validation failed", "details": { "title": ["can't be blank"] } }
```

## API

Everything lives under `/api/v1`. Signup, login and guest are open; the rest
need the session cookie those set, so a browser client sends
`credentials: "include"`.

| Method | Path | Who |
|---|---|---|
| POST | `/auth/signup` `/auth/login` `/auth/guest` | anyone |
| DELETE | `/auth/logout` | signed in |
| POST | `/auth/upgrade` | guest |
| GET | `/me` | signed in |
| GET/POST | `/todos` | workspace |
| GET | `/todos/trash` | workspace |
| POST | `/todos/bulk` | workspace |
| DELETE | `/todos/clear_completed` | workspace |
| GET/PATCH/DELETE | `/todos/:id` | author or admin to write |
| GET | `/todos/:id/history` | workspace |
| PATCH | `/todos/:id/start` `/complete` `/reopen` `/archive` | author or admin |
| PATCH | `/todos/:id/trash` `/restore` | author or admin |
| GET | `/categories` `/tags` | signed in |
| POST/PATCH/DELETE | `/categories(/:id)` | member, admin |
| DELETE | `/tags/:id` | member, admin |
| GET | `/admin/stats` `/admin/users` | admin |

`GET /todos` takes `status` (`pending`, `in_progress`, `completed`, `archived`,
`overdue`), `q`, `priority`, `category_id`, `tag`, `sort` (`newest`, `oldest`,
`due_date`, `priority`), `page` and `per_page`.

A transition the state machine does not allow answers `422`, so archiving a todo
that was never finished fails loudly rather than quietly.

## Run it locally

You need Ruby 3.3+, Node 20.19+ and PostgreSQL. Two terminals.

**API**

```powershell
cd backend
bundle install
$env:DB_PASSWORD = "your-postgres-password"   # DB_USERNAME defaults to postgres
$env:DB_PORT = "5433"                         # only if Postgres is not on 5432
ruby bin/rails db:prepare                     # create, migrate, seed
ruby bin/rails server                         # http://localhost:3000
```

**Front end**

```powershell
cd frontend
copy .env.example .env.local
npm install
npm run dev                                   # http://localhost:5173
```

Seeded login: `demo@todoapp.dev` / `password123`. For an admin, set
`$env:ADMIN_EMAIL` and `$env:ADMIN_PASSWORD` and run `ruby bin/rails db:seed`.

| | API | Front end |
|---|---|---|
| Tests | `bundle exec rspec` | `npm test` |
| Lint | `bundle exec rubocop` | `npm run lint` |
| Security | `bundle exec brakeman` | |
| Build | | `npm run build` |

> On PostgreSQL 18, `db:prepare` can abort with "server closed the connection
> unexpectedly" when the database does not exist yet. Run
> `ruby bin/rails db:create` first, then `db:migrate` and `db:seed`. If
> `localhost` resolves to IPv6 and Postgres only listens on IPv4, set
> `$env:DB_HOST = "127.0.0.1"`.

## Deploy

1. **Push to GitHub.**

   ```powershell
   git remote add origin https://github.com/<you>/todoapp.git
   git push -u origin main
   ```

2. **API and database on Render.** Dashboard → **New → Blueprint** → pick the
   repo. It reads `render.yaml` and creates `todoapp-api` and `todoapp-db`. Fill
   in `FRONTEND_ORIGINS`, and `ADMIN_EMAIL` / `ADMIN_PASSWORD` if you want an
   admin seeded. Check that `/up` comes back green.

3. **Front end on Vercel.** **Add New → Project** → import the repo → set the
   root directory to `frontend`, add `VITE_API_URL`, deploy. Put the Vercel URL
   into Render's `FRONTEND_ORIGINS` and redeploy the API.

Free tier: the Render service sleeps after about 15 minutes idle, so the first
request takes 30-60 seconds, and the free database expires after 30 days.

### Serve both from one domain

Worth doing before you deploy. Login is a session cookie, so
`todoapp.vercel.app` calling `todoapp-api.onrender.com` is a third-party cookie:
Safari blocks those and Chrome is phasing them out, so a split deployment logs
people straight back out. Setting `SESSION_COOKIE_SAME_SITE=none` works around
it but gives up the CSRF protection that `SameSite=Lax` provides for free.

One origin fixes both. A Vercel rewrite is the least work:

```json
"rewrites": [
  { "source": "/api/:path*", "destination": "https://<your-api>.onrender.com/api/:path*" },
  { "source": "/(.*)", "destination": "/index.html" }
]
```

The API rule has to come first or the catch-all swallows it. Then drop
`VITE_API_URL` so the client calls its own origin. Nothing is needed locally:
`localhost:5173` and `localhost:3000` count as the same site.

## More

[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) walks through the layers, the
decisions behind them, and the things that would need doing before this carried
real traffic.
