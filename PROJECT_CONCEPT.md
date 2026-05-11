# PROJECT_CONCEPT.md — #equilibria

This file records the architectural decisions that diverge from the
CTTIR/tutorials template the site is otherwise modelled on, and the
front-matter contract every tutorial article must follow. Future audits
read this file to know which deviations are intentional vs accidental.

## Jurisdiction

Site is published from Germany and addresses (in part) German readers.
Therefore:

- `impressum.qmd` follows § 5 TMG and § 18 (2) MStV (responsible-person
  notice for journalistic content).
- `datenschutz.qmd` follows DSGVO Art. 13 / 14.
- VG Wort Zählmarken are embedded on individual articles via the
  `vgwort:` front-matter field + `_includes/vgwort.html`.

The visitor-facing site language is English (en-GB); the two legal
documents are intentionally in German.

## Deploy

- GitHub Pages serves the `gh-pages` branch via
  `quarto-dev/quarto-actions/publish@v2 target: gh-pages` in
  `.github/workflows/publish.yml`.
- Local render output goes to `_site/`, which is gitignored. The
  publish action handles the gh-pages branch push.
- `.nojekyll` exists at the source root and is copied into `_site/` via
  `_quarto.yml`'s `resources:` — belt-and-braces for any deploy path
  that bypasses the official action.
- The Quarto version is pinned to **1.9.37** in both `_quarto.yml`
  (`quarto-required:`) and every workflow's `quarto-dev/quarto-actions/setup@v2`.
- R is pinned to **4.5.2** in `publish.yml`.

## Build scripts language: R, not Python

CTTIR/tutorials' template puts build scripts under `scripts/*.py`. This
project keeps the same logic in `R/`:

- `R/build_artifacts.R` — emits `artifacts/{graph.json, tutorials.csv, cooccurrence.csv}`
- `R/build_decision_tree.R` — emits `artifacts/decision-tree.json`
- `R/check_frontmatter.R` — front-matter contract validator
- `R/check_charcount.R` — ≥ 2500 prose-char gate

`scripts/` holds Python one-offs only (not part of the render path):

- `scripts/normalize_tags.py` — idempotent kebab-case normaliser for
  `categories[1:]` and `labels` across all articles. Used during the
  2026-05-11 audit; kept for future re-runs.
- `scripts/replace_counts.py` — one-off that replaced fabricated
  count chips with live-count spans during the same audit.

Rationale: the rest of the corpus is R-first (every article sources
`R/_common.R`). Adding Python build scripts would create a second
runtime to pin and version. Documented divergence rather than retrofit.

## Artifacts ownership

`artifacts/{graph.json, tutorials.csv, cooccurrence.csv, decision-tree.json}`
are **tracked** and refreshed by `.github/workflows/artifacts-rebuild.yml`
on push to `main` that touches `tutorials/**`, `shiny/tutorials/**`,
`R/build_artifacts.R`, or `R/build_decision_tree.R`.

No pre-render hook is configured. PR renders use the last-committed
artifacts (slightly stale for the duration of the PR — acceptable for a
content site). This was an explicit choice over a pre-render hook so
that every render doesn't dirty the working tree.

## Search: Pagefind

The site uses **Pagefind** instead of Quarto's built-in Lunr search,
matching the CTTIR/tutorials approach. Built at deploy time via
`scripts/build_pagefind.sh` invoked from `publish.yml`.

## Topic taxonomy

`_data/topics.yml` is the single source of truth for the 32 topic areas
(slug, display name, blurb). Consumers:

- `js/overview.js` `TOPIC_COLORS` keying
- `R/check_frontmatter.R` slug validation
- (future) index.qmd topic-card grid via a Quarto include

No counts in `topics.yml` — counts come from `artifacts/tutorials.csv`
at render time via `_includes/live-counts.html`.

## Topic colour palette

32 distinct colours, composed of:

- Okabe-Ito 8 (colourblind-safe) for the eight core GT topics
  (`foundations` through `network-games`)
- d3.schemeTableau10 for the next 10 applied/theoretical topics
- d3.schemeSet3 for the next 12 methods/data/dev topics
- 2 custom hex codes for the final two slots

**Accessibility caveat:** only the first 8 are Okabe-Ito-grade
colourblind-safe. The remaining 24 are not. Documented here so future
Lighthouse a11y audits don't flag this as a regression to fix without
knowing the tradeoff.

If a future a11y review prefers strict CB-safety over 1:1 distinctness,
the alternative is to group the 32 topics into 8 thematic families and
reuse the Okabe-Ito 8 across families. That would require also revising
`overview.qmd` UX so the legend conveys family rather than individual
topic.

## Front-matter contract

Every tutorial article under `tutorials/<topic>/<slug>/index.qmd` must
have:

```yaml
title: <string>
description: <string>
author: <string>
date: <YYYY-MM-DD>
date-modified: <YYYY-MM-DD>
categories:
  - <topic-slug>          # MUST be one of the slugs in _data/topics.yml
  - <kebab-case-tag>      # all lowercase, hyphen-separated
  - ...
keywords: ["...", "..."]  # natural-language SEO phrases (not normalised)
labels: ["...", "..."]    # kebab-case lowercase
tier: 1 | 2 | 3
bibliography: ../../references.bib
vgwort: "TODO_VGWORT_<slug>" | "<actual-pixel-url>"
image: thumbnail.png
image-alt: <string>
citation:
  type: webpage
  url: https://r-heller.github.io/equilibria/tutorials/<topic>/<slug>/
license: "CC BY-SA 4.0"
draft: false
has_static_fig: <bool>
has_interactive_fig: <bool>
has_shiny_app: <bool>
```

Validated on every PR by `frontmatter-check.yml` →
`R/check_frontmatter.R`. The validator enforces:

- presence of `title`, `description`, `date` (ISO `YYYY-MM-DD`),
  `categories` (non-empty)
- `categories[0]` is a slug in `_data/topics.yml`
- `categories[1:]` and `labels` are lowercase kebab-case

Other front-matter fields are not yet validator-checked but are part of
the contract. `keywords` are deliberately left as natural-language
phrases (SEO content, not filter UI).

## VG Wort

`vgwort-gate.yml` hard-fails any PR that leaves `TODO_IMPRESSUM` or
`TODO_DATENSCHUTZ` markers (incl. `TODO_IMPRESSUM_<FIELD>` substrings)
in the legal documents. It also warns on remaining `TODO_VGWORT_*`
article pixels.

Pixel registration is batched (≈ every 50 articles) at
[tom.vgwort.de](https://tom.vgwort.de/); progress tracked in
`PLAN.md` § "Pending VG Wort pixel registrations".

Per-article enforcement of populated pixels (deny `TODO_VGWORT_*`
publish) is deferred until first article batch with active pixels.

## Char-count threshold

`char-count.yml` enforces ≥ 2500 prose chars per article. Above VG
Wort's 1800-char floor (≥ 2000 chars stated by user) by design —
quality headroom and resistant to small content shrink later.

## Counts policy

All visitor-facing tutorial counts are read at render time from
`artifacts/tutorials.csv` via `_includes/live-counts.html`. Failure
mode: hide the count chip (preferred over showing an empty or stale
number). No hard-coded counts in any visitor-facing file.

`README.md` and `about.qmd` use prose-only descriptions of scope
("comprehensive coverage across 32 topic areas") since neither runs
the live-count JS.

## Things that intentionally diverge from CTTIR/tutorials

| Item | CTTIR | equilibria | Reason |
|---|---|---|---|
| Build scripts | `scripts/*.py` | `R/*.R` (+ Python one-offs in `scripts/`) | R-first corpus |
| Artifact freshness | pre-render hook | post-merge workflow | Avoid dirty-tree-per-render |
| `_data/topics.yml` | yes | yes | (parity) |
| Pagefind search | yes | yes | (parity) |
| Modular `assets/js/overview/*` | yes | single `js/overview.js` | Defer split until UX iteration warrants it (S2) |
| Modular `assets/scss/overview/_overview.scss` | yes | top-level SCSS | Same as above |
| Legal jurisdiction | site-specific | DE (§ 5 TMG + DSGVO) | Author hosting from Germany |
| Sister-site link | varies | absent | Explicit removal (Phase 1 Q7) |

Update this file whenever a future audit decides to keep, retire, or
add a divergence.
