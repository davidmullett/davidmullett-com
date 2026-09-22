# Cal.com integration

## Current implementation (launch)

The homepage invitation — "half an hour of your time", in both The investigation
and Contact — is a link to the public event
`https://cal.com/david-mullett-8mcmpk/30min`, upgraded by Cal.com's official
**pop-up via element click** embed.

- Loader: `@calcom/embed-snippet` 1.3.3 published form, inline before `</body>`.
- Theming: `Cal("ui", { cssVarsPerTheme })` — the supported API — mapped to the
  site tokens (`--cream`, `--ink`, `--rule-lt`), `radius: 0px`.
- Fallback: the `<a href>` is the canonical event URL, so the link works with
  JavaScript disabled, in a new tab, and under keyboard navigation.

**No credential of any kind is involved.** The event link is public.

## If a Cal.com API v2 integration is ever needed

Not required for launch. Do not build it speculatively.

- **Credential env var:** `CALCOM_API_KEY`. Created at
  Cal.com → Settings → Developer → API keys. Stored as a Cloudflare Pages
  encrypted environment variable (Settings → Environment variables), and locally
  in `.dev.vars` (gitignored). Never in HTML, never in client JavaScript, never
  committed — a key in client code is world-readable and grants full account
  access.
- **Where server-side calls would live:** this repo is a pure static site with no
  build step. Cloudflare Pages supports server-side code via **Pages Functions** —
  a `functions/` directory at the repo root, deployed automatically. A future
  custom surface would put Cal.com calls in e.g. `functions/api/slots.js`, reading
  the key from `env.CALCOM_API_KEY`. The current hosting architecture supports
  this with no migration.
- **Base URL:** `https://api.cal.com/v2`. Authentication is required on every
  endpoint; unauthenticated requests return `ForbiddenException`.
- **Endpoints a custom booking surface would likely use:**
  - `GET /v2/slots` — available slots for an event type
  - `POST /v2/bookings` — create a booking
  - `GET /v2/event-types` — event type ids and metadata
  - `GET /v2/schedules` — availability windows
  - `GET /v2/me` — account/timezone
- **OAuth is not appropriate here.** It exists for platform customers booking on
  behalf of many users. This is a single-owner personal site; an API key scoped to
  the owner's own account is the correct mechanism.
