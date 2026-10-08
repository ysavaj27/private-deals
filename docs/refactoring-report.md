# Refactoring report — 7 October 2026

## Scope and approach

Only `private_deals` was changed. The review inventoried all 496 original Dart source files, traced imports/exports/parts including conditional web/native branches and test entry points, inspected the resource owners, large screens, shared helpers, API boundary, dependencies and assets, and made targeted changes in verified groups. This is not a claim of exhaustive manual review of every line or live acceptance of every backend workflow.

Priority: no regression, clean code, reuse, maintainability, performance. The GetX architecture, registered routes, permissions, API endpoints and request payloads, financial calculations, validation messages, and UI layouts were retained. No library versions were upgraded. The sibling Partner and Seller projects were not edited.

## Prioritized plan executed

1. Establish analyzer/test baselines and remove proven dead code and temporary debug instrumentation.
2. Correct ownership and cleanup of screen resources, timers and investor input drafts.
3. Consolidate identical helpers and image handling, and split the large primary landing library without changing its widget tree.
4. Format affected Dart files; run analyzer, VM/browser regressions and platform builds.

## Dead code and dependencies

- Removed 41 Dart files unreachable from the application and all tests, including obsolete models, disconnected legacy views and devtool pages. Dart import reachability includes both conditional platform branches; no removed file has a native entry-point annotation.
- Removed 11 comment-only libraries (including two empty exports), three temporary debug libraries, and one obsolete OTP debug script: **56 files total**.
- Removed approximately 1,900 lines of disabled implementations from active files, plus obsolete debug hooks. Those hooks created extra Dio clients/localhost requests and performed synchronous debug-file writes.
- Removed unused/redundant imports and added supported `const` constructors and explicit return types where appropriate.
- Removed direct dependency declarations for `cupertino_icons`, `fluttertoast`, `google_nav_bar`, `fl_chart`, `excel`, `data_table_2`, `sticky_headers`, and `infinite_scroll_pagination`. `cupertino_icons` remains transitively required. The lockfile loses ten resolved packages in total.
- Declared the existing directly imported `timezone` and `web` packages explicitly, using their already-locked versions. Every retained package version is unchanged.
- Asset audit: 108 files, with ten candidates lacking a literal source path. No assets were deleted because that alone does not establish absence of dynamic/platform use.

## Reuse and organization

- Institution number/date extensions and parsing now re-export their identical shared implementations, retaining the existing import paths.
- Institution `CacheImage` reuses shared URL, cache, fallback and error handling through a small loading-indicator override. Institution keeps its ripple loader; Partner keeps its thin circular loader. Both use the shared `LogoImage`, with the same dimensions, frame, fallback and tap handling.
- Added `InvestorDraftLifecycle` for the three catalog controllers that own selected-investor input rows. Removed rows dispose their inputs after widgets detach, while route closure also releases pending drafts.
- Split `desktop_primary_landing_view.dart` into its existing library plus `primary_landing_content.dart`, `primary_deal_sections.dart`, and `primary_startup_card.dart`. All nine original active class declarations were compared token-by-token (ignoring whitespace/comments/trailing commas); they are unchanged.
- No new general-purpose API abstraction, navigation framework, or third-party package was introduced.

## Resource and performance improvements

- Added missing text, scroll, page, focus and tab-controller cleanup to 19 controllers across catalog, dashboard, transactions, portfolio, investor listing and forms.
- Fixed primary-list carousel ownership: retain its periodic timer, cancel the previous timer on refresh, cancel it in GetX `onClose`, and ignore a response arriving after the controller closes. The three-second cadence and page sequence are unchanged.
- Portfolio refresh now disposes its previous tab controller and uses a ticker provider that supports repeated creation. Previously a second refresh could assert in debug builds and leak the earlier controller.
- Prevented deferred focus/input work from accessing disposed controllers after a screen closes.
- Reuse one private number formatter per locale instead of constructing a formatter for each displayed amount. Grouping, rounding, empty-value behavior and locale changes are covered by tests. Financial arithmetic was not changed.
- Removing debug hooks eliminates extra localhost requests and full-response debug-string construction. No frame-rate or startup-speed benchmark improvement is claimed.

## Tests and validation

- Baseline: **231 VM tests passed**; analyzer reported **189 issues**, including three warnings and no errors.
- Cleanup checkpoint: all **231 VM tests passed** again.
- Final VM suite: **248 tests passed** (17 new regressions).
- New tests cover controller disposal, closing active tab animations, repeated portfolio refresh, carousel timer replacement/cancellation, late carousel responses, mounted investor-row removal, pending-draft cleanup, image/loading/fallback/tap compatibility, parsing defaults and currency/locale behavior.
- `flutter analyze --no-pub --no-fatal-infos`: **exit 0; zero errors and warnings**, with **131 informational notices**. They include retained legacy names, style suggestions and deprecated APIs. No new analyzer suppressions or exclusions were added. Strict `flutter analyze --no-pub` will still treat these infos as a nonzero result.
- `dart format` was run on every modified/new Dart file; `git diff --check` passed.
- Chrome tests: validation running.
- Web release build: validation running.
- Android debug APK build: validation running.
- iOS release build without code signing: validation running.

## Intentionally retained and limits

- Assets without conclusive reference evidence, platform registrations and native plugin dependencies remain intact.
- Existing endpoint-specific error handling, request order, pricing/validation rules, role restrictions and state-management approach were retained; the existing API/role/payload tests guard them.
- The compatibility export barrel and supported legacy screens remain. Large financial forms were not rewritten for stylistic uniformity.
- The historical migration map describes the earlier migration and was retained as history; the removal inventory below records this refactor separately.
- Tests use synthetic identities and fake API responses. Optional live smoke tests do not authenticate without explicit test configuration. Authenticated backend acceptance, file-transfer flows against staging and physical-device UX are not proven by unit/widget tests or compilation.
- No deployment, production data mutation, store signing, or device installation was performed.

## Removed file inventory

- `lib/src/core/configuration/network_service.dart` — comment-only file.
- `lib/src/app/routing/module_access_middleware.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/data/models/user/investor_detail_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/data/models/demat_account/demat_account_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/data/models/3ed_party/pincode_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/data/models/startup/startup_fund_raise_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/data/models/startup/last_round_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/data/models/startup/startup_other_one_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/data/api/3rd_party/address_api.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/kyc_pending_investor/add_kyc/add_kyc_dialog.dart` — comment-only file.
- `lib/src/features/wealth_manager/presentation/kyc_pending_investor/add_kyc/add_kyc_dialog_ctrl.dart` — comment-only file.
- `lib/src/features/wealth_manager/presentation/kyc_pending_investor/add_kyc/phone_add_kyc_view.dart` — comment-only file.
- `lib/src/features/wealth_manager/presentation/kyc_pending_investor/add_kyc/desktop_add_kyc_view.dart` — comment-only file.
- `lib/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_sell_transaction/desktop_pre_ipo_sell_transaction_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_sell_transaction/phone_pre_ipo_sell_transaction_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_sell_transaction/pre_ipo_sell_transaction_page_ctrl.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/secondary_transaction_page.dart` — comment-only file.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/sell_request_page.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/desktop_sell_request_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/phone_sell_request_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/sell_request_page_ctrl.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/desktop_buy_request_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/buy_request_page_ctrl.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/phone_buy_request_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/buy_request_page.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/dashboard/startup_dialog.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/wealth_manager/presentation/dashboard/startup_list.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/auth/presentation/aif_onboarding/desktop_aif_onboarding_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/auth/presentation/aif_onboarding/aif_onboarding_page_ctrl.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/auth/presentation/aif_onboarding/phone_aif_onboarding_view.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/auth/presentation/aif_onboarding/aif_onboarding_page.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/catalog/presentation/primary/primary_landing_stats_strip.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/catalog/presentation/primary/dashboard_drawer.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/catalog/presentation/primary/primary_list_page/commit_now_dialog.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/catalog/presentation/primary/blog_list/blog_list_page.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/catalog/presentation/primary/blog_list/blog_list_page_ctrl.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/institution/legacy/backend/model/transaction/pre_ipo_transaction_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/institution/legacy/backend/model/deal/sell_enquiry_model.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/institution/legacy/backend/api/sell_enquiry_api.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/features/institution/deals/presentation/deal_list/desktop_deal_list_view.dart` — comment-only file.
- `lib/src/features/institution/deals/presentation/deal_list/phone_deal_list_view.dart` — comment-only file.
- `lib/src/features/institution/support/plugins/svg_image.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/shared/plugins/device_info.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/shared/widgets/app_popup.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/shared/widgets/action_menu.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/shared/widgets/info_card.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/shared/widgets/buttons/action_button.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/devtools/test_page_ctrl.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/devtools/test_api.dart` — comment-only file.
- `lib/src/devtools/test_page.dart` — unreachable from entry point, conditional imports, and all tests.
- `lib/src/core/debug/agent_debug_log.dart` — obsolete local debug instrumentation.
- `lib/src/core/debug/debug_log_io.dart` — obsolete local debug instrumentation.
- `lib/src/core/debug/debug_log_stub.dart` — obsolete local debug instrumentation.
- `lib/src/core/configuration/master_config.dart` — comment-only library exported by compatibility barrel.
- `lib/src/features/wealth_manager/data/api/bank_accounts/bank_accounts_api.dart` — comment-only library exported by compatibility barrel.
- `tools/debug_forgot_otp_phone.dart` — obsolete one-shot OTP debug script; no callers.
