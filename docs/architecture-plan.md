# Private Deals — Partner and Institution

Private Deals is being planned as one web-first Flutter application based on this Partner project. The new company-and-deals user is an **Institution partner**, corresponding to the seller-facing use case discussed during planning. Institution company/deal screens and Wealth Manager dashboards have separate access policies; investor/CML features are shared by permitted partner types.

**Status:** architecture and API-contract planning. This documentation does not mean that the seller merge, unified user model, or role guards have been implemented. The current Dart package remains `private_deal_partner`; package/platform renaming is a separate migration step.

## Confirmed product decisions

Confirmed by the project owner on 2026-10-01:

- All supported partner types authenticate through `POST /api/v1/business/login` against the same user database.
- Each user has **exactly one role**. No user-selectable role or role switcher is planned.
- The backend `data.type` identifies that role. The supplied configuration establishes the canonical values `Wealth Manager`, `Distributor`, `Retailer`, `Relation Manager`, and `Institution`.
- Wealth Manager and Institution use separate dashboards. Company/deal management requires Institution; shared investor/CML features are available to the partner types described below. A shared feature is not permission to enter another role's dashboard.
- Maintain one global authenticated user/session and shared authentication infrastructure.
- Use Partner as the destination application for the Seller merge.
- Document the architecture, dependencies, behavior changes, migration status, and verification in this README.

The earlier proposals for separate seller/business login adapters, multiple-role switching, and copying every legacy Seller feature unchanged are superseded by this contract. The owner confirmed that the first merged release starts with supported Institution features. Unsupported legacy features stay in the old Seller application.

## Handoff contract and scope

Contract reference: the owner-supplied `app-handoff.md`, dated 2026-09-30. It describes API behavior and proposed application flows; its embedded build instructions do not themselves authorize runtime implementation. This planning update has not tested the live API.

- New Institution work uses `/api/v2/business/institution/...` with the business-login partner token.
- The merged app must not call legacy `/api/v2/seller/...` endpoints. Seller tokens and Institution partner tokens are not interchangeable.
- The legacy Seller application and its endpoints remain the reference for behavior; no changes to that application are made by this plan.
- Every API request requires `headtoken`. Authenticated requests additionally require `Authorization: Bearer <token>`. Keep actual values out of source examples and logs.
- HTTP 200 with JSON `status: 1` means success. HTTP 200 with `status: 0` means a business failure. Preserve the message and do not report success or automatically expire the session just because of a business failure.
- Profile uses `GET /api/v1/business/profile`. Recovery uses `/api/v1/business/forgot-password` and its resend/verify/change subpaths, with `partner_id` rather than `seller_id` where required.
- Retain `data.token` in the session and parse nullable `data.self_investor_id` from login/profile. A null self-investor ID must not be converted into a selectable investor or used to infer the user's role.

### Roles and shared capabilities

- **Wealth Manager, Distributor, Retailer:** investor/CML access; no Institution company/deal management.
- **Institution:** investor/CML access plus company/deal management.
- **Relation Manager:** investor/CML access for the parent's clients, subject to backend scope; no self investor and no Institution company/deal management.
- **Unknown type:** deny private access. Do not classify every non-Institution value as Wealth Manager.

Preserve the raw API type separately from an internal typed role. The exact configuration path is `data.enum.partner_type` (the Dart model calls the enclosing object `enumValues`). Its supplied values are:

```json
{
  "wealthmanager": "Wealth Manager",
  "distributor": "Distributor",
  "retailer": "Retailer",
  "relationmanager": "Relation Manager",
  "institution": "Institution"
}
```

Map those labels to explicit internal role values. Treat the earlier lowercase distributor example as superseded by this canonical configuration. Do not infer roles from substrings or silently promote an unknown type. The current `PartnerType` configuration model lacks `institution`; extending that parser is part of implementation. Existing product access flags and Relation Manager restrictions still apply where the endpoint contract requires them.

The supplied config also has `current_api_version: v1`, a string page limit of `30`, and file size limits expressed in MB. Parse numeric configuration deliberately, and keep API version selection per endpoint family. A global version setting must not change the documented v2 Institution/investor URLs. Endpoint-specific rules take precedence over generic upload extensions: CML accepts PDF only, max 10 MB, even though the generic document configuration includes other formats.

### Legacy features without Institution endpoints

The handoff explicitly supplies no Institution copies of the legacy Seller dashboard, profile update, standalone share-price update, pre-IPO transaction list/detail, or sell-enquiry list. Do not derive replacement endpoints by string substitution or reuse the Seller token.

Institution price entry uses deal create/bulk operations. A normal deal updates today's company price; a hot deal does not. The owner chose supported Institution features for the first release, so the unsupported legacy features are outside that release and their source remains in the old Seller project. Proposed Institution dashboard: links to companies, deals, and shared investor/CML workflows. No legacy Seller dashboard request or invented aggregate totals. Final layout remains a UI design detail.

The owner says the referenced specifications are available on the web and can share specific details on request; no URL or full specification has been provided yet. Ask for the field-level details needed by each implementation slice instead of assuming those documents have been read.

## Current implementation

Independent Flutter application combining the existing wealth manager and shared core source in one package. The Dart package name is `private_deal_partner` and the existing platform identifiers and Firebase configuration are preserved.

The existing stack uses Flutter/Dart, GetX for state/dependency management/navigation, Dio for HTTP, GetStorage for persistence, and Firebase initialization with platform-specific behavior. Exact dependency constraints and resolved versions are recorded in `pubspec.yaml` and `pubspec.lock`. Dependencies and runtime code have not been changed for this plan.

Relevant current code:

- `lib/src/backend/api/auth/w_auth_api.dart`: business login and account API calls.
- `lib/src/models/user/wealth_manager_model.dart`: current user DTO, including `type`, token, status, and product-access flags.
- `lib/src/configuration/app_config.dart`: global state and persistence.
- `lib/src/routes/pages.dart`: registered routes.
- `lib/src/routes/middleware/auth_middleware.dart`: login-presence check; no business-role check.
- `lib/src/routes/module_access_middleware.dart`: product-access logic, currently not registered in `Pages.pages`; this is not a business-role guard.

The existing `UserType.distributor` selects an application/API context. It is distinct from `data.type`, including an actual distributor business role. Do not overwrite the request `usertype` header with a new role enum without confirming the backend contract.

## Run

```sh
flutter pub get
flutter run
```

For browser development:

```sh
flutter run -d chrome
```

These are development commands, not validation results for the planned merge.

Core backend, configuration, models, and utilities now live directly in `lib/src/`, alongside the existing modules, routes, and theme. Their exports are combined in `lib/src/utils/app_exports.dart`. Shared assets and Roboto fonts are bundled in `assets/` and declared in `pubspec.yaml`. Asset widgets load these local assets without a package prefix.

No sibling core package is required. UI and business logic are preserved; changes are limited to package imports, exports, asset references, and dependency configuration. The unused core demo entry point is excluded in favor of the wealth manager entry point. Generated build caches and installed dependencies are excluded from the copy.

## Proposed global user and session

Use a neutral `PartnerUser` model for the common authenticated identity: ID, raw backend type, one mapped role, nullable self-investor ID, account status, password-change requirement, and confirmed permissions. Keep Institution company data and Wealth Manager business data within their features. Investor responses also need their own `is_self` flag.

One `AuthSession` service owns the current user and credentials. Screens read its state; they do not mutate roles, create their own session stores, or replace the authenticated user with a selected investor.

The role parser must map only the confirmed API labels to a known role. Missing, unsupported, or malformed types must result in denied private access, never a default Wealth Manager or Institution role. A future value in remote configuration must not gain access without an explicit local policy. Commit a login session only after the response's `status` indicates success and its user data passes validation; any required configuration must be ready before protected feature entry.

Persist only the minimum session data required by the agreed authentication contract. Do not persist passwords or log credentials, OTPs, or complete user responses. Cached user data is a startup hint, not authority to bypass server validation. A backend-supported HttpOnly/Secure-cookie session can be evaluated separately; this plan does not assume that support exists.

Recommended session states are restoring, anonymous, authenticated, password-change-required, account-unavailable, unsupported-role, and validation-error. A network failure should offer retry without treating stale role data as validated or incorrectly declaring the user logged out.

## Proposed access policy and routing

The guard pipeline is:

```text
Requested URL
  -> Restore and validate session
  -> Require authentication
  -> Reject blocked/deleted account
  -> Enforce required password change
  -> Resolve the server-returned role
  -> Check route role and product/action permissions
  -> Construct the authorized page and its controllers
```

For the initial dashboard, resolve the role and navigate to its dashboard. For a saved link, return to that link only if its route policy allows the user.

Proposed route namespaces:

```text
/login
/forgot-password
/account/profile
/account/change-password
/wealth-manager/dashboard
/investors
/investors/:investorId
/investors/:investorId/kyc/cml
/wealth-manager/transactions/:transactionId
/institution/dashboard
/institution/companies/:companyId
/institution/companies/my-submissions
/institution/deals/new
/institution/deals/bulk
/forbidden
```

These are proposed names. The Institution dashboard's data source is unresolved; the handoff provides no dedicated dashboard endpoint. `/investors/*` is shared, with backend ownership and relation-manager scope enforced. Existing non-Institution dashboard mappings must preserve their current restrictions. The current routes remain unchanged until implementation.

Access-policy requirements:

- Centralize route metadata: allowed roles, required product/action permissions, and whether authentication is required.
- Apply the policy to every private route, including detail, create/edit, nested, and legacy routes. Unclassified private routes are denied.
- Use the same policy for sidebars, action visibility, navigation, and guarded controller creation. Hiding a menu does not protect its route.
- Require both a permitted business role and the relevant capability. Existing `is_primary_access`, `is_secondary_access`, and `is_preipo_access` flags do not grant a different business role.
- Only Institution can enter `/institution/*`. Wealth Manager, distributor, retailer, and relation manager are denied before Institution controllers or requests start. Institution cannot enter an exclusive Wealth Manager dashboard, but can enter shared investor/CML routes.
- Prefer capability rules such as `canManageInstitutionCompanies` and `canAccessInvestors` over treating all screens as exclusive to one of two roles. An Institution's shared investor access does not turn it into a Wealth Manager.
- Unknown paths show not found. Unknown roles show unsupported access. Neither should silently select the default dashboard.
- Model blocked/deleted checks as neither blocked nor deleted. These checks take precedence over forced password change.
- Validate login return URLs as internal permitted routes; do not redirect to arbitrary URLs from query parameters.
- On refresh, do not render private content before session validation completes. Fetch entities from stable URL IDs/slugs; in-memory route arguments are optional optimizations.
- Legacy `/home/*` paths need explicit mappings. Use the validated role for unambiguous destinations and deny incompatible links.
- Reevaluate the route when the server changes the user's role, status, or permissions. Clear/dispose old feature state and ignore responses from an earlier session revision.

Keep GetX state management during migration. Route guards and page lifecycle must be tested with the current router; a Router/go_router migration remains a separate evaluated decision, not a prerequisite assumed by this README.

The backend must independently enforce role, action, and record ownership on every API request. A client role field, URL, hidden menu, or global Dart object is not a server authorization boundary. See the [OWASP authorization guidance](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html).

## Proposed folder ownership

Retain `lib/src` as the source root and reorganize incrementally:

```text
lib/
  main.dart
  src/
    app/
      bootstrap.dart
      routing/              # Route registry and guard composition
      shell/                # Common layout and role-specific navigation
      bindings/             # Dependency composition
    core/
      config/
      session/              # One global user/session owner
      permissions/          # Role mapping and shared access policy
      network/              # Dio clients, interceptors, failures
      storage/
      platform/             # Browser/native adapters
      logging/
    shared/
      theme/
      widgets/
      formatting/
      models/               # Verified common value objects only
    features/
      auth/                 # Shared business login and recovery
      account/              # Common account screens/services
      catalog/
      documents/
      notifications/
      investors/            # Shared list, client creation and CML
      wealth_manager/
        dashboard/
        transactions/
        portfolio/
        earnings/
        channel_partners/
        pending_tasks/
        reports/
      institution/
        dashboard/          # Data/layout decision still pending
        companies/
        deals/
```

Within each feature use `data/` (API, DTOs, repository) and `presentation/` (controllers, pages, widgets), with a feature route declaration and bindings. Add a domain layer only where business rules justify it.

`app` composes features; features depend on `core` and `shared`; core/shared do not depend on feature controllers. Institution and Wealth Manager must not import one another's private screens/controllers. Both can use shared investor features through the common policy. Use explicit names such as `InstitutionDashboardController` and `WealthManagerDashboardController`.

Do not collapse unrelated `CompanyModel`, transaction models, or API payloads just because their filenames match. Preserve separate DTOs until their contracts are compared. Existing investor-login-only code is retained during inventory; shared partner investor management does not imply a separate investor-login workspace.

## API changes that affect the migration

### Investors and CML

- List/create move to `GET/POST /api/v2/business/investor`. Do not change every business endpoint to v2; login/profile/recovery remain v1.
- List requires `is_kyc` and `is_active` (`All`, `Yes`, or `No`); `is_aif` defaults to `All`, and relation-manager IDs are optional. Fix the current API helper that assigns `isActive` to `is_aif` rather than its `isAif` parameter.
- Render "My account" using the actual `is_self` flag. The self investor is first only when it matches the filters; never identify self solely by row position. Relation managers have no self investor.
- New-client create requires `investor_type`, `name`, and `mobile_number`; only `email` and `gender` are optional. Do not reuse the old create payload containing password, address, city, or pincode. Investor update has a separate contract and must not be inferred from create.
- CML read: `POST /api/v2/business/investor/kyc/cml/read`, multipart `investor_id` and PDF `cml`, max 10 MB. Read only prefills fields; it does not complete KYC.
- An unreadable CML is submitted for manual verification and returns `status: 0`. Treat this as a contextual workflow result, not success, session expiry, or an instruction to blindly resubmit.
- CML save: `POST /api/v2/business/investor/kyc/cml/save`. Required fields are `investor_id`, `dp_id`, `client_id`, `pan_no`, and `name`; optional fields are `account_number`, `ifsc_code`, `bank_name`, `dob` (`d-m-Y`), and PDF `cml_file`. Success sets `preipo_kyc_status` to `1` and replaces the investor name.
- The handoff permits reading a self investor and saving clients. The owner does not yet know whether self-investor CML save is supported. Proposed first-release policy: allow documented self read, support authorized client save, and leave self-save disabled/unimplemented until the backend contract is confirmed. Do not silently treat a self investor as a client or discover write permission through live submissions.

### Institution companies and deals

- Base: `/api/v2/business/institution/company`. Company create uses multipart data for the optional logo. Preserve all required financial/identity fields from the detailed specification; do not send `processing_fee_percentage` or `commission`.
- Use the documented sectors, duplicate check, list, list-lite, detail, my-submissions, promoters, and shareholders endpoints. Detail accepts `slug`, `id`, or `uuid`.
- `is_editable` follows `submitted_by_partner_id` ownership. Do not compare against the old seller ID. Backend ownership checks remain required.
- Promoter/shareholder operations replace the complete collections; empty lists clear them. Preserve this behavior explicitly in editing flows.
- Create is immediately approved according to the handoff. Do not add an approval-wait screen.
- Deal list/create share `GET/POST .../company/deals`; there are no new `/list` or `/create` suffixes. Update/delete remain `POST .../company/deals/update` and `/delete`; bulk is `POST .../company/deals/bulk`.
- On create, request `share_price` is the Institution's **base amount**. The server adds its fee and returns `base_price` and customer `share_price`. Show them with distinct labels and use server values.
- On update, request `share_price` is the updated deal price; the fee is **not added again**, `base_price` remains unchanged, and `company_id` cannot change. Use separate create/update payload builders to avoid accidentally applying create semantics to edits.
- Bulk uses `sell[]`/`buy[]` rows with `company_id`, `sell_price`/`buy_price`, `min_qty`, and nullable `total_qty`. Blank/zero-price rows are skipped; at least one valid row is required. A priced row with an invalid company or `min_qty < 1` fails the entire request without creating rows.
- Normal deals update today's company price; hot deals do not. Deal update/delete identify an owned deal by `uuid`.

Business denial of an Institution endpoint is documented as HTTP 200, `status: 0`, and an explanatory message. Keep this distinct from HTTP 401 session expiry and HTTP 403 where those are used elsewhere. The handoff describes backend checks; their actual deployment still needs authorized integration verification.

## Migration and verification plan

1. Confirm detailed field contracts for each implementation slice. All five canonical role labels, shared login, one role per user, the Institution API namespace, and supported-feature first-release scope are settled. Self-CML saving remains unconfirmed and is deferred.
2. Inventory each source file, route, API, asset, and test from both projects. Record whether it is moved, consolidated, retained, or intentionally retired. Seller remains the reference project during migration.
3. Implement and test the neutral user/session service and capability policy in Partner before importing Institution pages. Shared login must resolve the correct dashboard while preserving shared investor/CML access.
4. Move features into their owned folders in working slices. Reconcile dependency APIs, assets, themes, and payload models. Preserve existing Wealth Manager behavior and business tests.
5. Validate web refresh, back/forward, old URLs, responsive layouts, byte-based uploads, PDFs, downloads, and spreadsheet flows on a hosted staging build.
6. Compare feature coverage against the migration inventory. Update this README with actual changes and test results before release.

Required regression cases:

- Wealth Manager and Institution each reach their own dashboard after business login and refresh; each other supported role gets its permitted existing flow.
- All non-Institution roles are denied Institution URLs before private page initialization/API calls. Institution is denied exclusive Wealth Manager dashboard routes but allowed shared investor/CML routes.
- Missing/unknown type, missing permission, blocked/deleted account, and forced password change follow explicit outcomes.
- Every registered private route has policy coverage, including aliases and nested routes.
- HTTP 401 follows the confirmed session-expiry/refresh contract; HTTP 400 remains a request error and HTTP 403 remains access denied. Do not treat all bad responses as expiry.
- HTTP 200 with `status: 0` is a business failure, including Institution-role denial and CML manual-verification responses. Failed responses must not commit login state or show saved/completed UI.
- Concurrent failures, logout, login as another user, and stale requests do not restore an old user or old role's records.
- Changing browser storage or sending an API request directly cannot bypass backend authorization. Verify only in an authorized test environment.
- The server validates partner/investor scope and Institution ownership of company/deal mutations. The merged app never calls legacy Seller APIs.
- Existing transaction payload tests continue to pass, and migrated seller workflows have behavior-based coverage.
- Test all five canonical role mappings, the new Institution config field, and unknown-type denial. Test self-investor filtering/null IDs and Relation Manager scope; reduced v2 client payloads; CML read versus client save (no self-save while unconfirmed); create/update price semantics; hot versus normal prices; and atomic bulk failures.

Planned validation commands are `flutter analyze`, `flutter test`, and `flutter build web`, followed by browser integration checks. No new runtime test results are claimed by this documentation update.

## Open API/product questions

- Obtain company list/create/detail and bulk response examples, pagination fields, and full required/optional form validation rules when implementing those features. No credentials or personal records are required.
- Can a partner save CML for its own self investor? The owner does not yet know; defer this write action until the backend contract is confirmed. This does not block the documented client flow or the role architecture.
- Confirm logout, authenticated password change, token expiry/refresh, and legacy custom-header requirements with the full partner contract; do not infer them from recovery endpoints.
- What deployment origin and existing public links must be preserved?

## Documentation maintenance

For each implementation change, record the changed behavior and why, affected folders/routes/API contracts, introduced or removed dependencies, storage/URL compatibility changes, and actual validation results. Keep confirmed decisions, proposals, and implemented behavior visibly distinct. Do not put credentials or real user payloads in documentation.

### Change record

- **2026-10-01 — Planning/documentation only:** recorded shared `business/login`, one user database, server-derived Wealth Manager/Seller roles, Partner as the destination, a global session, proposed guard policy and folder ownership, and pending backend questions. Application code, dependencies, routes, and package identifiers were not changed.
- **2026-10-01 — Handoff reconciliation, documentation only:** recorded exactly one role per user, `Institution` as the new seller-facing role, v1 shared auth plus v2 Institution/investor APIs, shared investor/CML permissions, legacy features without replacements, and distinct deal create/update pricing semantics. Corrected the two-exclusive-workspaces assumption. No supplied token or personal user data was copied into this repository; runtime implementation remains pending.
- **2026-10-01 — First-release scope confirmed:** start with supported Institution features. Legacy Seller dashboard, standalone price update, profile edit, transactions, and sell enquiries stay in the old Seller application. Detailed web specifications will be requested as needed; current planning has only used the supplied handoff.
- **2026-10-01 — Role configuration confirmed:** recorded the exact five labels from `data.enum.partner_type`, the missing Institution config-model field, and endpoint-specific v1/v2 version selection. Self-CML save is still unknown; the proposed first release defers that action while supporting documented client save. No runtime code changed.

## Historical validation from the earlier Partner extraction

The following results were already present in this README before merge planning. They have not been rerun for this documentation update and do not validate the planned seller merge:

- Offline dependency resolution succeeds without a `core` package.
- Flutter analysis: zero errors, 25 warnings, and 138 informational notices.
- Existing tests: 10 pass; the unchanged counter-template widget test fails because it expects the demo counter UI.
- Source comparison confirms only import/export and asset package-reference adjustments.
- Some asset constants already reference files absent from the original assets; these were preserved without inventing replacements.
- `flutter build web --no-pub` succeeds.
