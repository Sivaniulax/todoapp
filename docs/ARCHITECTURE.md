# How this app is put together

Notes for anyone reading the code: what the layers are, why each library is
there, and what is deliberately missing.

## Layout

```
backend/app/
├── controllers/     thin: authenticate, authorize, delegate, render
│   └── concerns/    authentication (devise), error handling, pagination
├── policies/        pundit: who may do what, and which rows they can see
├── models/          validations, state machine, tenancy, callbacks
│   └── concerns/    Trashable (soft delete), Taggable (polymorphic tags)
├── queries/         TodosQuery: params in, a scope chain out
├── forms/           BulkCreateForm: validate pasted text, write in one go
├── services/        Accounts::UpgradeGuest: a guest becomes a member
├── resources/       alba: the JSON that leaves the API
├── jobs/            guest cleanup, tag purge, daily digest
├── mailers/         welcome, daily digest
└── validators/      HexColorValidator

frontend/src/
├── api/             one fetch wrapper, one module of endpoints
├── stores/          pinia: auth, todos, categories
├── views/           one per route
├── components/      presentational, events upward
└── utils/           dates, status labels, debounce
```

A controller action should read as four lines: authorize, call something,
render, done. Anything longer than that belongs in a query, form or service
object.

## A request, end to end

Middleware order matters and is set in `config/application.rb`:

```
Rack::Cors            → credentials allowed, origins from FRONTEND_ORIGINS
ActionDispatch::Cookies
ActionDispatch::Session::CookieStore
Warden::Manager       → appended by devise; it needs the session to exist first
routes
```

An API-only app loads neither cookies nor sessions by default, and devise
appends Warden to the end of the stack, so both are inserted *before*
`Warden::Manager` explicitly. Getting that order wrong fails as
`undefined method '[]' for nil` inside Warden, which is not a helpful message.

Then, per request:

1. `authenticate!` — Devise's `user_signed_in?`, plus the guest expiry check.
   An expired guest is signed out and gets a 401.
2. `set_current_tenant` — the workspace from the signed-in user. Every query on
   a tenant model is scoped from here on.
3. `set_paper_trail_whodunnit` — so versions record who.
4. `authorize` — Pundit. Member actions find the record *through* the policy
   scope first, so another workspace's row is a 404 and not a 403: the API
   never confirms that something it won't show you exists.
5. The model does the real work; the resource shapes the response.

## Decisions

**A session cookie, not a JWT.** Devise is session-based, and a cookie the
browser cannot read beats a token in `localStorage` for XSS. The cost is that
the app and the API have to share a domain, because a cross-site cookie is
blocked by Safari and increasingly Chrome. `SameSite=Lax` is also what stands
in for CSRF tokens here: the browser never attaches the cookie to a cross-site
write, and every GET is read-only. Setting `SESSION_COOKIE_SAME_SITE=none` for
a split deployment gives that up, and real CSRF tokens would have to go in
first.

**Pundit, not role checks in controllers.** `require_role :admin` worked, but
authorization rules want to live somewhere testable, and the questions got
harder once workspaces were shared: you can *see* a colleague's todo and not
edit it. That is two lines in a policy and an awkward `before_action`
otherwise.

**acts_as_tenant, not apartment.** Apartment is unmaintained and does not
support Rails 8, and schema-per-tenant is a lot of machinery for this app.
Row-level scoping gives the same guarantee — one `workspace_id` condition on
every query, added by default rather than by hand — with none of the migration
pain.

**AASM, not a boolean.** `completed` could not say "in progress", and nothing
stopped a todo being completed twice or archived without being finished.
Four states and the moves between them say what a boolean could not, and the
API hands the client each todo's `allowed_events` so the buttons it shows come
from the server's rules rather than a second copy of them.

**Alba, not hand-rolled serializers.** The plain-Ruby classes were fine. Alba
is less code for the same explicitness, and associations stop being hand-built
hashes.

**Pagy, not the concern.** Same reason, plus it answers an empty last page
rather than raising when someone asks for page 99.

**jsonb for paper_trail.** The default is a text column holding YAML, which is
neither queryable nor pleasant. `object` and `object_changes` are `jsonb`, and
`lock_version` and `updated_at` are ignored because they change on every save
and say nothing.

**Soft delete without `default_scope`.** `Trashable` adds `kept` and `trashed`
scopes and nothing global. A `default_scope` is too easy to forget about and
too annoying to escape.

**Solid Queue inside Puma.** One Render service covers web and jobs on the free
plan. `SOLID_QUEUE_IN_PUMA=false` plus `bin/jobs` splits them when that stops
being true.

## Tests

164 specs, and the kinds matter more than the count:

- **model** — validations, the state machine's legal and illegal moves, scopes
- **policy** — each permission, and each scope, from both sides
- **request** — the API as a client sees it, including the 404-not-403 rule
- **workspace isolation** — that sharing works *and* that tenants cannot see
  each other; this is the spec that would catch a tenancy regression
- **query, form, service, job, mailer** — the objects controllers delegate to

The front end has Vitest specs for the components and the todo store,
including that a stale response cannot overwrite a newer one and that an
optimistic status flip is rolled back when the API refuses it.

## Not done

Honest list, roughly in the order I would pick them up:

- **No CSRF tokens.** Fine while the cookie is `SameSite=Lax` and both halves
  share a domain. Required the moment they do not.
- **No way to invite someone into a workspace.** The model supports shared
  workspaces and the policies enforce them, but nothing in the UI or API
  creates the second membership; today you would do it in the console.
- **`users.workspace_id` is a single column**, so a person belongs to exactly
  one workspace. A join table is the obvious next step, and policies would
  mostly survive it.
- **Admin stats are cached for five minutes** and counted across all tenants on
  every miss. Fine at this size, wrong later.
- **No end-to-end tests.** The specs cover the API and the components, not a
  browser driving both.
- **Guest cleanup is opportunistic** — enqueued when a new guest signs up, plus
  a nightly job. A long quiet spell leaves expired guests sitting there until
  the schedule catches up.
- **Brakeman does not run on Windows here.** Ruby's `windows_31j` encoding
  library crashes the VM when brakeman's scanner loads it. It runs in CI.
