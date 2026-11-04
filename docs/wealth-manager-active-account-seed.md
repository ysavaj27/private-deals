# Wealth manager seed — basic active account

Create one Wealth Manager that already looks in use: a profile, two investors, and two completed investments. This is the minimum set. Do not add extra investors, deals, enquiries, notifications, or channel partners.

The wealth manager app reads these APIs. After seeding, each one should return the values in [What the app should show](#what-the-app-should-show).

| Screen | API |
|---|---|
| Profile | `GET /api/v1/business/profile` |
| Investors | `GET /api/v2/business/investor` |
| Private Equity dashboard | `GET /api/v1/business/dashboard` |
| Unlisted dashboard | `GET /api/v1/business/dashboard-pre-ipo` |
| Equity portfolio | `GET /api/v2/business/portfolio/startup?type=equity` |
| Unlisted portfolio | `GET /api/v2/business/portfolio/pre-ipo` |
| Private Equity transactions | `GET /api/v1/business/primary-transactions` |
| Unlisted transactions | `GET /api/v2/business/pre-ipo/transaction-list` |
| Earnings | `GET /api/v2/business/earning/investor` |

Two dashboards are separate. The Private Equity deal must appear only on the Private Equity dashboard and equity portfolio. The Unlisted deal must appear only on the Unlisted dashboard and unlisted portfolio.

## Dates

Do not store a fixed calendar date. Count backwards from the day you insert the rows.

| When | Use it for |
|---|---|
| 120 days ago | Private Equity transaction and its portfolio holding |
| 15 days ago | Unlisted transaction and its portfolio holding |
| 10 days ago | Unlisted `settlement_date` only |

Use the same clock time for `created_at` and `updated_at` on a row. Example: if you seed on the morning of a given day, "120 days ago" is that same time of day, 120 days earlier.

Why these two gaps:

- The activity chart groups by the holding or transaction `created_at`: one point per `YYYY-MM`, and one point per calendar quarter.
- 120 days and 15 days are 105 days apart, so they always fall in different months and different quarters, on any day you run the seed.
- 10 days ago is still in the past, and it is 5 days after the Unlisted `created_at`.

If `GET /api/v1/business/dashboard` fails, the app rebuilds the Private Equity chart from the equity portfolio. It reads each holding's `created_at`, skips a year before 1900, and sums `investment_amount` into that month and quarter. The Private Equity holding `created_at` must be 120 days ago even when the dashboard API works.

Build the Unlisted chart in `GET /api/v1/business/dashboard-pre-ipo` from the Unlisted transaction `created_at` (15 days ago). Put that same timestamp on the unlisted holding if that table has `created_at`.

## Leave empty

Do not create any of these for this account:

- Channel partners, distributors, retailers, relation managers
- Enquiries
- Notifications
- Secondary transactions
- Documents to sign
- MIS reports
- Pending KYC, pending document signature, or pending fund transfer
- CCPS or CCD holdings
- A third investor

Pending-task counts on both dashboards stay `0`. The Channel Partner menu is still visible because the partner type is Wealth Manager. Its list stays empty. Earnings → From channel partners stays empty.

## 1. Wealth manager

Create the partner with your normal Wealth Manager flow. That flow already creates the self investor. Do not insert a second investor for the manager.

| Field | Value |
|---|---|
| `type` | `Wealth Manager` |
| `commission` | `2` (percent) |
| `is_primary_access` | `1` |
| `is_secondary_access` | `1` |
| `is_preipo_access` | `1` |
| `is_verified_mobile` | `1` |
| `is_verified_email` | `1` |
| `is_blocked` | `0` |
| `is_deleted` | `0` |
| `ask_password_change` | `0` |

Also set name, mobile, email, gender, address, city, state, country, pincode, and a profile photo the app can load.

After create, `GET /api/v1/business/profile` must return a non-null `self_investor_id`. That id is Investor A below. If the create flow did not attach one, create exactly one investor, set `is_self = 1`, and store its id in `self_investor_id`. Do not leave `self_investor_id` null.

All three access flags are required. Private Equity and Unlisted tabs are hidden when their flag is off. Documents is hidden when both Private Equity and LP Secondary access are off.

## 2. Investors

Two investors total.

### Investor A — self, already created

Do not create this row. Update the auto-created self investor so the list is not blank.

| Field | Value |
|---|---|
| `is_self` | `1` |
| Linked partner | this Wealth Manager |
| `id` | matches profile `self_investor_id` |
| `is_active` | `1` |
| `kyc_status` | `1` (approved) |
| Name, mobile, email, profile photo | set. The app shows this person as `[Self] {name}` |

This investor owns the Private Equity deal only.

### Investor B — create this one

Create one normal investor under this Wealth Manager.

| Field | Value |
|---|---|
| `is_self` | `0` |
| `is_active` | `1` |
| `kyc_status` | `1` (approved) |
| Name, mobile, email, profile photo | set, and different from Investor A |

This investor owns the Unlisted deal only.

`GET /api/v2/business/investor` returns both rows. One has `is_self = 1`.

## 3. Use companies that already exist

Do not create a startup or an unlisted company for this seed.

| Deal | Pick |
|---|---|
| Private Equity | An existing startup that already has a brand name, a logo, and a sector id and sector name |
| Unlisted | An existing unlisted company that already has a brand name and a logo |

One startup and one company is enough. They must be different records.

## 4. Private Equity deal — Investor A, 120 days ago

Insert one completed primary investment and the equity holding it created. Both rows describe the same deal.

Sample amounts below are safe to change. If you change them, keep all of these true:

- `investment_amount = shares × purchase_price`
- current value = `shares × current_share_price`
- `current_share_price` is higher than `purchase_price`
- this amount stays larger than the Unlisted amount in section 5

| Field | Value |
|---|---|
| Investor | Investor A (self) |
| Startup | the existing startup from section 3 |
| Instrument | `equity` |
| Shares | `500` |
| `purchase_price` / `share_price` | `200` |
| `investment_amount` | `100000` |
| `current_share_price` | `240` |
| `current_value` | `120000` |
| `shares_sold` | `0` |
| `on_sell_shares` | `0` |
| `is_primary_transaction` | `1` |
| Payment | received. Use a real payment mode your primary flow already stores, such as RTGS |
| Status | the same completed status a finished live primary investment uses |
| `current_status` | the completed label that API already returns for a finished primary deal |
| `created_at` | 120 days ago, on both the transaction and the holding |
| `updated_at` | the same timestamp as `created_at` |

`GET /api/v2/business/portfolio/startup?type=equity` must return this holding under Investor A, with startup brand name, logo, sector id, sector name, and the `created_at` above.

The equity portfolio request uses `type=equity`. A CCPS or CCD instrument will not show on the Equity tab and will not fill the Private Equity dashboard fallback.

## 5. Unlisted deal — Investor B, 15 days ago

Insert one completed unlisted buy and the holding it created.

| Field | Value |
|---|---|
| Investor | Investor B |
| Company | the existing unlisted company from section 3 |
| Shares | `100` |
| `share_price` / `purchase_price` | `500` |
| `investment_amount` | `50000` |
| `current_share_price` | `550` |
| `current_value` | `55000` |
| `shares_sold` | `0` |
| `on_sell_shares` | `0` |
| Status | completed |
| `current_status` | the completed label your unlisted transaction API already returns |
| `percentage` | `100` |
| `created_at` | 15 days ago, on the transaction and on the holding if that column exists |
| `updated_at` | the same timestamp as `created_at` |
| `settlement_date` | 10 days ago |

Add a `status_list` in display order. Mark every step completed. Put each step date on or after `created_at` and on or before `settlement_date`. Include `transaction_invoice_no`.

`GET /api/v2/business/portfolio/pre-ipo` must return this holding under Investor B, with company `brand_name` and `logo`.

## 6. Earnings

Store commission the same way a live completed deal stores it. With partner `commission = 2`, the earning API should return 2% of each `investment_amount`.

`GET /api/v2/business/earning/investor`:

| | Amount invested | Transactions | Commission |
|---|---:|---:|---:|
| Investor A | 100000 | 1 | 2000 |
| Investor B | 50000 | 1 | 1000 |
| Response totals | 150000 | 2 | 3000 |

Each row in `investors_list` needs `investor_id`, `name`, `profile_photo`, `amount_invested`, `total_transactions`, and `commission_earned`. Both `commission_earned` values must be greater than 0. The app hides a zero commission on the dashboard and shows an empty earnings list when every row is zero.

If a live deal does not use a flat 2% of `investment_amount`, use that live rule instead, and keep both investors above zero. Then the totals above change with that rule.

Do not create partner-earning rows. `GET /api/v1/business/earning/partner` can return zeros and an empty list.

## What the app should show

### Profile

Name, photo, mobile, email, address, and commission 2%.

### Investors

Two people. Investor A is marked self. Both are active and KYC approved.

### Dashboard — Private Equity tab

This tab calls `GET /api/v1/business/dashboard`.

| Field | Value |
|---|---|
| `total_amount_invested` | `100000` |
| `average_ticket_size` | `100000` |
| `total_investors` | `1` |
| `total_startups` | `1` |
| `pending_kyc` | `0` |
| `pending_documents` | `0` |
| `pending_fund_transfer` | `0` |
| `pending_payment` | `0` |
| `investors` and `top_investors` | Investor A, `amount_invested` 100000, `total_startups` 1, `commission_earned` 2000, name and profile photo set |
| `sectors` | one sector, the startup's real sector name, `total_investment` 100000, one startup row |
| `investment_growth` | one company, `total_invested_amount` 100000, `current_value` 120000, logo set |
| `investments.monthly` | one entry: the `YYYY-MM` of 120 days ago, `total_investment` 100000 |
| `investments.quarterly` | one entry: the quarter that contains 120 days ago, `total_investment` 100000, with `start` and `end` |
| `investor_chart.active` and `investor_chart.kyc` | Investor A, `is_active` 1, `kyc_status` 1 |

`investment_growth.current_value` must be a real number. The performance chart only draws a gain when that value is present and higher than `total_invested_amount`.

### Dashboard — Unlisted tab

This tab calls `GET /api/v1/business/dashboard-pre-ipo`. Same shape as above, with the Unlisted deal only.

| Field | Value |
|---|---|
| `total_amount_invested` | `50000` |
| `average_ticket_size` | `50000` |
| `total_investors` | `1` |
| `total_startups` | `1` |
| Pending counts | `0` |
| `investors` and `top_investors` | Investor B, `amount_invested` 50000, `commission_earned` 1000 |
| `investment_growth` | `total_invested_amount` 50000, `current_value` 55000, company name and logo set |
| `investments.monthly` | the `YYYY-MM` of 15 days ago, `total_investment` 50000 |
| `investments.quarterly` | the quarter that contains 15 days ago, `total_investment` 50000 |

### Portfolio

- Equity tab: Investor A, one startup, invested 100000, current value 120000, gain about 20%.
- CCPS and CCD tabs: empty.
- Unlisted tab: Investor B, one company, invested 50000, current value 55000.

### Transactions

- Private Equity: one completed row for Investor A, 120 days ago, amount 100000.
- Unlisted: one completed row for Investor B, created 15 days ago, settled 10 days ago, amount 50000.
- Secondary: empty.

### My Earnings

- From investors: totals 2 transactions, 150000 invested, 3000 commission, with A above B.
- From channel partners: empty.

## Checks

1. Profile `self_investor_id` equals Investor A, and the investor list marks that row `is_self = 1`.
2. Investor list length is 2.
3. Private Equity dashboard month is the month of 120 days ago, and it does not include the 50000 unlisted amount.
4. Unlisted dashboard month is the month of 15 days ago, and it does not include the 100000 private equity amount.
5. Those two months are different, and those two quarters are different.
6. Equity portfolio `type=equity` returns the holding with `created_at` 120 days ago.
7. Earnings returns both investors with `commission_earned` greater than 0.
8. Enquiries, notifications, channel partners, secondary transactions, and pending tasks are empty.
