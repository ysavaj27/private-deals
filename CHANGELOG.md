# Changelog

## 2026-10-01 — New merged Private Deals web project

- Created a separate `private_deals` project from Partner and the supported Seller company/deal features. Original application codebases remain separate.
- Kept Partner branding; updated the web app name and manifest icon paths.
- Reorganized code into app, core, shared, and feature modules; preserved source mappings in `docs/migration-map.json`.
- Added a single Partner principal with exact role parsing, restoration verification, default-deny route guards, product checks and workspace API checks.
- Removed login/recovery test credentials, raw payload logs, investor-token session replacement, and the inherited blocked/deleted OR condition.
- Separated password recovery state, corrected 401-only expiration and protected newer sessions from stale requests.
- Moved Institution calls to the documented v2 business namespace, removed unsupported Seller price APIs, and removed server-managed fee fields from company creation.
- Added owned-submission filtering, optional company logo, deal editing, bulk pricing, and base/final-price labels.
- Added shared v2 investor/client creation and browser-safe PDF CML read/save; self-save stays disabled pending backend confirmation.
- Corrected investor AIF filter wiring, explicit endpoint versioning and browser multipart uploads.
- Added role/API/route/pricing/PDF tests; retained existing Partner regressions and aligned the old color assertion with the existing Partner navy theme.
- Deployment and authenticated staging acceptance remain separate from local compile/tests; see `docs/validation.md`.
