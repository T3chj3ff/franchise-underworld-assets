#!/usr/bin/env python3
"""
FRANCHISE UNDERWORLD — PRE-POST IMAGE QA GATE
=============================================
Runs before every Instagram publish. Checks for:
  1. Hallucinated readable text / signs
  2. Anatomy failures (missing bodies, floating limbs)
  3. Image dimensions (Instagram minimum: 320x320px)
  4. File size (Instagram max: 8MB)
  5. Generates alt text for accessibility

Usage:
  python3 qa_image.py <image_path> [--caption "caption text"] [--auto-approve]

Returns:
  Exit 0 = PASS (safe to post)
  Exit 1 = FAIL (do not post)
"""

import sys
import os
import json
import struct
import zlib
from pathlib import Path
from datetime import datetime

# ── CONFIG ──────────────────────────────────────────────────────────────
QA_LOG = Path(__file__).parent.parent / "logs" / "qa_log.jsonl"
MIN_SIZE_PX = 320
MAX_FILE_BYTES = 8 * 1024 * 1024  # 8MB

# Hallucination risk keywords that should NOT appear in your prompts
# (used to flag if a high-risk prompt was used without safeguards)
HIGH_RISK_PROMPT_ELEMENTS = [
    "newspaper", "sign", "menu", "label", "book", "magazine",
    "billboard", "poster", "letter", "writing", "text on"
]

# ── CHECKLIST (manual visual gate) ──────────────────────────────────────
CHECKLIST = [
    ("BODY_COMPLETE",    "Does the character have a COMPLETE visible body? (no missing torso, floating limbs, or cut-off anatomy)"),
    ("NO_READABLE_TEXT", "Is the image FREE of readable text, signs, labels, or legible writing?"),
    ("NO_BRAND_LOGOS",   "Are there NO real-world brand logos or recognizable trademarks?"),
    ("STYLE_CONSISTENT", "Does the art style match the Fortiche/Arcane 1997-noir aesthetic?"),
    ("LORE_ACCURATE",    "Does the character/scene match established lore (correct costume, setting)?"),
    ("BACKGROUND_CLEAN", "Is the background free of hallucinated artifacts or distorted geometry?"),
]

# ── HELPERS ─────────────────────────────────────────────────────────────
def get_png_dimensions(filepath):
    """Read image dimensions — tries PNG header first, falls back to JPEG/generic."""
    try:
        with open(filepath, 'rb') as f:
            header = f.read(24)

        # PNG
        if header[:8] == b'\x89PNG\r\n\x1a\n':
            w = struct.unpack('>I', header[16:20])[0]
            h = struct.unpack('>I', header[20:24])[0]
            return w, h

        # JPEG — scan for SOF marker
        if header[:2] == b'\xff\xd8':
            with open(filepath, 'rb') as f:
                f.read(2)  # skip SOI
                while True:
                    marker = f.read(2)
                    if len(marker) < 2:
                        break
                    length = struct.unpack('>H', f.read(2))[0]
                    if marker[1] in (0xC0, 0xC1, 0xC2):  # SOF markers
                        f.read(1)  # precision
                        h = struct.unpack('>H', f.read(2))[0]
                        w = struct.unpack('>H', f.read(2))[0]
                        return w, h
                    f.read(length - 2)
            return None, None

        return None, None
    except Exception:
        return None, None

def log_result(image_path, result, checks, alt_text, caption):
    """Append QA result to jsonl log."""
    QA_LOG.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "image": str(image_path),
        "result": result,
        "checks": checks,
        "alt_text": alt_text,
        "caption_preview": (caption or "")[:80],
    }
    with open(QA_LOG, "a") as f:
        f.write(json.dumps(entry) + "\n")

def generate_alt_text(image_path, caption):
    """Prompt the user to write alt text if not derivable from caption."""
    print("\n📝 ALT TEXT REQUIRED")
    print("   Instagram alt text should describe the image for screen readers.")
    if caption:
        print(f"   Caption hint: {caption[:120]}")
    print("   Example: 'Illustrated portrait of Pastor Jonah Creed, an elderly Black man")
    print("   wearing a preacher collar and kitchen apron, standing in a dimly lit kitchen.'")
    alt = input("   Enter alt text (or press Enter to auto-generate from filename): ").strip()
    if not alt:
        name = Path(image_path).stem.replace("_", " ").title()
        alt = f"Illustrated character art for Franchise Underworld: {name}. Graphic novel concept art in a 1997 industrial noir style."
    return alt

# ── MAIN QA FLOW ────────────────────────────────────────────────────────
def run_qa(image_path, caption=None, auto_approve=False):
    path = Path(image_path)
    checks = {}
    failures = []

    print(f"\n{'='*60}")
    print(f"🔍 FRANCHISE UNDERWORLD — IMAGE QA GATE")
    print(f"{'='*60}")
    print(f"Image : {path.name}")
    print(f"{'='*60}\n")

    # ── CHECK 1: File exists ─────────────────────────────────────────
    if not path.exists():
        print(f"❌ FAIL: File not found: {path}")
        return 1

    # ── CHECK 2: File size ───────────────────────────────────────────
    size = path.stat().st_size
    size_mb = size / (1024 * 1024)
    if size > MAX_FILE_BYTES:
        print(f"❌ FAIL: File too large ({size_mb:.1f}MB, max 8MB)")
        failures.append("FILE_SIZE")
    else:
        print(f"✅ File size: {size_mb:.2f}MB")
    checks["FILE_SIZE"] = size <= MAX_FILE_BYTES

    # ── CHECK 3: Dimensions ──────────────────────────────────────────
    w, h = get_png_dimensions(str(path))
    if w and h:
        dim_ok = w >= MIN_SIZE_PX and h >= MIN_SIZE_PX
        if dim_ok:
            print(f"✅ Dimensions: {w}x{h}px")
        else:
            print(f"❌ FAIL: Dimensions too small ({w}x{h}px, min {MIN_SIZE_PX}px)")
            failures.append("DIMENSIONS")
        checks["DIMENSIONS"] = dim_ok
    else:
        print(f"⚠️  Could not read dimensions (non-PNG or corrupt)")
        checks["DIMENSIONS"] = None

    # ── CHECK 4: Caption risk scan ───────────────────────────────────
    if caption:
        risky = [kw for kw in HIGH_RISK_PROMPT_ELEMENTS if kw.lower() in caption.lower()]
        if risky:
            print(f"⚠️  Caption contains high-risk words: {risky}")
            print(f"   These suggest the image may contain readable text. Verify manually.")
        else:
            print(f"✅ Caption risk scan: clean")

    # ── CHECK 5: Visual checklist (manual) ──────────────────────────
    if not auto_approve:
        print(f"\n📋 VISUAL CHECKLIST — Open the image and answer each question.")
        print(f"   File: {path.absolute()}\n")
        os.system(f'open "{path.absolute()}"')  # macOS: open in Preview

        all_passed = True
        for key, question in CHECKLIST:
            while True:
                answer = input(f"   {'✓' if all_passed else '?'} {question}\n   [y/n]: ").strip().lower()
                if answer in ("y", "n"):
                    break
                print("   Please enter y or n.")
            passed = answer == "y"
            checks[key] = passed
            if not passed:
                failures.append(key)
                all_passed = False
                print(f"   ❌ FLAGGED: {key}\n")
            else:
                print(f"   ✅ PASSED\n")
    else:
        print("⚡ Auto-approve mode — skipping visual checklist (not recommended for character art)")
        for key, _ in CHECKLIST:
            checks[key] = True

    # ── ALT TEXT ────────────────────────────────────────────────────
    alt_text = generate_alt_text(path, caption) if not auto_approve else f"Franchise Underworld concept art: {path.stem}"
    print(f"\n📝 Alt text saved: \"{alt_text}\"")

    # ── RESULT ──────────────────────────────────────────────────────
    print(f"\n{'='*60}")
    if failures:
        result = "FAIL"
        print(f"❌ QA RESULT: FAIL")
        print(f"   Failed checks: {', '.join(failures)}")
        print(f"   DO NOT POST. Regenerate the image and re-run QA.")
    else:
        result = "PASS"
        print(f"✅ QA RESULT: PASS — Safe to publish.")

    print(f"{'='*60}\n")

    log_result(path, result, checks, alt_text, caption)
    return 0 if result == "PASS" else 1

# ── ENTRY ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 qa_image.py <image_path> [--caption 'text'] [--auto-approve]")
        sys.exit(1)

    image_path = sys.argv[1]
    caption = None
    auto_approve = "--auto-approve" in sys.argv

    if "--caption" in sys.argv:
        idx = sys.argv.index("--caption")
        if idx + 1 < len(sys.argv):
            caption = sys.argv[idx + 1]

    sys.exit(run_qa(image_path, caption, auto_approve))
