#!/usr/bin/env python3
"""
Rewrite each tutorials/<topic>/index.qmd body to use the .hero pattern
(matching index.qmd and shiny/index.qmd). YAML frontmatter is preserved
verbatim — only the post-frontmatter body is replaced.

Idempotent: re-running over an already-converted file is a no-op.
"""
from __future__ import annotations

import re
from pathlib import Path


HERO_RE = re.compile(r'^\s*<div class="hero">', re.MULTILINE)


def split_frontmatter(text: str) -> tuple[str, str] | None:
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    if end < 0:
        return None
    return text[: end + 4], text[end + 4 :]


def parse_yaml_field(fm: str, key: str) -> str:
    m = re.search(rf'^{re.escape(key)}:\s*"([^"]*)"', fm, re.MULTILINE)
    if m:
        return m.group(1)
    m = re.search(rf"^{re.escape(key)}:\s*(.+)$", fm, re.MULTILINE)
    if m:
        v = m.group(1).strip()
        if v.startswith('"') and v.endswith('"'):
            v = v[1:-1]
        return v
    return ""


def process(path: Path, slug: str) -> bool:
    raw = path.read_text(encoding="utf-8")
    split = split_frontmatter(raw)
    if not split:
        return False
    fm, body = split

    if HERO_RE.search(body):
        return False  # idempotent: already converted

    title = parse_yaml_field(fm, "title")
    desc = parse_yaml_field(fm, "description")
    if not title:
        return False

    hero = (
        '\n\n```{=html}\n'
        '<div class="hero">\n'
        f'  <div class="kicker"><span data-topic-count="{slug}"></span> TUTORIALS</div>\n'
        f'  <h1>{title}</h1>\n'
        f'  <p class="lead">{desc}</p>\n'
        '</div>\n'
        '```\n'
    )
    path.write_text(fm + hero, encoding="utf-8")
    return True


def main() -> None:
    changed = 0
    for d in sorted(Path("tutorials").iterdir()):
        if not d.is_dir() or d.name.startswith("_"):
            continue
        idx = d / "index.qmd"
        if not idx.exists():
            continue
        if process(idx, d.name):
            print(f"updated {idx}")
            changed += 1
    print(f"\n{changed} file(s) changed.")


if __name__ == "__main__":
    main()
