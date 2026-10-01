# Validation — 1 October 2026

## Completed locally

Toolchain: Flutter 3.47.2 stable / Dart 3.13.2.

- `flutter pub get --offline`: dependencies resolved from the installed cache; package name is `private_deals`.
- `flutter test --no-pub`: **66 tests passed**. This includes retained Partner tests and added role matrix, account state, route guards, session restoration, stale 401, API workspace checks, recovery isolation, independent investor filters, allowed create fields, CML self-save denial, PDF validation, pricing payloads and page rendering tests.
- `flutter analyze --no-pub --no-fatal-infos`: **exit 0, no errors or warnings**. There are 227 informational style suggestions in migrated/new sources and tests; none were suppressed via blanket analyzer exclusions.
- `flutter build web --release --no-pub`: **exit 0; built `build/web`**. The optional WebAssembly dry run reports inherited plugin incompatibilities; standard JavaScript output succeeds.
- Browser smoke check: opening `/institution/dashboard` without a session redirects to `/sign-in`; the Partner logo and empty login form render, with no browser errors observed during that check.
- Actual Institution dashboard, company list, deal list and shared investor pages render with mocked APIs at 390px and 1280px. Refreshing a quote checkout safely requests a new offer selection.
- Partner `logo.png`, `logo.svg` and web favicon match the original files byte-for-byte.
- All migration-map destinations exist. Seller restoration now intentionally includes the original dashboard, enquiries, transaction, and profile endpoint contracts; their old-server connection is pending the exact base URL and token requirements.
- Original Seller Git status remains clean. The original Partner application code is unchanged; its README had the earlier planning update.

## Integration acceptance still needed

The tests use synthetic identities and fake HTTP responses. No production login, financial transaction, company submission, investor creation or KYC mutation was performed. Local tests do not prove backend authorization or live payload compatibility.

Before deployment, use staging accounts for all five roles to verify login/profile, forced-password changes, browser reload/back, logout, revoked/blocked accounts, role changes, CORS, and server rejection of wrong-role or wrong-owner requests. Verify the field-level Institution and CML read responses against the full `institution.md`/`partner.md` or collection, which were not provided locally.

Verify an owned and unowned company, list filters/pagination, duplicate handling, creation without a logo, promoter/shareholder replacement and clearing, all deal types, fee/base/final-price behavior, and atomic bulk failures. Validate self-versus-client investor identification and Relation Manager parent-client ownership with the backend. Self-CML saving is intentionally disabled pending contract confirmation.

Native application signing, new Firebase/app registrations and store builds are outside this web-focused merge. Standard JavaScript web output is the release target; inherited plugins may report WebAssembly dry-run incompatibilities.

## Seller UI restoration — 1 October 2026

- Restored the original Seller desktop sidebar, mobile drawer/bottom navigation, dashboard, Sell Enquiries, Unlisted Transactions and profile layouts under `features/institution/legacy`, with the Partner navy/gold palette. Existing labels and nested Hot Deals/Transactions menus are retained; Investors & CML is additive.
- LP Secondary Transactions retains the original placeholder, as confirmed by the owner.
- Bulk deals reuses the original share-price table/search with Buy and Sell tabs, separate drafts, validation, and the existing Institution bulk payload. A rejected batch retains entries; success clears only the submitted tab.
- Wealth Manager Investors no longer redirects into a different workspace. Shared CML screens keep Partner navigation, and returning to Investors preserves the authenticated principal.
- Regression tests cover both workspace layouts at 390px/1280px, original endpoint selection, role restrictions, independent drafts and failed/successful bulk submission. Flutter web release compilation succeeded; analysis had no errors or warnings (informational style suggestions remain).
- Old-server routing is not finalized: the owner confirmed these screens should read old-server data, but has not supplied the old base URL, token requirements, or whether profile also uses that server. No live authenticated calls or mutations were performed. The current restored endpoint paths still resolve against the configured app API base until this is clarified.
