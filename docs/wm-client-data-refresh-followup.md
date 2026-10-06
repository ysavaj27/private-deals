# Follow-up: WM client data refresh & Send Documents bugs

**Status:** Scheduled — do after backend contract reply (or in parallel if backend confirms APIs are correct).  
**Scope:** Wealth Manager app only. Not for the backend ticket.

These client issues can make Dashboard / Pending Tasks / Send Documents / MIS look stale even when APIs return correct data.

## Refresh / cache

- GetX controllers load mostly in `onInit` — reopening tabs often shows cached lists/counts without refetch.
- Send Documents does not reload the list after a successful `POST v1/business/send-document`.
- Pending Tasks refresh after Complete KYC is incomplete (phone refreshes counts only; desktop refreshes list only).
- Desktop Pending Tasks count chips are not wrapped in `Obx`, so badges may stay at `0`.

## Send Documents correctness

- Desktop may pass nested **document** ids as `transaction_id`; phone uses the primary transaction id.
- Wrong `document_type` mappings for counter slip / RTGS / SHA vs config keys (`chequecounterslip`, `rtgsreceipt`, `sha`).
- Missing `break` after MGT14 ZIP can fall through and also send Offer.

## Dashboard chart logic

- Active / Inactive pie filters on `kyc_status` instead of `is_active` (`DashboardPageCtrl.setData`).

## Suggested order

1. Wait for backend confirmation on `pending_payment` (count vs amount) and document_type enum.
2. Fix Send Documents id + document_type + MGT fallthrough.
3. Add refetch-on-tab-visible / post-action refresh for Dashboard, Pending Tasks, Send Documents, MIS.
4. Fix desktop Pending Tasks `Obx` + Active/Inactive pie filter.
