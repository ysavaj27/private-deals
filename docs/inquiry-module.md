# Inquiry module

Both seller (Institution) and wealth manager workspaces use the shared feature in
`lib/src/features/enquiries`.

- Seller: existing Inquiry navigation (`/institution/sell-enquiries`).
- Partner: My Inquiries (`/wealth-manager/my-inquiries`) on desktop and mobile.
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

The inquiry API tests use a fake HTTP adapter; no live decisions or transactions
are made. `test/enquiry_flow_test.dart` covers contract payloads, state rules,
rejection validation, investor selection, seller lock races, responsive screens,
mandate delivery failure, transaction handoff, and sell-side endpoints.
