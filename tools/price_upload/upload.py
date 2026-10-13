#!/usr/bin/env python3
"""Daily Institution sell-price uploader (no AI required).

1. Copy prices.sample.csv → prices.csv and fill Selling Prices from the rate sheet.
2. Copy institutes.sample.json → institutes.local.json and set passwords.
3. Dry-run:  python3 upload.py
4. Upload:   python3 upload.py --confirm

Skip CNC / blank selling prices in the CSV (leave them out or use empty price).
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Any

try:
    import requests
except ImportError:
    print("Install deps: pip install -r requirements.txt", file=sys.stderr)
    sys.exit(1)

HERE = Path(__file__).resolve().parent
HEADTOKEN = os.environ.get(
    "PD_HEADTOKEN",
    "FBvBeiP253uCFK0VEUO6RWQhXlXp4PmeK1ZY1NbzhahertMCcgjoCMfpmWpe",
)


@dataclass
class Company:
    id: int
    brand: str
    legal: str
    brand_n: str
    legal_n: str


def normalize(name: str) -> str:
    s = name.upper().strip()
    s = re.sub(r"\([^)]*\)", " ", s)
    s = s.replace("&", " AND ")
    s = re.sub(r"[^A-Z0-9]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    for noise in (
        " LIMITED",
        " LTD",
        " PRIVATE",
        " PVT",
        " ONLY NSDL",
        " NSDL ONLY",
        " NSDL",
        " DEPARTMENT STORE",
    ):
        if s.endswith(noise.strip()) or s.endswith(noise):
            s = re.sub(re.escape(noise.strip()) + r"$", "", s).strip()
    s = re.sub(r"\bBAZAAR\b", "BAZAR", s)
    return s


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def load_prices(path: Path) -> dict[str, float]:
    prices: dict[str, float] = {}
    with path.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        if not reader.fieldnames:
            raise SystemExit(f"Empty CSV: {path}")
        fields = {h.strip().lower(): h for h in reader.fieldnames if h}
        name_key = fields.get("script_name") or fields.get("script") or fields.get(
            "name"
        )
        price_key = (
            fields.get("selling_price")
            or fields.get("sell_price")
            or fields.get("base_price")
            or fields.get("price")
        )
        if not name_key or not price_key:
            raise SystemExit(
                "CSV needs columns script_name and selling_price "
                f"(found: {reader.fieldnames})"
            )
        for row in reader:
            raw_name = (row.get(name_key) or "").strip()
            raw_price = (row.get(price_key) or "").strip()
            if not raw_name:
                continue
            if not raw_price or raw_price.upper() == "CNC":
                continue
            try:
                value = float(raw_price.replace(",", ""))
            except ValueError:
                print(f"Skip non-numeric price for {raw_name!r}: {raw_price!r}")
                continue
            if value <= 0:
                continue
            key = normalize(raw_name)
            if not key:
                continue
            prices[key] = value
    if not prices:
        raise SystemExit(f"No priced rows in {path}")
    return prices


def load_aliases(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    raw = load_json(path)
    return {normalize(k): normalize(v) for k, v in raw.items()}


def api_base(config: dict[str, Any]) -> str:
    base = os.environ.get("PD_BASE_URL") or config.get(
        "base_url", "https://www.privatedeals.in/"
    )
    return base.rstrip("/") + "/api/"


def login(api: str, mobile: str, password: str) -> dict[str, Any]:
    device_id = f"price-upload-{uuid.uuid4().hex[:12]}"
    headers = {
        "headtoken": HEADTOKEN,
        "deviceid": device_id,
        "devicetype": "web",
        "usertype": "distributor",
        "isdebug": "1",
        "Content-Type": "application/json",
    }
    body = {
        "mobile_no": mobile,
        "password": password,
        "firebase_token": "N/A",
        "device_id": device_id,
        "device": "web",
    }
    r = requests.post(api + "v1/business/login", headers=headers, json=body, timeout=60)
    r.raise_for_status()
    payload = r.json()
    if not payload.get("status"):
        raise RuntimeError(f"Login failed for {mobile}: {payload.get('message')}")
    data = payload["data"]
    if str(data.get("type", "")).lower() != "institution":
        raise RuntimeError(
            f"Account {mobile} type={data.get('type')!r}, expected Institution"
        )
    return {
        "token": data["token"],
        "user_id": data["id"],
        "device_id": device_id,
        "name": data.get("name") or data.get("brand_name") or mobile,
    }


def auth_headers(session: dict[str, Any]) -> dict[str, str]:
    return {
        "headtoken": HEADTOKEN,
        "Authorization": f"Bearer {session['token']}",
        "deviceid": session["device_id"],
        "devicetype": "web",
        "userid": str(session["user_id"]),
        "usertype": "distributor",
        "isdebug": "1",
    }


def list_lite(api: str, session: dict[str, Any]) -> list[Company]:
    r = requests.get(
        api + "v2/business/institution/company/list-lite",
        headers=auth_headers(session),
        params={"type": "unlisted"},
        timeout=60,
    )
    r.raise_for_status()
    payload = r.json()
    if not payload.get("status"):
        raise RuntimeError(f"list-lite failed: {payload.get('message')}")
    out: list[Company] = []
    for row in payload.get("data") or []:
        brand = str(row.get("brand_name") or "")
        legal = str(row.get("company_name") or "")
        out.append(
            Company(
                id=int(row["id"]),
                brand=brand,
                legal=legal,
                brand_n=normalize(brand),
                legal_n=normalize(legal),
            )
        )
    return out


def canonical_key(normalized: str, prices: dict[str, float], aliases: dict[str, str]) -> str | None:
    if normalized in prices:
        return normalized
    mapped = aliases.get(normalized)
    if mapped and mapped in prices:
        return mapped
    return None


def match_companies(
    companies: list[Company],
    prices: dict[str, float],
    aliases: dict[str, str],
) -> tuple[dict[str, Company], list[str], list[str]]:
    matched: dict[str, Company] = {}
    ambiguous: list[str] = []
    by_norm: dict[str, list[Company]] = {}
    for c in companies:
        for key in {c.brand_n, c.legal_n}:
            if key:
                by_norm.setdefault(key, []).append(c)

    for sheet_key in prices:
        sheet_n = normalize(sheet_key)
        candidates: list[Company] = []
        for norm, comps in by_norm.items():
            resolved = canonical_key(norm, prices, aliases)
            if resolved == sheet_key or norm == sheet_n:
                candidates.extend(comps)
        if not candidates:
            for c in companies:
                for side in (c.brand_n, c.legal_n):
                    if not side:
                        continue
                    if sheet_n in side or (
                        len(sheet_n) >= 4 and side.startswith(sheet_n + " ")
                    ):
                        candidates.append(c)
                        break
        uniq = {c.id: c for c in candidates}
        candidates = list(uniq.values())
        if len(candidates) == 1:
            matched[sheet_key] = candidates[0]
        elif len(candidates) > 1:
            exact = [c for c in candidates if c.brand_n == sheet_n]
            if len(exact) == 1:
                matched[sheet_key] = exact[0]
            else:
                names = ", ".join(f"{c.id}:{c.brand}" for c in candidates)
                ambiguous.append(f"{sheet_key} → {names}")

    unmatched = [k for k in prices if k not in matched]
    return matched, unmatched, ambiguous


def min_qty(base: float, notional: float) -> int:
    return max(1, int(round(notional / base)))


def priced_sell(base: float, markup_percent: float) -> float:
    return round(base * (1.0 + markup_percent / 100.0), 2)


def build_rows(
    matched: dict[str, Company],
    prices: dict[str, float],
    markup_percent: float,
    notional: float,
    settlement_days: int,
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for sheet_key, company in sorted(matched.items()):
        base = prices[sheet_key]
        rows.append(
            {
                "company_id": company.id,
                "sell_price": priced_sell(base, markup_percent),
                "min_qty": min_qty(base, notional),
                "total_qty": None,
                "settlement_days": settlement_days,
                "_sheet": sheet_key,
                "_brand": company.brand,
                "_base": base,
            }
        )
    return rows


def post_bulk(api: str, session: dict[str, Any], rows: list[dict[str, Any]]) -> dict[str, Any]:
    clean = [
        {
            "company_id": r["company_id"],
            "sell_price": r["sell_price"],
            "min_qty": r["min_qty"],
            "total_qty": r["total_qty"],
            "settlement_days": r["settlement_days"],
        }
        for r in rows
    ]
    r = requests.post(
        api + "v2/business/institution/company/deals/bulk",
        headers={**auth_headers(session), "Content-Type": "application/json"},
        json={"sell": clean, "buy": []},
        timeout=120,
    )
    try:
        return r.json()
    except Exception:
        return {"status": 0, "message": f"HTTP {r.status_code}: {r.text[:500]}"}


def run_institute(
    *,
    api: str,
    institute: dict[str, Any],
    prices: dict[str, float],
    aliases: dict[str, str],
    notional: float,
    settlement_days: int,
    confirm: bool,
) -> int:
    label = institute.get("label") or institute.get("mobile")
    mobile = str(institute["mobile"]).strip()
    password = str(institute.get("password") or "").strip()
    markup = float(institute.get("markup_percent", 0))
    if not password or password == "REPLACE_ME":
        print(f"ERROR: set password for {label} ({mobile}) in institutes.local.json")
        return 2

    print(f"\n=== {label} ({mobile}) markup=+{markup:g}% ===")
    session = login(api, mobile, password)
    print(f"Logged in as {session['name']} (id={session['user_id']})")
    companies = list_lite(api, session)
    print(f"list-lite unlisted companies: {len(companies)}")

    matched, unmatched, ambiguous = match_companies(companies, prices, aliases)
    rows = build_rows(matched, prices, markup, notional, settlement_days)

    print(f"Matched: {len(matched)} / {len(prices)}")
    if ambiguous:
        print("AMBIGUOUS:")
        for line in ambiguous:
            print(f"  ? {line}")
    if unmatched:
        print("UNMATCHED (skipped):")
        for key in unmatched:
            print(f"  - {key} @ {prices[key]}")

    print("ROWS:")
    for r in rows:
        print(
            f"  {r['_sheet']:22} → id={r['company_id']:<6} {r['_brand'][:40]:40} "
            f"base={r['_base']:<10} sell={r['sell_price']:<10} "
            f"min_qty={r['min_qty']:<5} notional≈{r['sell_price'] * r['min_qty']:.0f}"
        )

    if not rows:
        print("No rows to upload.")
        return 1
    if ambiguous and confirm:
        print("Resolve ambiguous matches before --confirm.")
        return 1
    if not confirm:
        print("Dry-run only (pass --confirm to upload).")
        return 0

    result = post_bulk(api, session, rows)
    print("BULK RESPONSE:", json.dumps(result, indent=2)[:2000])
    if not result.get("status"):
        print(f"FAILED: {result.get('message')}")
        return 1
    print(f"OK: {result.get('message')}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--prices",
        type=Path,
        default=HERE / "prices.csv",
        help="CSV with script_name,selling_price (default: prices.csv)",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=HERE / "institutes.local.json",
        help="Institutes config (default: institutes.local.json)",
    )
    parser.add_argument(
        "--aliases",
        type=Path,
        default=HERE / "aliases.json",
        help="Optional name aliases JSON",
    )
    parser.add_argument(
        "--confirm",
        action="store_true",
        help="POST deals/bulk (default: dry-run)",
    )
    parser.add_argument(
        "--only",
        type=int,
        help="1-based institute index to run alone",
    )
    args = parser.parse_args()

    if not args.config.exists():
        sample = HERE / "institutes.sample.json"
        print(
            f"Missing {args.config.name}. Copy {sample.name} → {args.config.name} "
            "and set passwords.",
            file=sys.stderr,
        )
        return 2
    if not args.prices.exists():
        sample = HERE / "prices.sample.csv"
        print(
            f"Missing {args.prices.name}. Copy {sample.name} → {args.prices.name} "
            "and fill today's Selling Prices (skip CNC).",
            file=sys.stderr,
        )
        return 2

    config = load_json(args.config)
    prices = load_prices(args.prices)
    aliases = load_aliases(args.aliases)
    api = api_base(config)
    notional = float(config.get("notional", 35000))
    settlement_days = int(config.get("settlement_days", 1))
    institutes = config.get("institutes") or []
    if not institutes:
        print("No institutes in config.", file=sys.stderr)
        return 2

    print(f"Prices: {len(prices)} from {args.prices.name}")
    print(f"Notional≈{notional:g}  settlement=T+{settlement_days}  confirm={args.confirm}")

    rc = 0
    for i, institute in enumerate(institutes, start=1):
        if args.only is not None and args.only != i:
            continue
        code = run_institute(
            api=api,
            institute=institute,
            prices=prices,
            aliases=aliases,
            notional=notional,
            settlement_days=settlement_days,
            confirm=args.confirm,
        )
        if code != 0:
            rc = code
            if args.confirm:
                print("Stopping after failure.")
                break
    return rc


if __name__ == "__main__":
    sys.exit(main())
