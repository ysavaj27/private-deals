# Firebase Analytics

The app uses the existing Firebase project `private-deals-e672b` and web measurement ID `G-HS6FVQDDFE`. Analytics is initialized after Firebase and session restoration. No Firebase console settings or hosting deployments are changed by this implementation.

## Collection and identity

`Analytics` in `lib/src/core/analytics/analytics_service.dart` owns the SDK. Session validation sets the authenticated partner's numeric user ID and `partner_role`; logout, session expiry, and signing in again clear both. A startup without a validated session also clears the SDK's previous identity. Selected investors never become the analytics user.

SDK calls are ordered, asynchronous, and limited to two seconds per operation. A failed identity update or timed-out SDK call stops further wrapper events for that app run, preventing events under an uncertain identity. Business actions continue independently. Business responses that arrive after the account changes are not recorded for the new account.

One navigator observer records `screen_view` on page pushes, replacements, and pops. Dialogs, sheets and snackbars do not create page visits. Screen names use registered route templates with company slugs, investor IDs, query strings and fragments removed. Wealth-manager tab names are expanded from the known tab enum so dashboards and other tabs remain distinct. Unregistered routes become `unknown`.

## Events

- Authentication: `login`, `login_failed`, `logout`.
- Interaction: `ui_tap`, with a stable `name` and `screen`. Shared controls accept `analyticsName`; generic controls use `button_press`, `tab_select`, `refresh`, or `download`. Display labels are not used automatically because they may contain investor names or other private text. An empty explicit name opts out.
- Catalog: `pre_ipo_detail_view`, `primary_detail_view`, `secondary_detail_view`, and `pre_ipo_offer_select` retain the existing company/deal reporting fields.
- Orders: `pre_ipo_buy`, `pre_ipo_sell_request`, `primary_investment`, and `transaction_action`. Transaction actions include approve, reject, cancel, receipt upload, payment confirmation, and share-transfer confirmation, with `actor` distinguishing institution and partner endpoints.
- Enquiries: `enquiry_submit`, `enquiry_response`, `enquiry_quote_submit`, `enquiry_quote_withdraw`, and `enquiry_quote_accept`. Enquiry responses include accept, reject, withdraw, and accept-counterparty.
- Seller deals/prices: `deal_create`, `deal_update`, `deal_delete`, `share_price_update`, `price_excel_download`, `price_excel_review`, and `price_excel_save`.
- Investor/portfolio: `investor_add`, `investor_update`, `investor_kyc_submit` (the CML save flow), and `portfolio_add`.

Business outcome events are recorded at the shared API boundary, once per invocation, even when the original view closes. `success` is `1` for a successful API result and `0` for a rejected result, local API validation failure, or transport error. These events describe the operation result; a successful order submission is not evidence of settlement or payment. Cancelled dialogs that never invoke an API do not create outcome events.

Events carry `partner_role` when authenticated; API outcome events also carry their originating `screen`. Only explicitly selected reporting fields are included. Request/response bodies, credentials, investor identity fields, rejection reasons, notes, KYC values, uploaded file names/content, and error messages are not copied into events. The wrapper keeps at most 25 parameters, clips string values to 100 characters, converts booleans to 0/1, and excludes objects and non-finite numbers. Firebase's own automatic web events and page-location collection are managed separately by the SDK/property settings.

## Validation and reporting

Run the mocked regression tests without making live API or Firebase requests:

```sh
flutter test --no-pub test/analytics_service_test.dart test/analytics_flows_test.dart
```

For an end-to-end check, use a test account in a development/staging build and enable DebugView using Firebase's [documented browser/device setup](https://firebase.google.com/docs/analytics/debugview). Web uses the Google Analytics Debugger extension; Android uses `adb shell setprop debug.firebase.analytics.app PACKAGE_NAME`; Apple platforms use the Xcode `-FIRDebugEnabled` launch argument. A Flutter debug build or a consent call alone does not enable DebugView.

1. Sign in once as a wealth manager and once as an institution. Check `user_id` and `partner_role`.
2. Navigate between pages, open/close a dialog, and go back. Expect one `screen_view` per page transition and none for the dialog. Different company detail URLs should share a screen name.
3. Exercise relevant business actions in the test environment. Inspect the outcome event and its `success`, `action`, `actor`, and company fields where applicable.
4. Sign out or expire the session. Check that the next anonymous events have no user ID or role.
5. Register the parameters needed for reports as GA4 custom definitions, such as event-scoped `partner_role`, `screen`, `name`, `action`, `actor`, `deal_side`, and `success`; use user-scoped `partner_role` if needed for user segmentation. Follow Google's [custom-dimension guidance](https://support.google.com/analytics/answer/14240153), and avoid unnecessary high-cardinality definitions for IDs.

A local passing test confirms instrumentation behavior, not delivery to the Firebase console. DebugView verification and custom-definition setup require the target Firebase/GA4 property. Configure developer traffic filtering in that property if test traffic should be excluded from reporting; see the DebugView documentation above.

## Local verification for this change

On 2026-10-15, all 17 analytics tests passed. The affected regression selection passed 158 tests and failed five tests: four KYC dialog expectations in `investor_transaction_kyc_test.dart` and one bulk-price layout overflow in `seller_workspace_test.dart`. Those same five failures reproduced in an isolated copy with this task's changes removed. Static analysis reported no errors and two existing warnings in `app_motion_test.dart` (plus informational lints). The web release compiled successfully. No live Firebase/GA4 delivery check or deployment was performed.
