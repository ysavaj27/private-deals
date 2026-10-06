# Optional pre-IPO transaction details

The partner and institution Detail/More dialogs accept these additional fields on
`PreIpoOrderModel`. They follow the seller transaction detail field names. The updated API sample supplies invoice, creation date, investment amount and
`status_list`. The remaining fields below are optional; absent data is hidden.

Add these keys to the existing transaction detail response's `data` object (and
optionally to list rows). Keep `order_step`, `action`, prices,
payment details, receipts, and documents as they are today. The latest response
uses `current_step` and `next_step`; these populate the existing current/next UI.
The old `current` and `next` keys remain supported as fallbacks.

```json
{
  "transaction_invoice_no": "PRE-IPO-481",
  "created_at": "2026-10-01T10:00:00Z",
  "settlement_date": "2026-10-06",
  "payment_mode": "Bank transfer",
  "instrument": "Equity shares",
  "investment_amount": "10000.00",
  "processing_fee": "100.00",
  "coupon_discount_amount": "0.00",
  "percentage": 40,
  "current_status": "Payment pending",
  "next_step": "Upload the payment receipt.",
  "status_list": [
    {
      "title": "Order placed",
      "description": "Your order has been created.",
      "date": "2026-10-01T10:00:00Z",
      "is_active": false
    },
    {
      "title": "Payment",
      "description": "Transfer payment and upload the receipt.",
      "date": null,
      "is_active": true
    },
    {
      "title": "Share transfer",
      "description": "The institution will transfer the shares.",
      "date": null,
      "is_active": false
    }
  ]
}
```

All new fields are optional. Missing, null, or invalid amounts are hidden; numeric
zero is displayed as zero. Amounts and percentage accept JSON numbers or numeric
strings. Dates accept ISO date/timestamp strings and display in local time.
Percentage uses a 0–100 scale and is clamped for display; it is never inferred from
the order step. Keep the existing `payable_amount` as the authoritative total.

Return timeline entries in display order. An explicit `is_completed` flag controls completion, even when `date` is null.
When that flag is absent, a valid date marks completion. `is_active` marks the
current incomplete step. Supply `is_completed` on every entry to disambiguate
undated historical steps. A step can also contain a `document` object with `name`,
`url`, `path`, and `id`; its link appears beneath that step.
The timeline is read-only. Its entries do not introduce action buttons or change
the top-level action flow. The current status and next step remain in the progress header;
identical `current_status` and `next_step` text is not repeated in the progress panel.

Until these fields are returned, the existing detail content remains in place
without empty overview/progress sections or invented fee/progress values.

## Missing from the supplied updated response

To fill every seller detail, return `percentage` (0–100), `payment_mode`,
`instrument`, `settlement_date`, `processing_fee`, and `coupon_discount_amount`.
No separate `current_status` is needed because `current_step` supplies that text.

The sample's “Share Confirmed” entry has no date or completion flag, despite the
order being completed. Supply `is_completed` for that step (and preferably all
steps); supply its real timestamp if the date should be shown. The final
“Transaction Completed” flag is supported, but its date is also missing.

## Timeline completion display

The active entry keeps its current-step indicator. All entries before it display
as completed, including those without timestamps or completion flags. A completed
order displays all non-active steps as completed. Without an active step or a
completed order, entries use their own completion flag/date; cancellation does
not mark remaining steps complete. Missing dates remain hidden.
