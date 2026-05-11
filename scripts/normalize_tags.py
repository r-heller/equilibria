#!/usr/bin/env python3
"""
Normalize categories[1:] and labels across all tutorial articles.

Convention: lowercase kebab-case. Spaces, slashes, ampersands, underscores
become hyphens; '&' becomes 'and'; runs of hyphens collapse; leading/trailing
hyphens trimmed.

Leaves categories[0] (topic slug, fixed in commit 0e6edba), keywords (SEO
phrases), and every other front-matter field untouched.

Idempotent. Run from repo root: python scripts/normalize_tags.py
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


def kebab(s: str) -> str:
    s = s.strip().strip('"').strip("'")
    s = s.replace("&", " and ").replace("/", "-").replace("_", "-")
    s = s.lower()
    s = re.sub(r"\s+", "-", s)
    s = re.sub(r"-+", "-", s)
    return s.strip("-")


# Match a block-style YAML list under "categories:"
CATS_RE = re.compile(
    r"(^categories:\s*\n)((?:^[ \t]+-[^\n]*\n)+)",
    re.MULTILINE,
)

# Match an inline-style YAML list: labels: ["a", "b", ...]
LABELS_RE = re.compile(r"^(labels:\s*)\[([^\]]*)\]\s*$", re.MULTILINE)


def transform_categories_block(match: re.Match[str]) -> str:
    header, body = match.group(1), match.group(2)
    lines = body.splitlines(keepends=True)
    out_lines: list[str] = []
    for i, raw in enumerate(lines):
        m = re.match(r"^([ \t]+-\s*)(.+?)\s*$", raw)
        if not m:
            out_lines.append(raw)
            continue
        prefix, value = m.group(1), m.group(2)
        # categories[0] already normalized in 0e6edba; leave alone
        new_value = value if i == 0 else kebab(value)
        nl = "\n" if raw.endswith("\n") else ""
        out_lines.append(f"{prefix}{new_value}{nl}")
    return header + "".join(out_lines)


def transform_labels_inline(match: re.Match[str]) -> str:
    prefix, body = match.group(1), match.group(2)
    items = [kebab(x) for x in body.split(",") if x.strip()]
    items_q = ", ".join(f'"{x}"' for x in items)
    return f"{prefix}[{items_q}]"


def find_frontmatter_bounds(text: str) -> tuple[int, int] | None:
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    if end == -1:
        return None
    return (0, end + 4)


def process(path: Path, write: bool) -> bool:
    text = path.read_text(encoding="utf-8")
    bounds = find_frontmatter_bounds(text)
    if not bounds:
        return False
    fm = text[: bounds[1]]
    rest = text[bounds[1] :]
    new_fm = CATS_RE.sub(transform_categories_block, fm)
    new_fm = LABELS_RE.sub(transform_labels_inline, new_fm)
    if new_fm == fm:
        return False
    if write:
        path.write_text(new_fm + rest, encoding="utf-8")
    return True


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="Report changes only, don't write")
    ap.add_argument(
        "paths",
        nargs="*",
        default=["tutorials", "shiny/tutorials"],
        help="Directories or files to scan",
    )
    args = ap.parse_args()

    targets: list[Path] = []
    for p in args.paths:
        path = Path(p)
        if path.is_dir():
            targets.extend(
                t for t in path.rglob("*.qmd") if "_template" not in t.parts
            )
        elif path.is_file():
            targets.append(path)

    changed = []
    for t in sorted(targets):
        if process(t, write=not args.check):
            changed.append(t)

    verb = "would change" if args.check else "changed"
    for c in changed:
        print(f"{verb}: {c}")
    print(f"\n{len(changed)} file(s) {verb}.")
    return 1 if (args.check and changed) else 0


if __name__ == "__main__":
    sys.exit(main())
