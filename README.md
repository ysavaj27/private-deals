# Private Deals

A Flutter application combining the Partner app with the supported Seller workflows, now available to the **Institution** partner role. The primary target is the web. The app logo, favicon, icons, fonts and navy/gold theme come from Partner.

## Run locally

Use Flutter with Dart 3.12.2 or later, compatible with the checked-in lockfile.

```sh
flutter pub get
flutter run -d chrome --web-port 8080
```

The default API origin is the existing Private Deals service. For a test server, pass a trailing-slash origin (the app appends `api/`):

```sh
flutter run -d chrome --dart-define=PRIVATE_DEALS_BASE_URL=https://your-staging-host/
```

Keep `pubspec.lock` under version control. Do not run an automatic dependency upgrade as part of this merge. The current resolved file-picker API uses bytes for browser uploads.

## Structure

```text
lib/
  main.dart
  firebase_options.dart
  src/
    app/
      bootstrap/             # Startup and initial destination
      routing/               # Route registration, guards, session destinations
    core/
      session/               # Single AuthSession and PartnerUser
      permissions/           # Canonical roles and shared access policy
      config/                # Endpoint versions and backend configuration
      configuration/         # Dio, preferences, device and platform services
    features/
      auth/                  # Shared business login, recovery, password change
      account/               # Existing Partner profile views
      investors/             # Shared v2 clients, self identification and CML
      institution/
        companies/           # Catalog, creation, promoters and shareholders
        deals/               # Single create, edit, delete and bulk deals
        data/                # Institution DTOs, endpoints and payload contracts
        support/             # Seller presentation helpers retained during migration
      wealth_manager/        # Partner dashboard, earnings, transactions, portfolio
      catalog/               # Partner primary, secondary and unlisted catalog
    shared/                  # Reusable widgets, theme, media and formatting
test/                        # Auth, API, route, pricing and UI regression tests
docs/                        # Contract source, migration map and implementation notes
```

Add new code to its feature rather than to a new top-level `seller` app. There is one Flutter entry point, route registry, session and API client. Some migrated Partner files still use `shared/app_exports.dart`, and legacy `wUser` getters delegate to the same Partner session. They are compatibility names, not separate identities. New feature code should use focused imports.

## Roles and navigation

The exact `data.type` values are `Wealth Manager`, `Distributor`, `Retailer`, `Relation Manager`, and `Institution`. Each user has exactly one role. Unknown/missing values are rejected; public configuration cannot grant a new role.

- Institution lands at `/institution/dashboard` and can manage Institution companies and deals.
- Wealth Manager, Distributor, Retailer and Relation Manager use the Partner workspace at `/wealth-manager/dashboard`. Existing backend permissions still govern their individual operations.
- `/investors` and `/investors/:id/cml` are shared by all recognized partner roles. Relation Managers receive their parent-client scope from the backend.
- `/account` and `/changePassword` are shared account pages. Institution account information is read-only; no unsupported Seller profile-update endpoint is called.
- Primary, secondary and unlisted catalog routes also require the matching product access flag. Flags never grant Institution access. Relation Managers cannot open channel-partner management.
- Checkout URLs preserve their product section. Refreshing a quote-based checkout asks the user to reselect an available offer rather than reconstructing a price from the URL.
- Company/deal routes enumerate `unlisted` and `secondary`; invalid types do not silently select another dashboard.

`AuthMiddleware` runs before protected page builders/controllers. Menus and named route navigation use the same access policy. The API interceptor also rejects wrong-workspace calls. **The backend must independently enforce the role and ownership on every request.** Client-side guards cannot secure an API against a modified browser.

## Login and session lifecycle

All roles use `POST v1/business/login`, with `GET v1/business/profile` to restore a browser session. `PartnerUser` keeps the role, access flags and nullable `self_investor_id`. Investor selection never changes the authenticated user or token.

Only the minimum session candidate (partner ID and token) is persisted under `private_deals.session.v1`. On refresh the cached role/permissions are ignored until profile verification succeeds. A connection failure displays a retry page; it does not erase a potentially valid token. Unauthorized deep links are blocked, and an allowed pending destination can be resumed after login/password change.

HTTP 401 clears the current session. HTTP 400, 403, 405, business `status: 0`, and temporary network failures do not automatically sign the user out. Request generations prevent an old response/401 from changing or clearing a newer session. Password recovery keeps its `partner_id` separately from the authenticated user. Login forms contain no test credentials, and payload logging is disabled.

Browser persistence currently uses the inherited GetStorage bearer-token design. JavaScript-readable storage is not an HttpOnly session cookie. A cookie-based session/BFF requires coordinated backend work and is not implemented by this frontend merge. Do not put user access tokens into source files or docs.

## API boundaries and supported workflows

Auth remains v1; shared investors/CML and Institution endpoints explicitly use v2. `get-config.current_api_version` does not rewrite these endpoints. Every backend request carries `headtoken`; authenticated requests also carry the Partner bearer token. These headers are not sent to unrelated third-party URLs.

- Company catalog and **Only my submissions**, sectors, duplicate checking, create, promoters, and shareholders use `v2/business/institution/company/...`.
- Company creation goes live immediately; commission and processing fee are server-managed. Company logo is optional; the retained image picker caps it at 2 MB. Ownership is taken from `is_editable` before promoter/shareholder editing; those APIs replace complete lists, including clearing them with `[]`.
- Single deal creation sends a **base** `share_price`; the response contains the original `base_price` and final customer `share_price`. Deal editing sends the **final** price without adding a second fee or changing company/base price. Bulk buy/sell input validates every priced row before submitting one request.
- Shared investor listing uses `v2/business/investor` with independent KYC, active and AIF filters. Self identification uses `is_self` or the profile's `self_investor_id`, never list position.
- New clients send only investor type, name, mobile number and optional email/gender. Legacy investor-update contracts remain separate.
- CML read accepts a PDF up to 10 MB and prefills fields; it does not mark KYC complete. Client save confirms KYC and updates the investor name. Self-CML read is supported; **self-CML save remains disabled** until the backend contract is confirmed. Direct CML links reload the accessible investor list rather than trusting a URL-provided self flag.

The Institution dashboard contains supported workflow links. No financial totals are fabricated. Seller dashboard metrics, standalone company price updates, Seller transactions, sell enquiries and Seller profile editing were intentionally left in the original Seller project because the handoff has no Institution replacements. There is no role switcher and no active `/seller/` endpoint in the new app.

## Validation and deployment

```sh
flutter test --no-pub
flutter analyze --no-pub --no-fatal-infos
flutter build web --release --no-pub
```

See [validation.md](docs/validation.md) for the verified checks and remaining integration work. Tests use fake responses and never authenticate against production. Style-level analyzer suggestions remain in migrated and new files; they are distinct from errors/warnings.

The web server must serve `index.html` for application routes so browser refresh and pasted deep links work. See [web-deployment.md](docs/web-deployment.md). No hosting or backend was changed. Native runner files and Firebase configuration were inherited from Partner; new native app registrations, signing and store releases are not part of this web merge.

## Documentation and maintenance

- [CHANGELOG.md](CHANGELOG.md) records actual changes, including their purpose and validation.
- [migration-map.json](docs/migration-map.json) maps both source codebases into this project and records deferred Seller files.
- [api-handoff.md](docs/api-handoff.md) is the supplied backend contract reference. Its implementation suggestions are reference material; the agreed release scope takes precedence.
- [architecture-plan.md](docs/architecture-plan.md) preserves the pre-implementation plan. This README and the changelog describe the implemented result.

For every future behavior/API/routing change, update this README or the relevant document and add a changelog entry with validation and any unresolved backend dependency. Do not claim a new role or endpoint is supported without a confirmed contract and a role/ownership regression test.
