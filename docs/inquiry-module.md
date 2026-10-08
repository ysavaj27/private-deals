# Inquiry module

Both seller (Institution) and wealth manager workspaces use the shared feature in
`lib/src/features/enquiries`.

- Seller: existing Inquiry navigation (`/institution/sell-enquiries`).
- Partner: My Inquiries (`/wealth-manager/my-inquiries`) on desktop and mobile.
- Successful enquiry creation from Pre-IPO or Secondary company detail opens
  My Inquiries. Cancellation, validation errors, and API failures keep the user
  on the current screen. The dialog owns its input controllers through its
  closing animation and scrolls when screen height is limited.
- Successful Pre-IPO purchases open Partner Transactions with `asset=unlisted`.
  The Unlisted selection applies to both desktop and mobile tabs, including
  reused transaction controllers. Completed forms are removed from the app's
  navigation stack to prevent returning to an already-submitted draft.
- Inquiry creation uses `POST v2/business/enquiries/deals`, with `deal_type`,
  `company_slug`, `quantity`, `share_price`, and optional `notes`. The price entered
  is the base price; the returned customer price includes the processing fee.
  The API contract does not support an expiry or an existing deal identifier.
- Seller decisions use `v2/business/institution/enquiries/accept` and `/reject`.
  Rejection reason is optional. The list is refreshed after every decision,
  including rejected requests caused by another Institution accepting first.
- Partners can withdraw open, unlocked inquiries. Locked inquiries require an
  investor selection to approve or a nonblank reason (maximum 1000 characters)
  to reject. Partner decisions use `v2/business/enquiries/deals/{action}`.
- Approval returns the backend-created order and offers its transaction details.
  `mandate_sent: false` remains a successful conversion, with the server's warning
  shown. The app does not create a second order or resend the mandate.
- Converted inquiries link to Transactions. The seller list hides mandate-pending
  orders. Both workspaces retain the server's `trade_side` and render actions from
  `action`, including the sell-side payment and share-transfer actions.
  Partner links explicitly select Unlisted; Institution links open
  `/institution/unlisted-transactions`. Institutions receive and decide on
  enquiries rather than using the Partner company's purchase/enquiry form.

The inquiry API tests use a fake HTTP adapter; no live decisions or transactions
are made. `test/enquiry_flow_test.dart` covers contract payloads, state rules,
rejection validation, investor selection, seller lock races, responsive screens,
mandate delivery failure, transaction handoff, and sell-side endpoints.
`test/pre_ipo_navigation_test.dart` covers purchase success/failure navigation,
enquiry success/failure/cancellation at phone and desktop sizes, both workspaces'
converted-enquiry links, and synchronized transaction tabs.
