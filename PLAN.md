# PLAN.md — #equilibria audit/2026-05-11

Phase 1 fix plan, derived from `AUDIT.md` + user decisions on the 10 open
questions. One bullet = one commit, in the listed order. Phase 2 starts
only on explicit "proceed" from the user.

## Decision log (Phase 0 → Phase 1)

| # | Question | Decision |
|---|---|---|
| 1 | Deploy target | gh-pages branch via `quarto publish gh-pages` |
| 2 | Jurisdiction | DE — keep Impressum, Datenschutz, VG Wort gate |
| 3 | Contact email | Keep `58561665+r-heller@users.noreply.github.com` |
| 4 | Unverified counts | Strip everywhere — no "planned" hedging |
| 5 | Build scripts language | Stay in R; document divergence in `PROJECT_CONCEPT.md` |
| 6 | Search backend | Add Pagefind + `scripts/build_pagefind.sh` |
| 7 | Sister-site link | Remove from README.md + about.qmd; not in navbar/footer |
| 8 | VG Wort gate | Keep current scope; defer per-article pixel enforcement |
| 9 | `decision-tree.json` | Pre-render hook runs `R/build_decision_tree.R` |
| 10 | Topic-colour palette | Extend Okabe-Ito 8 with d3.schemeTableau10 + Set3 to 32 distinct entries |
| 10b | Char-count threshold | Keep 2500 (already exceeds VG Wort 1800/2000) |

---

## Phase 1 commits

### S0 — deploy blockers

#### S0-1 — Add `publish.yml` + Pages deploy via gh-pages
- **Files:** new `.github/workflows/publish.yml`
- **Change:** workflow that on push to `main` runs `quarto render` (with R + Python deps), generates Pagefind index, then deploys `_site/` to `gh-pages` via `peaceiris/actions-gh-pages@v4` (or `quarto publish gh-pages` with token). Includes write-permissions block.
- **Acceptance:** workflow file exists, syntactically valid YAML, references the same Quarto version as `_quarto.yml`. (Actual successful deploy = Phase 3.)
- **Rollback:** delete the file.

#### S0-2 — Add `.nojekyll` for gh-pages output
- **Files:** new `.nojekyll` (empty file) at repo root, copied into `_site/` by Quarto's `resources:` block in `_quarto.yml`.
- **Change:** create empty `.nojekyll`; add it to `_quarto.yml` `project.resources:` so it lands in `_site/`.
- **Acceptance:** `.nojekyll` is staged; after a render, `_site/.nojekyll` exists (verified manually in Phase 2).
- **Rollback:** delete file + revert `_quarto.yml`.

#### S0-3 — Populate `impressum.qmd` skeleton with structured TODOs
- **Files:** `impressum.qmd`
- **Change:** replace `TODO_IMPRESSUM` placeholder with a § 5 TMG-shaped skeleton: legal name, postal address, contact, responsible person for journalistic content (§ 18 (2) MStV), VG Wort, dispute resolution disclaimer. Each personal field marked `TODO_IMPRESSUM_<FIELD>:` so user can fill in without re-drafting structure. `vgwort-gate.yml` will still hard-fail until every `TODO_IMPRESSUM_*` is resolved — update the gate to match.
- **Acceptance:** rendered page has labelled headings for every § 5 TMG/§ 18 MStV requirement; remaining content is `TODO_IMPRESSUM_*:` markers.
- **Rollback:** restore previous one-line placeholder.

#### S0-4 — Populate `datenschutz.qmd` skeleton (GDPR/DSGVO baseline)
- **Files:** `datenschutz.qmd`
- **Change:** replace `TODO_DATENSCHUTZ` with a DSGVO-shaped skeleton: Verantwortlicher, gehostete Daten (GitHub Pages = US transfer; cite GitHub's SCC posture), Server-Logs, VG Wort Zählmarken (1×1 pixel, no personal data, opt-out info), no analytics presently, contact for rights requests, supervisory authority. Personal/legal fields marked `TODO_DATENSCHUTZ_<FIELD>:`. Update `vgwort-gate.yml` accordingly.
- **Acceptance:** rendered page covers Art. 13 DSGVO disclosures; remaining content is `TODO_DATENSCHUTZ_*:` markers.
- **Rollback:** restore previous one-line placeholder.

#### S0-5 — Strip all unverified counts site-wide
- **Files:** `index.qmd`, `about.qmd`, `README.md`, `shiny/index.qmd`, every `tutorials/*/index.qmd` (32 files).
- **Change:**
  - Remove `**2436 PAGES · 32 TOPIC AREAS**` lead block from `index.qmd`.
  - Remove every `::: {.topic-card-label} N TUTORIALS :::` block (32 instances in `index.qmd` topic cards + 32 in section index pages).
  - Remove `**80 INTERACTIVE APPS · 8 DOMAINS**` and `::: {.topic-card-label} 80 APPS :::` and per-app `TIER 1 · GT CORE` labels (these last are status tags, not counts — keep `TIER 1` etc. only if they carry real meaning; remove if speculative).
  - Update `README.md`: drop the "2436 tutorial articles / 80 interactive Shiny applications" bullets.
  - Update `about.qmd` "Scope" section accordingly.
  - Replace removed lead blocks with a shorter, count-free tagline.
- **Acceptance:** `git grep -E "(2436|150 TUTORIALS|120 TUTORIALS|80 APPS|80 INTERACTIVE)"` returns nothing in tracked content; render shows no numeric claims.
- **Rollback:** restore from `git show HEAD~1`.

#### S0-6 — Pin Quarto version
- **Files:** `_quarto.yml`, every workflow that uses `quarto-dev/quarto-actions/setup@v2`.
- **Change:** add `quarto-required: ">=1.5.0"` to `_quarto.yml` `project:` block (or as a top-level key); add `with: { version: 1.5.57 }` (or the current stable at time of fix — to be verified against `quarto --version` locally before commit) to every workflow's setup step. `build.yml` and the new `publish.yml` both updated.
- **Acceptance:** `_quarto.yml` and all workflows reference the same pinned version.
- **Rollback:** revert `_quarto.yml` + workflow files.

---

### S1 — pre-deploy quality

#### S1-1 — Create `_data/topics.yml` as topic source of truth
- **Files:** new `_data/topics.yml`; consume in `index.qmd` (via Quarto include or a render-time R snippet that emits topic cards) and document in `PROJECT_CONCEPT.md`.
- **Change:** define one row per topic with `slug`, `display`, `blurb`. **No count fields** (per S0-5). Order matches `_quarto.yml` navbar.
- **Acceptance:** `_data/topics.yml` exists, has 32 entries; `index.qmd` topic cards are sourced from it (or — if a render-time loop is too invasive for one commit — at minimum the file exists and is referenced by `js/overview.js` topic-colour map and validated by a CI gate).
- **Rollback:** delete `_data/topics.yml`.

#### S1-2 — Extend `TOPIC_COLORS` to 32 distinct colours
- **Files:** `js/overview.js`.
- **Change:** replace the 8-colour Okabe-Ito reuse map with a 32-colour map composed of: 8 × Okabe-Ito + 10 × d3.schemeTableau10 + remaining slots from d3.schemeSet3 (filtering duplicates and near-duplicates against Okabe-Ito). Slugs must align with `_data/topics.yml`. Add a comment block citing colour sources + accessibility caveats (Tableau10 + Set3 are not Okabe-Ito-grade colourblind-safe; document this).
- **Acceptance:** every topic slug has a unique hex; `git grep -A1 TOPIC_COLORS js/overview.js` shows 32 distinct values.
- **Rollback:** restore previous map.

#### S1-3 — Add front-matter validator workflow
- **Files:** new `.github/workflows/frontmatter-check.yml`, new `R/check_frontmatter.R`.
- **Change:** validator script reads every `tutorials/*/<slug>/index.qmd`, asserts presence + shape of `title`, `date` (ISO YYYY-MM-DD), `description`, `categories` (≥1 entry; `categories[0]` ∈ `_data/topics.yml` display set; remaining entries kebab-case), optional `labels` from `{beginner,intermediate,advanced,case-study,reference,methods,theory}`. Hard-fail on any violation. Trivially passes today (0 articles).
- **Acceptance:** workflow runs on PR; passes on the current empty state; fails when a deliberately broken article is staged (smoke-tested in Phase 2).
- **Rollback:** delete the workflow + script.

#### S1-4 — Add commercial-source CI gate
- **Files:** new `.github/workflows/commercial-link-check.yml`.
- **Change:** grep `tutorials/**/*.qmd` + `references.bib` for `klett.de|cornelsen.de|oup\.com(?!/research/article/)|cambridge\.org(?!/core/journals/)|pearson\.com|mheducation\.com|wiley\.com/(?!doi/)`. Hard-fail on hits. Allowlist commented at top.
- **Acceptance:** workflow runs on PR; passes today (no hits); fails on a synthetic violation in smoke test.
- **Rollback:** delete the workflow.

#### S1-5 — Add Lighthouse a11y workflow
- **Files:** new `.github/workflows/lighthouse.yml`.
- **Change:** on PR (after `build.yml` produces `_site/`), serve `_site/` via `npx http-server` and run `treosh/lighthouse-ci-action@v12` against `overview.html` + one random tutorial. Soft-fail (warning) on score < 95. Since no tutorials exist yet, scope to `overview.html` + `index.html` only.
- **Acceptance:** workflow runs on PR; produces Lighthouse summary in PR comment.
- **Rollback:** delete the workflow.

#### S1-6 — Pre-render hook for build_artifacts + build_decision_tree
- **Files:** `_quarto.yml` (add `project.pre-render:`).
- **Change:** add `pre-render: - Rscript R/build_artifacts.R - Rscript R/build_decision_tree.R`. This guarantees `artifacts/{graph.json,tutorials.csv,cooccurrence.csv,decision-tree.json}` are fresh every render. Means `R/build_decision_tree.R` must produce `artifacts/decision-tree.json` — verify the script does this (audit deferred until Phase 2 implementation).
- **Acceptance:** `quarto render` no longer requires a separate Rscript invocation to populate `artifacts/`.
- **Rollback:** remove the `pre-render:` block.

#### S1-7 — Add Pagefind step + `scripts/build_pagefind.sh`
- **Files:** new `scripts/build_pagefind.sh`; update `publish.yml` (from S0-1) to invoke it after `quarto render`; add `pagefind` query button to `_quarto.yml` navbar or a `_includes/pagefind-init.html`.
- **Change:** `scripts/build_pagefind.sh` runs `npx pagefind --site _site` to produce `_site/pagefind/`. The Pagefind UI snippet is loaded in `_includes/before-body.html` (or a new `_includes/pagefind.html`) and replaces (or augments) the Quarto navbar search. Document choice in `PROJECT_CONCEPT.md`.
- **Acceptance:** after a render + Pagefind run, `_site/pagefind/pagefind.js` exists; on the live site the search input returns results.
- **Rollback:** delete `scripts/build_pagefind.sh`; revert `publish.yml`, `_quarto.yml`, `_includes/`.

#### S1-8 — Remove sister-site mentions
- **Files:** `README.md`, `about.qmd`.
- **Change:** delete the `## Sister site` section in both files. Leave no replacement copy.
- **Acceptance:** `git grep -i "sister site\|cttir"` returns no hits in tracked Markdown/QMD content.
- **Rollback:** restore from `git show HEAD~1`.

#### S1-9 — Update `.gitignore` for `_site/`, `_freeze/`, render-time artifacts
- **Files:** `.gitignore`.
- **Change:** confirm `_site/` and `_freeze/` are present (they are — lines 2–3). Add `artifacts/decision-tree.json` (since pre-render hook now generates it) and `_site/pagefind/` (Pagefind output, regenerated each render). Leave `artifacts/graph.json`, `artifacts/tutorials.csv`, `artifacts/cooccurrence.csv` tracked because `artifacts-rebuild.yml` commits them — *but* this conflicts with the new pre-render hook; resolve by either (a) untracking them and letting pre-render generate them per environment, or (b) keeping `artifacts-rebuild.yml` as authoritative and treating pre-render as a no-op when artifacts are fresh. **Decide in Phase 2 before this commit.**
- **Acceptance:** `.gitignore` reflects the resolved policy; `git status` after a render shows no untracked render outputs.
- **Rollback:** revert `.gitignore`.

#### S1-10 — Update `vgwort-gate.yml` to match new TODO markers
- **Files:** `.github/workflows/vgwort-gate.yml`.
- **Change:** generalise the grep from `TODO_IMPRESSUM` / `TODO_DATENSCHUTZ` to `TODO_IMPRESSUM_*` / `TODO_DATENSCHUTZ_*` so the gate fires until every structured field is filled in (per S0-3 / S0-4).
- **Acceptance:** gate hard-fails today (because the skeleton has unfilled fields); passes once user populates every marker.
- **Rollback:** restore the simpler greps.

#### S1-11 — Add `PROJECT_CONCEPT.md` documenting deviations
- **Files:** new `PROJECT_CONCEPT.md`.
- **Change:** short document explaining: (a) DE jurisdiction posture, (b) R-based build scripts (vs Python template), (c) `_site/` + gh-pages deploy (vs `docs/`), (d) Pagefind chosen over Lunr, (e) Okabe-Ito extended with Tableau10/Set3 for 32 topics, (f) char-count gate at 2500 (above VG Wort floor). This is the canonical record of "why this repo diverges from CTTIR/tutorials".
- **Acceptance:** file committed; cross-referenced from `README.md`.
- **Rollback:** delete the file + revert README link.

---

## Deferred (carried forward in PLAN.md)

These come from `AUDIT.md` §10 S2/S3 plus pre-existing PLAN.md open questions.

- **S2-1** `renv.lock` — deferred until first real article batch lands.
- **S2-2** Governance docs (`COVERAGE.md`, `LEGAL.md`, `ORIGINALITY.md`, `README-network.md`) — stubs only, after Phase 4.
- **S2-3** Modularise `js/overview.js` into per-feature files — defer until content exists to drive UX iteration.
- **S2-6** `scripts/build_related.py` (R equivalent) — only useful with articles.
- **S2-7** Manifest-freshness CI check — defer with S2-2.
- **S3-1** First-article batch (out of scope, per Hard Rule #3).
- **S3-2** Shiny app deployment.
- **S3-3** API-liveness coverage — only meaningful with public-APIs articles.
- **Plausible vs Matomo** decision (from existing PLAN.md open questions) — defer until first real-traffic month.
- **VG Wort per-article pixel enforcement** — defer until first DE article ships.

---

## Risk register

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| `quarto publish gh-pages` token scope insufficient | M | Pages stays 404 | Use `peaceiris/actions-gh-pages@v4` with `GITHUB_TOKEN` instead; smoke-test deploy on a throwaway branch first |
| Pagefind binary unavailable on CI runner | L | Search degraded | `npx pagefind` is npm-installable; cache via setup-node action; fall back to Lunr if step fails |
| Pre-render hook breaks local renders without R toolchain installed | M | Contributors blocked | Document R prereqs in CONTRIBUTING.md; let the hook silently skip if Rscript missing |
| Impressum TODO markers ship to prod by accident | L | Legal exposure | `vgwort-gate.yml` hard-fails on any `TODO_IMPRESSUM_*` / `TODO_DATENSCHUTZ_*` |
| Tableau10/Set3 colours fail colourblind-safety audit | M | A11y regression on overview graph | Document in PROJECT_CONCEPT.md; consider grouping topics into 8 Okabe-Ito families if a11y testing fails Phase 3 Lighthouse |
| `artifacts-rebuild.yml` + new pre-render hook create commit loops | M | CI noise / merge conflicts | Resolve in S1-9: pick one source of truth before merging |
| Quarto version drift between local + CI | L | Render-output divergence | Pin in `_quarto.yml` + every workflow (S0-6) |
| User cannot supply real Impressum data soon | M | Deploy delayed indefinitely | Phase 1 ships the structured skeleton; deploy is gated on user data fill, not on Claude |

---

## Progress log

(Filled in during Phase 2, one short row per commit.)

| Commit | Item | Notes |
|---|---|---|
| | | |

---

## Carry-over from bootstrap PLAN.md (operational logs)

### Pre-existing open questions
- [ ] Plausible vs. Matomo for analytics? (decide before deploy)
- [ ] Single VPS Shiny Server vs. shinyapps.io split for 80 apps?
- [ ] de/ mirror later? (out of scope for v1)
- [ ] Cross-link CTTIR ↔ equilibria — closed (Q7: no link)
- [ ] Tier 2/3 prioritization — wait for analytics or pre-commit to roster?

### Tier 2 candidate ranking
(Updated quarterly based on Plausible/Matomo data after Tier-1 deploy)

### Unverified citations
(Auto-populated by citation-check workflow)

### Real-world-data review log
(One line per article: date, slug, sensitivity note)

### Ethics review log
(One line per article: date, slug, controversy level, frameworks covered)

### AI/ML benchmark verification log
(One line per AI/ML article citing benchmarks: date, slug, benchmarks, all verified Y/N)

### Inaccessible APIs
(One line per: date, name, source URL, reason for skipping)

### Deprecated R packages encountered

### Skipped ethics topics

### Crosslink graph

### Shiny app deployment status
| App slug | Deploy target | Last successful deploy | Status |
|---|---|---|---|

### Pending VG Wort pixel registrations
(Batch every 50 articles — Raban registers at tom.vgwort.de, then replaces TODO_VGWORT_*)

### Build issues encountered
