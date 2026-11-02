# Inquiry module

Both seller (Institution) and wealth manager workspaces use the shared feature in
`lib/src/features/enquiries`.

- Seller: an expandable **Enquiries** sidebar contains **My Inquiry**
  (`/wealth-manager/my-inquiries`) and **All Enquiries**
  (`/institution/sell-enquiries`). Both retain the Institution shell, including
  direct URLs and refreshes. Compact screens expose the same choices as sub-tabs
  under the Enquiries bottom navigation item (Share Price remains under Unlisted).
- Seller My Inquiry uses `GET v2/business/enquiries/deals` and filters the list,
  search, and counts to the logged-in seller's own buy and sell enquiries. It uses
  the existing ownership model: legacy responses without a partner ID are treated
  as owned because that contract returned only the caller's enquiries.
- Seller All Enquiries uses `GET v2/business/institution/enquiries` for incoming
  buy and sell requests. Records explicitly owned by the logged-in seller are
  excluded. Eligible open requests expose Approve, Reject, and Send Quote.
- Partner: My Inquiries (`/wealth-manager/my-inquiries`) on desktop and mobile.
  Its existing owner/counterparty list remains available to Wealth Managers,
  Distributors, and Retailers; Relation Managers remain excluded. Institution
  access to this exact shared URL does not grant access to other Partner pages.
- Successful enquiry creation from Pre-IPO or Secondary company detail opens
  `/wealth-manager/my-inquiries`, using the authenticated workspace's shell.
  Institutions raise sell enquiries from the seller deals board
  against buyer interest using the same create dialog and
  `POST v2/business/enquiries/deals` endpoint as partners. Cancellation,
  validation errors, and API failures keep the user on the current screen. The
  dialog owns its input controllers through its closing animation and scrolls
  when screen height is limited. While creation is pending, inputs and dismissal
  are disabled so a successful submission cannot be abandoned and submitted
  again. A completed or disposed dialog cannot submit again or close another
  route; responses from an earlier login session cannot navigate the current one.
- Successful Pre-IPO purchases open Partner Transactions with `asset=unlisted`.
  The Unlisted selection applies to both desktop and mobile tabs, including
  reused transaction controllers. Completed forms are removed from the app's
  navigation stack to prevent returning to an already-submitted draft.
- Inquiry creation uses `POST v2/business/enquiries/deals`, with `deal_type`,
  `company_slug`, `quantity`, `share_price`, `settlement_days` (required for buy
  and sell), and optional `notes`. The price entered is the base price; the
  returned transaction price includes the processing fee. The API contract does not
  support an expiry or an existing deal identifier.
- All Enquiries uses the shared component's incoming Institution inbox mode.
  Its decisions on original terms use `v2/business/institution/enquiries/accept`
  and `/reject` with `uuid` only on accept (no `settlement_days`). Rejection
  reason is optional. The list is refreshed after every decision, including
  rejected requests caused by another Institution accepting first.
- In incoming inbox mode, Institutions can send, replace, or withdraw a single counter-quote via
  `POST .../institution/enquiries/quote` and `.../quote/withdraw`. While a
  pending `my_quote` exists, Approve original is unavailable until the quote is
  withdrawn. The Institution screen shows only `my_quote`, never other
  Institutions' quotes.
- Inquiry owners see quotes and can accept a pending quote on their own open,
  unlocked enquiry with
  `POST .../enquiries/deals/quotes/accept` (`uuid`, `quote_uuid`, `investor_id`).
- In My Enquiries, partners and Institutions can withdraw their own open,
  unlocked inquiries. Their locked inquiries require an
  investor selection to approve or a nonblank reason (maximum 1000 characters)
  to reject. Partner decisions use `v2/business/enquiries/deals/{action}`.
  Accepting original terms, a quote, or another partner's open enquiry rechecks
  the selected investor's KYC before submitting. Only known buy/sell enquiries
  with valid identifiers expose these actions. Quotes from a completed or locked
  enquiry do not re-enable its actions. Related Relation Managers under the same
  Wealth Manager cannot act as counterparties unless the server explicitly
  allows it.
- Seller My Inquiry does not expose counterparty acceptance because other
  partners' enquiries are excluded. All Enquiries uses Institution inbox actions
  for both buy and sell requests; accepting original terms locks the request for
  its owner's decision rather than immediately creating another order.
- Approval returns the backend-created order and offers its transaction details.
  `mandate_sent: false` remains a successful conversion, with the server's warning
  shown. The app does not create a second order or resend the mandate.
- Converted inquiries link to Transactions. The seller list includes mandate-pending
  orders under Pending. Both workspaces retain the server's `trade_side` and render actions from
  `action`, including the sell-side payment and share-transfer actions.
  Partner links explicitly select Unlisted; Institution links open
  `/institution/unlisted-transactions`. Seller My Enquiries tracks enquiries
  raised from the deals board with the partner enquiry APIs; institutions do
  not use the partner company purchase form. Newly created transaction details
  and subsequent actions select the Institution endpoints from the authenticated
  role, independently of the enquiry list API. Opening details does not register
  an extra transaction page controller.

The inquiry API tests use a fake HTTP adapter; no live decisions or transactions
are made. `test/enquiry_flow_test.dart` covers contract payloads, state rules,
rejection validation, investor selection, seller lock races, quote
send/replace/withdraw, partner quote accept, responsive screens, mandate
delivery failure, transaction handoff, and sell-side endpoints.
`test/wealth_enquiry_integration_test.dart` exercises the real Wealth Manager
routes at 390px, 1024px, and 1440px: sidebar entry, mixed own/counterparty lists,
filters and retry, buy/sell approvals and quote/counterparty acceptance, KYC
rechecks, mandate-delivery warnings, transaction details, and the Unlisted
transaction destination. It also checks KYC changes and already-converted
responses after investor selection. Compact navigation buttons share the
available width, and the desktop transaction heading/tabs wrap when needed.
`test/pre_ipo_navigation_test.dart` covers purchase success/failure navigation,
enquiry success/failure/cancellation at phone and desktop sizes, both workspaces'
converted-enquiry links, and synchronized transaction tabs.
`test/seller_enquiry_navigation_test.dart` covers both seller deep links, nested
navigation at compact and desktop widths, ownership-filtered lists/counts,
workspace permissions, and Institution approve/reject/quote payloads for both
buy and sell enquiries.
The `test/seller_enquiry_*_test.dart` regressions cover seller submission races,
failure/retry, ownership and stale actions, self/client investor KYC checks,
actual seller routes, and approval/quote/counterparty conversion through seller
transaction detail and payment actions at phone and desktop widths. These are
mocked integration tests; backend authorization, mandate delivery, and actual
settlement must still be verified against staging before release.
