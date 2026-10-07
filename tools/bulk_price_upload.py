#!/usr/bin/env python3
"""One-shot Institution bulk sell-price upload from the daily rate sheet.

Default is dry-run. Pass --confirm to POST deals/bulk.
Credentials via env or CLI — do not commit passwords.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import uuid
from dataclasses import dataclass
from typing import Any

try:
    import requests
except ImportError:
    print("Install requests: pip install requests", file=sys.stderr)
    sys.exit(1)

BASE_URL = os.environ.get("PD_BASE_URL", "https://www.privatedeals.in/").rstrip(
    "/"
) + "/"
API = BASE_URL + "api/"
HEADTOKEN = os.environ.get(
    "PD_HEADTOKEN",
    "FBvBeiP253uCFK0VEUO6RWQhXlXp4PmeK1ZY1NbzhahertMCcgjoCMfpmWpe",
)
TARGET_NOTIONAL = 15000.0
SETTLEMENT_DAYS = 2

# Selling Price from 07-Oct-26 rate sheet. CNC rows omitted.
BASE_PRICES: dict[str, float] = {
    "APOLLO GREEN": 61.95,
    "BOOTES": 1023.75,
    "CARE INSURANCE": 153.3,
    "COCHIN INT AIRPORT": 467.25,
    "CSK": 255.15,
    "CREMICA FOOD": 183.75,
    "GOODLUCK DEFENCE": 464.1,
    "HDFC SECURITIES": 8452.5,
    "HINDUJA FINANCE": 244.65,
    "HVR SOLAR": 273.0,
    "INDOFIL": 1879.5,
    "INCRED": 158.55,
    "MSEI": 6.9825,
    "MOTILAL HOME FIN": 11.8125,
    "MOHAN MEAKIN": 2362.5,
    "NCDEX": 388.5,
    "MODERN BAZAAR": 54.6,
    "OYO": 24.045,
    "OYO ASSET": 8.4,
    "ORBIS FINANCE": 383.25,
    "PARAG PARIKH": 19320.0,
    "PHARMEASY": 6.72,
    "POLYMATECH": 47.25,
    "ZEPTO": 30.45,
}

# Optional aliases → canonical sheet key above.
ALIASES: dict[str, str] = {
    "APOLLO GREEN ENERGY": "APOLLO GREEN",
    "COCHIN INTERNATIONAL AIRPORT": "COCHIN INT AIRPORT",
    "COCHIN INTERNATIONAL": "COCHIN INT AIRPORT",
    "CHENNAI SUPER KINGS": "CSK",
    "CREMICA": "CREMICA FOOD",
    "CARE HEALTH": "CARE INSURANCE",
    "CARE HEALTH INSURANCE": "CARE INSURANCE",
    "GOODLUCK DEFENCE AND AEROSPACE": "GOODLUCK DEFENCE",
    "GOODLUCK": "GOODLUCK DEFENCE",
    "HINDUJA LEYLAND FINANCE": "HINDUJA FINANCE",
    "HINDUJA": "HINDUJA FINANCE",
    "HDFC": "HDFC SECURITIES",
    "MOTILAL OSWAL HOME FINANCE": "MOTILAL HOME FIN",
    "MOTILAL OSWAL": "MOTILAL HOME FIN",
    "METROPOLITAN STOCK EXCHANGE": "MSEI",
    "METROPOLITAN STOCK EXCHANGE OF INDIA": "MSEI",
    "MODERN BAZAR": "MODERN BAZAAR",
    "API HOLDINGS": "PHARMEASY",
    "PHARMEASY API": "PHARMEASY",
    "AXELIA SOLUTIONS": "PHARMEASY",
    "PPFAS": "PARAG PARIKH",
    "PARAG PARIKH FINANCIAL ADVISORY SERVICES": "PARAG PARIKH",
}

INSTITUTES = [
    {"label": "1-base", "markup": 0.0},
    {"label": "2-+0.5%", "markup": 0.005},
    {"label": "3-+1.5%", "markup": 0.015},
    {"label": "4-+1.0%", "markup": 0.01},
]


def normalize(name: str) -> str:
    s = name.upper().strip()
    s = re.sub(r"\([^)]*\)", " ", s)
    s = s.replace("&", " AND ")
    s = re.sub(r"[^A-Z0-9]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    # Drop common suffixes that hurt matching
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
    # BAZAAR / BAZAR
    s = re.sub(r"\bBAZAAR\b", "BAZAR", s)
    return s


def min_qty(base: float) -> int:
    return max(1, int(round(TARGET_NOTIONAL / base)))


def priced_sell(base: float, markup: float) -> float:
    return round(base * (1.0 + markup), 2)


@dataclass
class Company:
    id: int
    brand: str
    legal: str
    brand_n: str
    legal_n: str


def login(mobile: str, password: str) -> dict[str, Any]:
    device_id = f"bulk-upload-{uuid.uuid4().hex[:12]}"
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
    r = requests.post(API + "v1/business/login", headers=headers, json=body, timeout=60)
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


def list_lite(session: dict[str, Any]) -> list[Company]:
    r = requests.get(
        API + "v2/business/institution/company/list-lite",
        headers=auth_headers(session),
        params={"type": "unlisted"},
        timeout=60,
    )
    r.raise_for_status()
    payload = r.json()
    if not payload.get("status"):
        raise RuntimeError(f"list-lite failed: {payload.get('message')}")
    rows = payload.get("data") or []
    out: list[Company] = []
    for row in rows:
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


def resolve_sheet_key(normalized: str) -> str | None:
    if normalized in BASE_PRICES:
        return normalized
    if normalized in ALIASES:
        return ALIASES[normalized]
    for alias, key in ALIASES.items():
        if normalize(alias) == normalized:
            return key
    return None


def match_companies(
    companies: list[Company],
) -> tuple[dict[str, Company], list[str], list[str]]:
    """Return matched sheet_key→company, unmatched sheet keys, ambiguous notes."""
    matched: dict[str, Company] = {}
    ambiguous: list[str] = []

    # Index companies by normalized brand/legal
    by_norm: dict[str, list[Company]] = {}
    for c in companies:
        for key in {c.brand_n, c.legal_n}:
            if not key:
                continue
            by_norm.setdefault(key, []).append(c)

    for sheet_key in BASE_PRICES:
        sheet_n = normalize(sheet_key)
        candidates: list[Company] = []

        # Direct / alias equality
        for norm, comps in by_norm.items():
            resolved = resolve_sheet_key(norm)
            if resolved == sheet_key or norm == sheet_n:
                candidates.extend(comps)

        # Containment: sheet name inside company name only (not reverse —
        # reverse wrongly maps OYO → OYO ASSET via brand "OYO" ⊂ sheet).
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

        # Deduplicate
        uniq: dict[int, Company] = {c.id: c for c in candidates}
        candidates = list(uniq.values())

        if len(candidates) == 1:
            matched[sheet_key] = candidates[0]
        elif len(candidates) > 1:
            # Prefer brand exact
            exact = [c for c in candidates if c.brand_n == sheet_n]
            if len(exact) == 1:
                matched[sheet_key] = exact[0]
            else:
                names = ", ".join(f"{c.id}:{c.brand}" for c in candidates)
                ambiguous.append(f"{sheet_key} → {names}")

    unmatched = [k for k in BASE_PRICES if k not in matched]
    return matched, unmatched, ambiguous


def build_sell_rows(
    matched: dict[str, Company], markup: float
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for sheet_key, company in sorted(matched.items()):
        base = BASE_PRICES[sheet_key]
        rows.append(
            {
                "company_id": company.id,
                "sell_price": priced_sell(base, markup),
                "min_qty": min_qty(base),
                "total_qty": None,
                "settlement_days": SETTLEMENT_DAYS,
                "_sheet": sheet_key,
                "_brand": company.brand,
                "_base": base,
            }
        )
    return rows


def post_bulk(session: dict[str, Any], rows: list[dict[str, Any]]) -> dict[str, Any]:
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
        API + "v2/business/institution/company/deals/bulk",
        headers={**auth_headers(session), "Content-Type": "application/json"},
        json={"sell": clean, "buy": []},
        timeout=120,
    )
    try:
        return r.json()
    except Exception:
        return {"status": 0, "message": f"HTTP {r.status_code}: {r.text[:500]}"}


def run_institute(
    mobile: str,
    password: str,
    label: str,
    markup: float,
    confirm: bool,
) -> int:
    print(f"\n=== Institute {label} ({mobile}) markup={markup*100:.1f}% ===")
    session = login(mobile, password)
    print(f"Logged in as {session['name']} (id={session['user_id']})")
    companies = list_lite(session)
    print(f"list-lite unlisted companies: {len(companies)}")

    matched, unmatched, ambiguous = match_companies(companies)
    rows = build_sell_rows(matched, markup)

    print(f"Matched: {len(matched)} / {len(BASE_PRICES)}")
    if ambiguous:
        print("AMBIGUOUS:")
        for line in ambiguous:
            print(f"  ? {line}")
    if unmatched:
        print("UNMATCHED:")
        for key in unmatched:
            print(f"  - {key} @ {BASE_PRICES[key]}")

    print("ROWS:")
    for r in rows:
        print(
            f"  {r['_sheet']:22} → id={r['company_id']:<6} {r['_brand'][:40]:40} "
            f"base={r['_base']:<10} sell={r['sell_price']:<10} "
            f"min_qty={r['min_qty']:<5} notional≈{r['sell_price']*r['min_qty']:.0f}"
        )

    if not rows:
        print("No rows to upload.")
        return 1
    if ambiguous:
        print("Resolve ambiguous matches before --confirm.")
        if confirm:
            return 1

    if not confirm:
        print("Dry-run only (pass --confirm to upload).")
        return 0 if not unmatched and not ambiguous else 0

    result = post_bulk(session, rows)
    print("BULK RESPONSE:", json.dumps(result, indent=2)[:2000])
    ok = bool(result.get("status"))
    if not ok:
        print(f"FAILED: {result.get('message')}")
        return 1
    print(f"OK: {result.get('message')}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--confirm",
        action="store_true",
        help="Actually POST bulk deals (default: dry-run)",
    )
    parser.add_argument(
        "--password",
        default=os.environ.get("PD_INSTITUTION_PASSWORD", ""),
        help="Shared password (or PD_INSTITUTION_PASSWORD)",
    )
    parser.add_argument(
        "--m1",
        default=os.environ.get("PD_INST_1", "9316314236"),
        help="Institute 1 mobile (base)",
    )
    parser.add_argument(
        "--m2",
        default=os.environ.get("PD_INST_2", "7984718397"),
        help="Institute 2 mobile (+0.5%)",
    )
    parser.add_argument(
        "--m3",
        default=os.environ.get("PD_INST_3", "8980740163"),
        help="Institute 3 mobile (+1.5%)",
    )
    parser.add_argument(
        "--m4",
        default=os.environ.get("PD_INST_4", "8945612735"),
        help="Institute 4 mobile (+1.0%)",
    )
    parser.add_argument(
        "--only",
        type=int,
        choices=(1, 2, 3, 4),
        help="Run only one institute index",
    )
    args = parser.parse_args()

    if not args.password:
        print(
            "Password required: --password or PD_INSTITUTION_PASSWORD",
            file=sys.stderr,
        )
        return 2

    mobiles = [args.m1, args.m2, args.m3, args.m4]
    rc = 0
    for i, institute in enumerate(INSTITUTES, start=1):
        if args.only is not None and args.only != i:
            continue
        code = run_institute(
            mobile=mobiles[i - 1],
            password=args.password,
            label=institute["label"],
            markup=institute["markup"],
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
