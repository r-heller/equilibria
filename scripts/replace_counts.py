#!/usr/bin/env python3
"""
One-off: replace hard-coded tutorial-count labels with span elements
that live-counts.html populates from artifacts/tutorials.csv.

Idempotent — re-running after the first pass changes nothing.

Run from repo root: python scripts/replace_counts.py
"""
from __future__ import annotations

import re
from pathlib import Path

# Block-level pattern for `::: {.topic-card-label}\nN TUTORIALS\n:::`
# capturing the count digits.
BLOCK = re.compile(
    r"::: \{\.topic-card-label\}\s*\n(\d+)\s+TUTORIALS\s*\n:::",
    re.MULTILINE,
)


def section_index_files() -> list[tuple[Path, str]]:
    out = []
    for d in sorted(Path("tutorials").iterdir()):
        if not d.is_dir() or d.name.startswith("_"):
            continue
        idx = d / "index.qmd"
        if idx.exists():
            out.append((idx, d.name))
    return out


def fix_section_index(path: Path, slug: str) -> bool:
    text = path.read_text(encoding="utf-8")
    new = BLOCK.sub(
        f'::: {{.topic-card-label}}\n<span data-topic-count="{slug}"></span> TUTORIALS\n:::',
        text,
    )
    if new == text:
        return False
    path.write_text(new, encoding="utf-8")
    return True


def fix_root_index() -> bool:
    path = Path("index.qmd")
    text = path.read_text(encoding="utf-8")
    orig = text

    # Replace each topic-card's "N TUTORIALS" with a slug-aware span.
    # We use a stateful walk: for each topic-card block, find its preceding
    # `### [...](tutorials/<slug>/index.qmd)` to get the slug.
    card_pattern = re.compile(
        r"(### \[[^\]]+\]\(tutorials/([^/)]+)/index\.qmd\)[\s\S]*?)"
        r"::: \{\.topic-card-label\}\s*\n(\d+)\s+TUTORIALS\s*\n:::",
    )

    def card_repl(m: re.Match[str]) -> str:
        prefix, slug = m.group(1), m.group(2)
        return (
            f"{prefix}::: {{.topic-card-label}}\n"
            f'<span data-topic-count="{slug}"></span> TUTORIALS\n'
            f":::"
        )

    text = card_pattern.sub(card_repl, text)

    # Strip the bold "2436 PAGES · 32 TOPIC AREAS" lead, replace with live span
    text = text.replace(
        "**2436 PAGES · 32 TOPIC AREAS**",
        '**<span id="live-total-count"></span> TUTORIALS · 32 TOPIC AREAS**',
    )

    # Shiny Apps card: count "80 APPS" -> remove count, keep an "INTERACTIVE" label.
    text = re.sub(
        r"(### \[Shiny Apps\][\s\S]*?)::: \{\.topic-card-label\}\s*\n80 APPS\s*\n:::",
        r"\1::: {.topic-card-label}\nINTERACTIVE\n:::",
        text,
    )

    if text == orig:
        return False
    path.write_text(text, encoding="utf-8")
    return True


def fix_shiny_index() -> bool:
    path = Path("shiny/index.qmd")
    text = path.read_text(encoding="utf-8")
    orig = text
    text = text.replace(
        "**80 INTERACTIVE APPS · 8 DOMAINS**",
        "**INTERACTIVE APPS · MULTIPLE DOMAINS**",
    )
    # Strip the stale paragraph that promises a 80-app roadmap
    text = text.replace(
        "*More apps will be added as tutorials are published. See the [full app catalog](../PLAN.md) for the complete roadmap of 80 applications.*",
        "*More apps will be added as tutorials are published.*",
    )
    if text == orig:
        return False
    path.write_text(text, encoding="utf-8")
    return True


def fix_about() -> bool:
    path = Path("about.qmd")
    text = path.read_text(encoding="utf-8")
    orig = text
    text = text.replace(
        "- **2436 tutorial articles** across 32 topic areas\n- **80 interactive Shiny applications**\n",
        "- Comprehensive coverage across 32 topic areas\n- Interactive Shiny applications paired with selected tutorials\n",
    )
    if text == orig:
        return False
    path.write_text(text, encoding="utf-8")
    return True


def fix_readme() -> bool:
    path = Path("README.md")
    text = path.read_text(encoding="utf-8")
    orig = text
    text = text.replace(
        "- **2436 tutorial articles** across 32 topic areas\n- **80 interactive Shiny applications**\n",
        "- Comprehensive coverage across 32 topic areas\n- Interactive Shiny applications paired with selected tutorials\n",
    )
    if text == orig:
        return False
    path.write_text(text, encoding="utf-8")
    return True


def main() -> None:
    changed = 0
    if fix_root_index():
        print("updated index.qmd")
        changed += 1
    if fix_shiny_index():
        print("updated shiny/index.qmd")
        changed += 1
    if fix_about():
        print("updated about.qmd")
        changed += 1
    if fix_readme():
        print("updated README.md")
        changed += 1
    for path, slug in section_index_files():
        if fix_section_index(path, slug):
            print(f"updated {path}")
            changed += 1
    print(f"\n{changed} file(s) changed.")


if __name__ == "__main__":
    main()
