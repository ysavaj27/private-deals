# Daily unlisted price upload (AI instructions)

You are updating Institution sell prices from a WhatsApp rate-sheet **image**. Follow every step. Do not improvise APIs or invent company IDs.

## What the human will give you

1. This file
2. Today’s rate-sheet image (title like **Unlisted Shares Tentative Rates**, date on the sheet)

## Goal

Upload **Selling Price*** from the image to all institutes in `institutes.local.json`, with each institute’s markup. Skip CNC / non-numeric selling prices.

## Working directory

```text
tools/price_upload/
```

Absolute path on this machine (if present):

```text
/Users/kd/Development/Project/PrivateDeals/Application/private_deals/tools/price_upload/
```

## Hard rules

1. **Source column = Selling Price only** (not Landing Price, not Face Value).
2. **Skip** any row where Selling Price is `CNC`, blank, or non-numeric — even if the script name contains `(CNC)`. If the name has `(CNC)` but Selling Price is a number, **still upload** that number.
3. **Do not** hardcode prices inside Python. Write them only to `prices.csv`.
4. **Do not** change markups, mobiles, or passwords unless the human explicitly asks. Read them from `institutes.local.json`.
5. **Always dry-run first**, then `--confirm`. Never `--confirm` if dry-run login fails or matches look wrong.
6. If `www.privatedeals.in` times out, wait and retry (up to 2–3 times). Do not invent a different host.
7. Passwords are case-sensitive. Use exactly what is in `institutes.local.json` (do not normalize case).
8. Unmatched scripts (BOOTES, CREMICA FOOD, OYO ASSET, etc.) are OK to skip if listed under UNMATCHED — report them; do not force wrong matches.
9. Do not commit `institutes.local.json` or `prices.csv`.

## Required files (must exist)

| File | Role |
|------|------|
| `upload.py` | Uploader CLI |
| `institutes.local.json` | Mobiles, passwords, markup %, notional, settlement |
| `aliases.json` | Name aliases |
| `prices.csv` | You overwrite this from the image |

If `institutes.local.json` is missing:

```bash
cp institutes.sample.json institutes.local.json
```

Then stop and ask the human for passwords. Do not guess.

## Step-by-step (do in order)

### 1) Read the image

Extract every row with a **numeric Selling Price**. Prefer reading the actual image file, not only a caption.

Build a table mentally: `script_name` → `selling_price`.

Typical script names (list changes day to day): APOLLO GREEN, BOOTES, CARE INSURANCE, COCHIN INT AIRPORT, CSK, Cremica Food, GOODLUCK DEFENCE, HDFC SECURITIES, Hinduja Finance, HVR SOLAR, INDOFIL, INCRED, MSEI, MOTILAL HOME FIN, MOHAN MEAKIN, NCDEX, MODERN BAZAAR, OYO, OYO ASSET, ORBIS FINANCE, PARAG PARIKH, PHARMEASY, POLYMATECH, ZEPTO, …

CNC examples to skip when price is CNC: INDIAN POTAS, PAYMATE, Power Exchange, RRP, TRL KROSAKI.

### 2) Write `prices.csv`

Overwrite `tools/price_upload/prices.csv` exactly like this (UTF-8, header required):

```csv
script_name,selling_price
APOLLO GREEN,61.95
CARE INSURANCE,150.15
...
```

- Keep script names close to the sheet (aliases handle Care Health, Modern Bazar, etc.).
- Use the numeric Selling Price as shown (keep decimals; do not round unless the sheet already shows rounded values).
- No CNC rows. No Landing Price column.

### 3) Dry-run all institutes

```bash
cd /Users/kd/Development/Project/PrivateDeals/Application/private_deals/tools/price_upload
python3 upload.py
```

Expect for each institute:

- `Logged in as …`
- `Matched: N / M`
- optional `UNMATCHED (skipped): …`
- `Dry-run only …`

If any login fails (`password do not match`, `not registered`), **stop** and ask the human for the correct mobile/password. Do not upload the others with `--confirm` until dry-run is clean for every institute you intend to update (or use `--only N` only if the human asks).

### 4) Upload for real

```bash
python3 upload.py --confirm
```

Success line per institute: `OK: Deals created`

If one institute fails mid-run, fix credentials and retry only that one:

```bash
python3 upload.py --only 3 --confirm
```

(`--only` is 1-based index in `institutes.local.json`.)

### 5) Report back to the human (short)

For each institute: label, markup, OK/FAIL, matched count.

List UNMATCHED scripts.

Mention sheet date from the image.

## Markup (default — already in config)

| # | Typical account | Markup |
|---|-----------------|--------|
| 1 | Hanuman / first mobile | 0% (base Selling Price) |
| 2 | second | +0.5% |
| 3 | third | +1.5% |
| 4 | fourth | +1.0% |

`upload.py` applies `markup_percent` from config. Do not recompute in CSV.

## Known pitfalls (avoid)

- Do **not** paste an old Strootaay / PDF price list into `prices.csv` — only today’s WhatsApp Selling Prices.
- Do **not** map OYO ASSET → company “OYO” (OYO ASSET is often unmatched; leave unmatched).
- CARE INSURANCE maps to Care Health via aliases — do not skip it.
- Institute passwords differ in capitalization (`shuru@123` vs `Shuru@123`) — use config as-is.
- Connection timeouts: retry; do not declare permanent failure after one timeout.

## Optional one-liner for the human

When starting a chat, they can say:

> Use `tools/price_upload/DAILY_UPLOAD_PROMPT.md` and this rate-sheet image. Update today’s prices and upload.
