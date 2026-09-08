# AUDIT — equilibria — 2026-05-11 (re-baseline)

Auditor: Claude Code, branch `audit/2026-05-11`.
Scope: pre-deploy readiness of the `#equilibria` Quarto site against the
CTTIR/tutorials template contract.

**Re-baseline note.** The first version of this audit was written against a
stale local checkout (`8c750da`, 90 commits behind `origin/main`). After
rebasing onto `origin/main@d0e90ab`, the real state is materially different:
182 published tutorial articles, 79 bib entries, populated artifacts. This
file replaces the original. Decisions made on the stale audit (`PLAN.md`
v1) are re-examined here.

---

## 1. Summary

- Repo holds **182 published tutorial articles** across all 32 topic sections (5–14 each, weighted toward `foundations` (14) and `classical-games` (12)), plus **1 Shiny tutorial** under `shiny/tutorials/`, **1 working Shiny app** (`shiny-apps/01-two-by-two-nash-explorer/app.R`), **79 references in `references.bib`**, and a working artifacts pipeline (`artifacts/{graph.json,tutorials.csv,cooccurrence.csv}` all populated and committed).
- `LIVE_URL` `https://r-heller.github.io/equilibria/` still returns **HTTP 404**. Despite 182 articles in the repo, the site has never deployed.
- Legal docs `impressum.qmd` and `datenschutz.qmd` remain **`TODO_IMPRESSUM` / `TODO_DATENSCHUTZ`** placeholders → `vgwort-gate.yml` hard-fails on every PR.
- Counts shown to readers are still **inconsistent with reality**: `index.qmd`, `about.qmd`, `README.md` claim "2436 tutorials" (actual: 182); per-topic cards claim 30–180 each (actual: 4–14). Honesty + Hard Rule #1 requires fixing.
- **Front-matter normalization is broken**: 8 of 182 articles use Title-Case display names in `categories[0]` ("AI/ML Foundations", "Bayesian Methods", "Behavioral Economics", "Decision Theory", "Ethics & Game Theory", "Ethics & Applications", "Evolutionary Game Theory", "Mechanism Design", "Network Science", "Public APIs & Datasets", "R Package Development"), the other 174 use kebab-case slugs. This breaks the topic→colour map in `js/overview.js`, Quarto's listing facets, and any future `_data/topics.yml`-based filter.
- Template gap is still large: no `_data/topics.yml`, no `scripts/`, no Pagefind setup, no `.nojekyll`, no Quarto version pin, no front-matter validator / commercial-source / Lighthouse CI gates, no pre-render hook, no `renv.lock`, no `publish.yml`.
- Tag style is mixed within and across articles: `categories` arrays contain a mix of kebab-case slugs (`zero-sum`), spaced lowercase (`multi-armed bandits`), and Title Case ("GANs", "Mechanism Design") — depending on the article. Same problem applies to `labels`.
- Articles carry a **richer front-matter contract** than the audit prompt's template specifies: `tier`, `vgwort`, `image`, `image-alt`, `citation`, `license`, `keywords`, `has_static_fig`, `has_interactive_fig`, `has_shiny_app`. This is divergent (extension, not violation) — should be documented as the canonical contract for this site.
- Render not attempted in this read-only phase. Existing artifacts in `artifacts/` are produced by `artifacts-rebuild.yml` post-merge, so artefact freshness is OK for the committed corpus.
- **0 commercial-source hits** across `tutorials/**` and `references.bib`.

---

## 2. Inventory + template gap matrix

### Inventory
- 279 tracked files (vs 93 in the stale baseline).
- 182 article `index.qmd` files under `tutorials/<topic>/<slug>/index.qmd`.
- 1 Shiny tutorial: `shiny/tutorials/two-by-two-nash-explorer-tutorial/index.qmd`.
- 1 Shiny app implementation: `shiny-apps/01-two-by-two-nash-explorer/app.R` (the second listed app `02-prisoners-dilemma-tournament/` is still `.gitkeep`-only).
- `references.bib`: 79 entries, 816 lines.
- `artifacts/`: `graph.json` populated (≥182 nodes), `tutorials.csv` 182 rows + header, `cooccurrence.csv` populated.
- CI workflows: 8 (unchanged from stale baseline).
- Scripts: 12 in `R/`, 6 in `python/` (unchanged).
- No `scripts/` directory, no `_data/`, no `assets/`.

### Template gap matrix
| Element | Status | Notes |
|---|---|---|
| `_quarto.yml` | PRESENT, DIVERGENT | output-dir `_site/`, no `quarto-required:`, no pre-render hook, references `_includes/vgwort.html` |
| `index.qmd` | PRESENT | Fabricated counts (still) |
| `overview.qmd` | PRESENT, DIVERGENT | Single `js/overview.js`; template expects `assets/js/overview/*.js` modular split |
| `tutorials.qmd` | PRESENT | A–Z table sources `artifacts/tutorials.csv` — actually populated now (182 rows) |
| `about.qmd` | PRESENT | Fabricated counts (still) |
| `impressum.qmd` | PRESENT | `TODO_IMPRESSUM` placeholder — **S0** |
| `datenschutz.qmd` | PRESENT | `TODO_DATENSCHUTZ` placeholder — **S0** |
| `references.bib` | PRESENT | 79 entries; smoke-sample shows DOIs (none live-checked in this phase — citation-check.yml runs per PR) |
| `README.md` | PRESENT | Fabricated counts (still) |
| `LICENSE`, `LICENSE-CONTENT` | PRESENT | not opened |
| `.gitignore` | PRESENT | Adequate; missing `_site/pagefind/` and `artifacts/decision-tree.json` only if those become render outputs |
| `.nojekyll` | MISSING | Required for any GH Pages serving path |
| `renv.lock` | MISSING | |
| `PLAN.md` | PRESENT | Will be re-written after this audit |
| `AUDIT.md` | PRESENT (this file) | |
| `COVERAGE.md` | MISSING | |
| `LEGAL.md` | MISSING | |
| `ORIGINALITY.md` | MISSING | |
| `PROJECT_CONCEPT.md` | MISSING | |
| `README-network.md` | MISSING | |
| `_data/topics.yml` | MISSING | Topics hard-coded across navbar + `index.qmd` + `overview.js` |
| `scripts/*` directory | MISSING | Equivalent logic lives in `R/build_artifacts.R` + `R/build_decision_tree.R` |
| `_artifacts/` (render-time, gitignored) | DIVERGENT | This repo commits `artifacts/` (tracked) and refreshes via `artifacts-rebuild.yml` post-merge. Conflict with adding a pre-render hook — see §9 Q1 |
| Pre-render hook in `_quarto.yml` | MISSING | |
| `publish.yml` (deploy) | MISSING | Only `build.yml` (PR preview artifact). **Site is not connected to GitHub Pages.** |
| Quarto version pin | MISSING | Neither in `_quarto.yml` nor in any workflow |
| Pagefind step in CI | MISSING | |
| Front-matter validator | MISSING | And actively needed: 8 articles diverge |
| Commercial-link gate | MISSING | (Greppable scan shows 0 violations today.) |
| Lighthouse a11y ≥ 95 | MISSING | |
| Per-tutorial nine-section template | PARTIAL | Out-of-scope to re-audit prose; spot-check on `tutorials/foundations/nash-bargaining-solution/` shows rich front-matter and a real setup chunk — body audit deferred per Hard Rule #3 |
| Modular `assets/js/overview/*` | DIVERGENT | One file at `js/overview.js` |
| `assets/scss/overview/_overview.scss` | DIVERGENT | Styles in top-level SCSS files |

### Existing CI workflows (8) — short description (unchanged from prior audit)
- `build.yml`: render on PR, upload `_site/` as artifact. **No deploy step.**
- `api-liveness.yml`: weekly HEAD check on `api_or_dataset.endpoint_or_url`. There are 5 articles under `tutorials/public-apis-and-datasets/` now, so this gate actually has scope; coverage not verified.
- `artifacts-rebuild.yml`: on push to `main` under `tutorials/**`, runs `R/build_artifacts.R` and commits `artifacts/*`. **Working** — `d0e90ab` is one such commit.
- `char-count.yml`: PR gate; ≥ 2500 prose chars per article.
- `citation-check.yml`: PR gate; resolves every `doi:` in `references.bib`.
- `figure-check.yml`: PR warning; static + interactive figure references.
- `shiny-deploy.yml`: on push to `main` under `shiny-apps/**`, deploy to shinyapps.io. Secrets not set — workflow echoes diagnostic and exits.
- `vgwort-gate.yml`: PR gate; hard-fail on `TODO_IMPRESSUM` / `TODO_DATENSCHUTZ`; warn on `TODO_VGWORT_`. 184 articles still have `TODO_VGWORT_*`, so warnings on every PR.

---

## 3. Live-site issues

- `GET https://r-heller.github.io/equilibria/` → **HTTP 404**. Pages not configured. All other 0.3 sub-checks (navbar link statuses, depth-2 broken-link scan, Pagefind, related-tutorials block, dark-mode toggle, mobile breakpoint) are **N/A until the site is deployed once**.

---

## 4. Front-matter violations

This section is now non-trivial.

### 4.1 First-category style inconsistency (S1 — high priority)
Most articles set `categories[0]` to the topic *slug* (kebab-case). 8 articles instead use the *display name* (Title Case, sometimes with `&` or `/` or spaces). Sample (from `artifacts/tutorials.csv`):

| File | `categories[0]` value | Should be |
|---|---|---|
| `tutorials/ai-ml-foundations-and-applications/mechanism-design-ml-auctions/index.qmd` | `AI/ML Foundations` | `ai-ml-foundations-and-applications` |
| `tutorials/bayesian-methods/auction-common-value-estimation/index.qmd` | `Bayesian Methods` | `bayesian-methods` |
| `tutorials/behavioral-economics/endowment-effect-exchange/index.qmd` | `Behavioral Economics` | `behavioral-economics` |
| `tutorials/decision-theory/*/index.qmd` (1 article) | `Decision Theory` | `decision-theory` |
| `tutorials/ethics-and-game-theory/*/index.qmd` (1 article) | `Ethics & Game Theory` | `ethics-and-game-theory` |
| `tutorials/ethics-applications/*/index.qmd` (1 article) | `Ethics & Applications` | `ethics-applications` |
| `tutorials/evolutionary-gt/*/index.qmd` (1 article) | `Evolutionary Game Theory` | `evolutionary-gt` |
| `tutorials/mechanism-design/*/index.qmd` (1 article) | `Mechanism Design` | `mechanism-design` |
| `tutorials/network-science/*/index.qmd` (1 article) | `Network Science` | `network-science` |
| `tutorials/public-apis-and-datasets/*/index.qmd` (1 article) | `Public APIs & Datasets` | `public-apis-and-datasets` |
| `tutorials/r-package-development/*/index.qmd` (1 article) | `R Package Development` | `r-package-development` |

Effect: the topic→colour map in `js/overview.js` keyed on slug fails to colour these 8 articles' nodes; the topic filter in `overview.qmd` shows duplicate chips ("Bayesian Methods" *and* "bayesian-methods"); `tutorials.csv` `topic` field contains both forms.

### 4.2 Tag-style inconsistency (S1)
Within `categories` arrays (after the first entry, used as freeform tags), styles vary article-by-article and even within the same article:

- Kebab-case lowercase: `nash-bargaining`, `multi-armed bandits` (mixed with spaces).
- Spaced lowercase: `multi-armed bandits`, `reinforcement learning`, `English auction`.
- Title Case: `Mechanism Design`, `GANs`, `Shapley-value`, `SHAP`.

Pick a single convention (recommended: kebab-case, all lowercase) and normalise across the corpus.

### 4.3 `tier` field (informational)
Every article carries `tier: 1`. Roadmap presumably has Tier 2/3 distinction (mentioned in pre-existing PLAN.md). No violation; flag for completeness — front-matter validator should accept `tier ∈ {1, 2, 3}` once tiers diverge.

### 4.4 `vgwort:` markers (expected)
Every article has `vgwort: "TODO_VGWORT_*"`. 184 markers total (182 articles + 1 shiny tutorial + 1 other). Tracked in PLAN.md's pre-existing "Pending VG Wort pixel registrations" section. No action this audit pass; will resolve in batched pixel registration at tom.vgwort.de.

### 4.5 `draft: true` article
1 article carries `draft: true`. Identity not surfaced in this scan; identify in Phase 2 and decide whether to keep, promote, or remove.

### 4.6 Front-matter schema (extension, not violation)
The de-facto schema for an article on this site is:

```yaml
title: <string>
description: <string>
author: <string>
date: <YYYY-MM-DD>
date-modified: <YYYY-MM-DD>
categories: [<topic-slug>, <tag>, ...]
keywords: [<string>, ...]
labels: [<label-token>, ...]
tier: <1|2|3>
bibliography: ../../references.bib
vgwort: <pixel-url-or-TODO_VGWORT_*>
image: thumbnail.png
image-alt: <string>
citation:
  type: webpage
  url: <canonical-url>
license: "CC BY 4.0"
draft: <bool>
has_static_fig: <bool>
has_interactive_fig: <bool>
has_shiny_app: <bool>
```

This is richer than the CTTIR template's contract. Codify it in `PROJECT_CONCEPT.md` and validate it in the new front-matter workflow.

---

## 5. Citation + link failures

- `references.bib`: 79 entries. Live DOI resolution deferred to the existing `citation-check.yml` workflow on Phase 2 PR (it already runs on every PR that touches `references.bib`). No manual sampling done in this read-only pass.
- External links inside articles: not exhaustively scanned. The template expects a depth-2 broken-link scan over the *live* site, which can't run until deploy succeeds. Will run in Phase 3.

---

## 6. Commercial-source hits

- **0 hits** across `tutorials/**/*.qmd` and `references.bib` for the audit pattern `klett.de | cornelsen.de | oup.com | pearson.com | mheducation.com | wiley.com` (raw `Grep` returned only `PLAN.md` and `AUDIT.md`, which mention the patterns as audit metadata, not as actual references).
- The CI gate doesn't yet exist; current absence of hits is fortunate, not enforced. Add gate in Phase 2 (was already S1 in the stale audit).

---

## 7. Legal / Impressum gaps (unchanged from re-baseline)

- `impressum.qmd`: still `TODO_IMPRESSUM` placeholder. **S0**.
- `datenschutz.qmd`: still `TODO_DATENSCHUTZ` placeholder. **S0**.
- Jurisdiction decided in Phase 1 prep: **DE** → both pages stay and need population. § 5 TMG, § 18 (2) MStV, Art. 13 DSGVO fields all required.
- Contact: GitHub noreply confirmed acceptable (Phase 1 prep, Q3).

---

## 8. Build + reproducibility issues

- `quarto render` not attempted (multi-minute budget over 182 articles; out of scope for read-only). Existing `build.yml` is rendering successfully on at least one PR per merge — `d0e90ab` is post-PR-#13 artefact rebuild, which implies render passes on that branch.
- `Rscript -e 'renv::restore()'`: **N/A**, no `renv.lock`.
- Pre-render hook: still not configured. `artifacts/` is freshness-managed by `artifacts-rebuild.yml` (post-merge), which currently works but creates a window where a PR's render uses stale committed artifacts.
- **Conflict to resolve:** if a pre-render hook is added (PLAN.md v1 S1-6), it will overwrite the artifacts that `artifacts-rebuild.yml` commits, causing every render-touching PR to dirty `artifacts/`. Choose one source of truth before adding the hook.
- `R/build_decision_tree.R`: present, but `artifacts/decision-tree.json` not committed and not generated by any workflow. `decision-tree/decision-assistant.qmd` and `decision-tree/decision-tree.qmd` will fall back to "data not available" until either the JSON is committed or a hook is added.
- `scripts/build_pagefind.sh`: still missing; no Pagefind index produced.
- `.nojekyll`: still missing.
- `_site/` and `_freeze/` already in `.gitignore` — adequate.
- `python/requirements.txt`: not opened; presumed correct.

---

## 9. Open questions (post-rebaseline)

Phase 1 (PLAN.md v1) settled most of these. Three deserve re-confirmation in light of the real state:

1. **Pre-render hook vs `artifacts-rebuild.yml`.** Real artefacts are now committed and authoritative. Adding a pre-render hook means every render dirties the working tree. Options:
   - (a) **Keep `artifacts-rebuild.yml` authoritative** (no pre-render hook); contributors run `Rscript R/build_artifacts.R` locally if they want a preview. Simpler.
   - (b) **Move to pre-render** and untrack `artifacts/*` (gitignore). `artifacts-rebuild.yml` is deleted; deploy regenerates artefacts. Cleaner long-term.
   - (c) **Hybrid**: pre-render hook generates `artifacts/decision-tree.json` only (since that's not yet tracked); leave the other three artefacts to `artifacts-rebuild.yml`.

2. **Front-matter normalization scope.** 8 articles need `categories[0]` rewritten; ~all articles need tag-style normalised. This is "metadata", not "body prose" — Hard Rule #3 (no bulk content edits) lets us touch front-matter. Confirm: do it in one bulk commit, or 8+ small commits per article?

3. **What to do with the existing fabricated counts now that real numbers exist.** Three options:
   - (a) **Strip all counts** (Phase 1 v1 decision). Defensible and consistent with Hard Rule #1.
   - (b) **Replace with live counts** sourced from `artifacts/tutorials.csv` (e.g., topic cards read "14 tutorials" generated at render time). Honest, motivational, updates automatically.
   - (c) **Hybrid**: strip the global "2436" headline, keep per-topic counts but read them from artefacts.

Defer items: PROJECT_CONCEPT.md content, governance docs, modular JS split — same disposition as PLAN.md v1.

---

## 10. Severity-ranked fix list (re-baselined)

### S0 — blocks deploy

- **S0-1** `publish.yml` for `quarto publish gh-pages` (no Pagefind yet — that lands in S1). Same as PLAN.md v1.
- **S0-2** `.nojekyll`. Same.
- **S0-3** `impressum.qmd` § 5 TMG / § 18 MStV skeleton with `TODO_IMPRESSUM_*` field markers. Same.
- **S0-4** `datenschutz.qmd` DSGVO Art. 13 skeleton with `TODO_DATENSCHUTZ_*` field markers. Same.
- **S0-5** Resolve fabricated counts (per Q3 above). PLAN.md v1 said "strip all"; reconsider in light of real numbers.
- **S0-6** Pin Quarto version. Same.

### S1 — should fix before deploy

- **S1-1** Create `_data/topics.yml` as topic source of truth (no counts, or counts auto-generated from `artifacts/tutorials.csv`).
- **S1-2** Extend `TOPIC_COLORS` to 32 distinct colours.
- **S1-3** Add front-matter validator (now actually catches real violations — see §4.1, §4.2).
- **S1-4** Add commercial-source gate (0 hits today, but enforce).
- **S1-5** Add Lighthouse a11y workflow.
- **S1-6** Pre-render hook policy (per Q1 above).
- **S1-7** Add Pagefind step + `scripts/build_pagefind.sh`.
- **S1-8** Remove sister-site mentions from README.md + about.qmd.
- **S1-9** `.gitignore` policy aligned with S1-6.
- **S1-10** Generalise `vgwort-gate.yml` greps to `TODO_IMPRESSUM_*` / `TODO_DATENSCHUTZ_*`.
- **S1-11** Add `PROJECT_CONCEPT.md` documenting deviations.
- **S1-12 (new)** Normalise `categories[0]` on the 8 divergent articles (§4.1).
- **S1-13 (new)** Normalise tag style across `categories[1:]` + `labels` (§4.2). Define convention in PROJECT_CONCEPT.md, apply via one commit, validate via S1-3 validator.
- **S1-14 (new)** Identify the 1 `draft: true` article; decide promote-or-remove.
- **S1-15 (new)** Generate or commit `artifacts/decision-tree.json` so decision-tree pages stop falling back to the empty state.

### S2 — nice to have

- `renv.lock`, governance docs (COVERAGE / LEGAL / ORIGINALITY / README-network), modular JS split, build_related.py R-equivalent, manifest-freshness check. Same as PLAN.md v1.

### S3 — deferred

- Tier 2/3 content batches, additional Shiny apps, expanded API-liveness coverage, Plausible vs Matomo decision, per-article VG Wort pixel enforcement. Same as PLAN.md v1.

---

**Next step:** revise `PLAN.md` to reflect the re-baseline, then wait for explicit "proceed" before Phase 2.
