# Daily price upload (no AI)

Standalone tool to push the WhatsApp **Selling Price** sheet into Institution accounts.

## Give this to an AI instead

Attach **`DAILY_UPLOAD_PROMPT.md`** + today’s rate-sheet image, and say:

> Follow DAILY_UPLOAD_PROMPT.md and upload today’s prices.

The AI should overwrite `prices.csv`, dry-run, then `--confirm`. No code changes needed.

## One-time setup

1. Install Python 3.9+ and deps:

```bash
cd tools/price_upload
pip3 install -r requirements.txt
```

2. Create local institute config (passwords stay on this machine):

```bash
cp institutes.sample.json institutes.local.json
```

Edit `institutes.local.json` — set each `password`, and adjust `mobile` / `markup_percent` if needed.

3. (Optional) Zip and share this folder with ops. They only need Python + the two local files above.

## Every day

1. Copy today’s Selling Prices into a CSV (skip CNC rows):

```bash
cp prices.sample.csv prices.csv
```

Edit `prices.csv` — columns:

| script_name | selling_price |
|-------------|----------------|
| APOLLO GREEN | 61.95 |
| CARE INSURANCE | 150.15 |

2. Dry-run (login + match + show rows, **no upload**):

```bash
python3 upload.py
```

3. Upload for real:

```bash
python3 upload.py --confirm
```

### Useful flags

```bash
python3 upload.py --only 3              # one institute (1-based)
python3 upload.py --prices today.csv
python3 upload.py --config institutes.local.json --confirm
```

## Rules (same as before)

| Institute | Markup |
|-----------|--------|
| 1 | base (0%) |
| 2 | +0.5% |
| 3 | +1.5% |
| 4 | +1.0% |

- `min_qty` ≈ `notional / base` (default notional **35000** in config)
- Settlement **T+N** from `settlement_days` in config (default **1**)
- Names matched to catalog via `list-lite` + `aliases.json`
- Unmatched scripts are listed and skipped

## Safety

- Default is **dry-run**. Only `--confirm` writes.
- Do **not** commit `institutes.local.json` or daily `prices.csv` with secrets/prices if you share the repo publicly.
- Rates are time-limited (till 2 pm on the sheet) — run the same day.

## Export to another laptop

Copy the whole `price_upload` folder, then on the new machine:

```bash
pip3 install -r requirements.txt
cp institutes.sample.json institutes.local.json   # fill passwords
cp prices.sample.csv prices.csv                   # fill today
python3 upload.py
python3 upload.py --confirm
```
