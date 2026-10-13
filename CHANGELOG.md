# Changelog

## 2026-10-13 — Config cleanup + partner documents

- Stopped reading removed get-config fields (`app_version`, `build`, banners, tutorial, investment process, Calendly). Force-update and Windows EXE-from-config are gone.
- `enum.document_type` is parsed dynamically for the six client document types only (no hardcoded SSA/PAN/etc.).
- Replaced Send Documents with a Documents workspace: list/filter from `GET v2/business/documents`, download, and send via WhatsApp/email/both with action toasts.

## 2026-10-13 — Pre-IPO flow corrections

- Returning from Limit to Market now updates the displayed price, submitted price and total together, preserving fractional share prices.
- Transaction detail actions receive the refreshed order, so signing after an external/WhatsApp step uses the current link. This also keeps receipt and payment actions aligned with the displayed details.
- Institution transactions retain mandate-pending orders under Pending and support the server-provided Sign mandate action.
- Catalog buy offers use **Enquire to sell** from both the row and details dialog. The existing sell-enquiry form is prefilled with quantity, price and a supported settlement cycle, and explains that counterparty acceptance is needed. Direct execution against a catalog buy deal remains unsupported by the supplied API contract.
- Widening phone checkout keeps the same investor drafts and usable investment form.
- Added regression coverage for all four buyer/seller combinations, refreshed signing links, market pricing, enquiry submission and checkout resizing. Updated the older Institution KYC test to the existing v2 self-KYC contract without changing API permissions.
- Validation: all 457 tests passed, including 17 new regression tests, and the versioned JavaScript web release build succeeded. Static analysis found no errors or new warnings; the two existing warnings in `test/app_motion_test.dart` remain. The optional Wasm probe still reports `get_storage`'s existing `dart:html` incompatibility. Backend/WhatsApp delivery was not tested live.

## 2026-10-13 — Pre-IPO transaction rebuild (buyer / seller)

- Orders now parse `buyer`, `seller` and `order_case`. Detail dialogs show Buyer, Seller, order type and a "You are buying / selling" chip; list rows show "Buying from X" / "Selling to Y". `investor` keeps meaning the partner's own person.
- Server `action` lists get a client safety filter: enquiry orders never show Approve or Reject; the buyer never sees Confirm payment or Upload transfer; the seller never sees Confirm shares or Upload receipt. Side filtering only applies when `buyer` / `seller` match the logged-in partner.
- "Confirm transfer" is now "Confirm shares" and asks for confirmation first. Institutions can confirm shares (`institution/pre-ipo/transaction/confirm-share-transfer`) and open the share-transfer receipt.
- Institutions can buy another Institution's deal with their self investor (no investor picker). Their own deals show a "Your deal" tag and cannot be bought. A missing self investor is reported instead of opening the flow.
- Partners can accept another partner's open enquiry (`enquiries/deals/accept-counterparty`, `uuid` + `investor_id`). The raiser, and a Wealth Manager with their own Relation Manager, are excluded; an optional server `can_accept_counterparty` flag overrides the local check. Withdraw and locked-enquiry decisions stay with the raiser.
- WhatsApp sign / accept / reject / payment / receipt links are unchanged and still open from the message.

## 2026-10-12 — Company-detail offer dialog

- Replaced the uneven seller/investment columns with a full-width investment summary and seller profile, responsive stat cards, and expandable profile sections.
- Added minimum investment amount (share price × minimum quantity) with the calculation shown; buyer offers use “Minimum offer amount”. Legacy seller enquiries display the same investment summary.
- Kept the close control and action footer visible while the dialog body scrolls, preserving the existing purchase and enquiry flows.
- Validation: all 36 offer and company-detail UI tests passed; analysis of the changed widgets and UI tests found no issues. Visually checked desktop/mobile previews in light and dark themes. No backend changes required.

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
