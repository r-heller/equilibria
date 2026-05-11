# AUDIT — equilibria — 2026-05-11

Auditor: Claude Code, branch `audit/2026-05-11`.
Scope: pre-deploy readiness of the `#equilibria` Quarto site against the
CTTIR/tutorials template contract.

---

## 1. Summary

- Repo is a fresh skeleton bootstrap (one feature commit, `2e96254`). All 32 topic-section index pages exist, but **zero tutorial articles** have been authored.
- Public-facing copy on `index.qmd`, `README.md`, `about.qmd`, `shiny/index.qmd` and each section index advertises **2436 tutorials / 80 Shiny apps** as if already published. Counter to Hard Rule #1: those numbers are aspirational and cannot be verified against any artefact.
- `LIVE_URL` `https://r-heller.github.io/equilibria/` returns **HTTP 404** — site is not deployed and GitHub Pages source has not been configured.
- Legal docs `impressum.qmd` and `datenschutz.qmd` are pure `TODO_IMPRESSUM` / `TODO_DATENSCHUTZ` placeholders. `vgwort-gate.yml` will hard-fail on PR.
- Template gap is large: missing `_data/topics.yml`, missing `scripts/` (template expects build_graph.py, build_pagefind.sh, build_indexes.py, build_related.py, vgwort_audit.py), no Pagefind setup, no front-matter validator workflow, no commercial-source CI gate, no Lighthouse a11y gate, no Quarto version pin, no `.nojekyll`, no `renv.lock`, no pre-render hook.
- `_quarto.yml` writes to `_site/`, but template + GitHub Pages convention in CTTIR/tutorials uses `docs/`. No deploy workflow exists at all (`build.yml` only uploads PR preview artifact; no `publish.yml`).
- `overview.js`'s `TOPIC_COLORS` map reuses the 8-colour Okabe-Ito palette across 32 topics → ~4 topics share each colour, defeating the "colour encodes topic area" promise on `overview.qmd`.
- `_includes/vgwort.html` and the `datenschutz.qmd` page imply a German/EU legal posture, but the site copy and licence are English. Decide jurisdiction explicitly before deploy.
- Build/render not attempted: requires R + Python toolchain and 2436-page render budget; deferred until S0/S1 fixes land.
- No commercial-source hits detected in the (very limited) content present today; `references.bib` has 3 entries, all with valid DOI/legitimate publishers.

---

## 2. Inventory + template gap matrix

### Inventory
- 93 tracked files; 52 `.qmd`/`.yml`/`.yaml`.
- Top-level: `_quarto.yml`, `index.qmd`, `overview.qmd`, `tutorials.qmd`, `about.qmd`, `impressum.qmd`, `datenschutz.qmd`, `404.qmd`, `references.bib`, `README.md`, `CONTRIBUTING.md`, `LICENSE`, `LICENSE-CONTENT`, `PLAN.md`, `GENERATION_LOG.md`, `.gitignore`, `styles.scss`, `theme-{light,dark}.scss`.
- Dirs: `tutorials/` (32 section indexes, no articles), `shiny/` (index + `tutorials/.gitkeep`), `shiny-apps/` (2 placeholder slugs), `decision-tree/` (3 pages), `R/` (11 scripts), `python/` (6 scripts + requirements.txt), `js/overview.js`, `_includes/`, `artifacts/` (3 empty CSV/JSON), `data/`, `.github/workflows/` (8 yml).
- Quarto version pin: **MISSING** (`_quarto.yml` has no `quarto-required:` field, `build.yml` uses `quarto-actions/setup@v2` unpinned).
- R deps: declared inline in each workflow's `setup-r-dependencies`. No `renv.lock`.
- Python deps: `python/requirements.txt` (not inspected; assumed for Shiny/decision-tree helpers).
- Node deps: none.
- `scripts/*` directory: **MISSING** entirely.
- Existing scripts (in `R/`): `_common.R`, `apis_helpers.R`, `build_artifacts.R`, `build_decision_tree.R`, `check_charcount.R`, `data_summary.R`, `interpretability_helpers.R`, `ml_helpers.R`, `plotly_helpers.R`, `shiny_helpers.R`, `theme_publication.R`, `torch_helpers.R`.
- Existing scripts (in `python/`): `benchmarks_helpers.py`, `cfr_solver.py`, `nash_solver.py`, `requirements.txt`, `rl_agents.py`, `transformers_helpers.py`.

### Template gap matrix
| Template element | Status | Notes |
|---|---|---|
| `_quarto.yml` | PRESENT, DIVERGENT | output-dir `_site/` (template uses `docs/`), no `quarto-required:`, no pre-render hook, includes references to `_includes/vgwort.html` despite English-only site copy |
| `index.qmd` | PRESENT | Fabricated counts (150, 120, …) on every topic card |
| `overview.qmd` | PRESENT, DIVERGENT | Single-file JS hookup; template expects modular `assets/js/overview/{main,state,graph,search,legend,slider,heatmap,list,a11y}.js` |
| `tutorials.qmd` | PRESENT | Loads `artifacts/tutorials.csv` (currently header-only) |
| `about.qmd` | PRESENT | Fabricated counts |
| `impressum.qmd` | PRESENT | `TODO_IMPRESSUM` placeholder — S0 |
| `datenschutz.qmd` | PRESENT, EXTRA | `TODO_DATENSCHUTZ` placeholder — S0 (template doesn't necessarily include this for EN-only sites) |
| `references.bib` | PRESENT | 3 entries; DOIs look valid |
| `README.md` | PRESENT | Fabricated counts |
| `LICENSE`, `LICENSE-CONTENT` | PRESENT | not opened — assumed standard MIT / CC-BY-SA |
| `.gitignore` | PRESENT | Missing `_artifacts/`, `docs/`, `*.html.lua`, `node_modules/`; otherwise reasonable |
| `.nojekyll` | MISSING | Required for `_site/` or `docs/` Pages deploy |
| `renv.lock` | MISSING | Template convention for R-dep reproducibility |
| `PLAN.md` | PRESENT | Pre-populated with deferred questions; will be re-used in Phase 1 |
| `AUDIT.md` | PRESENT (this file) | |
| `COVERAGE.md` | MISSING | |
| `LEGAL.md` | MISSING | |
| `ORIGINALITY.md` | MISSING | |
| `PROJECT_CONCEPT.md` | MISSING | |
| `README-network.md` | MISSING | |
| `_data/topics.yml` | MISSING | Topics currently hard-coded in `_quarto.yml` navbar + `index.qmd`; no single source of truth |
| `scripts/build_graph.py` | MISSING | Equivalent functionality exists at `R/build_artifacts.R` (R, not Python) |
| `scripts/build_related.py` | MISSING | No "Related tutorials" generator |
| `scripts/build_pagefind.sh` | MISSING | No Pagefind index built at all |
| `scripts/build_indexes.py` | MISSING | |
| `scripts/vgwort_audit.py` | MISSING | Template requires for DE-language content with ≥1800-char pages |
| `_artifacts/` (render-time, gitignored) | MISSING | `artifacts/` is tracked instead — divergent |
| `_artifacts/` in `.gitignore` | N/A | |
| Pre-render hook in `_quarto.yml` | MISSING | |
| `.github/workflows/publish.yml` (deploy) | MISSING | Only `build.yml` (PR preview artifact) — site cannot deploy via CI |
| Quarto version pin in CI | MISSING | |
| Pagefind step in CI | MISSING | |
| Front-matter validator in CI | MISSING | |
| Manifest-freshness check in CI | MISSING | |
| `topics.yml` integrity check | MISSING | (file itself doesn't exist) |
| Commercial-link gate | MISSING | |
| Lighthouse a11y ≥ 95 in CI | MISSING | |
| Per-tutorial nine-section template | UNTESTABLE | Zero tutorials exist |
| `assets/js/overview/*` modular JS | DIVERGENT | Single `js/overview.js` instead |
| `assets/scss/overview/_overview.scss` | DIVERGENT | Styles in top-level `styles.scss` + `theme-{light,dark}.scss` |

### Existing CI workflows (8) — short description
- `build.yml`: render on PR, upload `_site/` as artifact. **No deploy step.**
- `api-liveness.yml`: weekly HEAD check on `api_or_dataset.endpoint_or_url` from `tutorials/public-apis-and-datasets/**` (currently zero articles).
- `artifacts-rebuild.yml`: on push to `main` under `tutorials/**`, run `R/build_artifacts.R` and commit refreshed `artifacts/*`.
- `char-count.yml`: PR gate; ≥ 2500 prose chars per article.
- `citation-check.yml`: PR gate; resolve every `doi:` in `references.bib`.
- `figure-check.yml`: PR warning; each article must reference static + interactive figure helpers.
- `shiny-deploy.yml`: on push to `main` under `shiny-apps/**`, deploy changed apps to shinyapps.io. Secrets `SHINYAPPS_*` not yet set; workflow currently just echoes that fact.
- `vgwort-gate.yml`: PR gate; hard-fail on `TODO_IMPRESSUM` or `TODO_DATENSCHUTZ`; warn on `TODO_VGWORT_`.

---

## 3. Live-site issues

- `GET https://r-heller.github.io/equilibria/` → **404**. GitHub Pages either not enabled for this repo or pointed at the wrong branch/folder.
- All other 0.3 sub-checks (navbar link statuses, depth-2 broken-link scan, Pagefind, related-tutorials block, dark-mode toggle, mobile ≤768px) are **N/A until the site is deployed once**.

---

## 4. Front-matter violations

- No tutorial articles exist (zero files matching `tutorials/<topic>/<slug>/index.qmd`). Front-matter contract therefore cannot be enforced or violated yet.
- Section index pages (`tutorials/*/index.qmd`) carry `listing:` blocks but no `categories:` array, which is correct for listing pages.
- `_quarto.yml` navbar lists 32 topic entries; none of them is yet anchored to a `_data/topics.yml` row, so the "categories[0] matches topics.yml" rule has nothing to enforce.

---

## 5. Citation + link failures

- `references.bib` contains 3 entries:
  - `von_neumann_morgenstern_1944` — book, no DOI (citation-check.yml only validates entries that include `doi`, so this passes).
  - `nash_1950` — DOI `10.1073/pnas.36.1.48` — looks legitimate (PNAS).
  - `nash_1951` — DOI `10.2307/1969529` — looks legitimate (JSTOR / Annals of Mathematics).
  - DOI resolution **not live-tested** in this read-only phase; deferred to Phase 2 via the existing `citation-check.yml`.
- External links in scaffolding pages: `quarto.org`, `shiny.posit.co`, `pages.github.com`, `orcid.org/0000-0001-8006-9742`, `github.com/r-heller/equilibria`, `cttir.github.io/tutorials/`, `plausible.io/js/script.js` (commented out). All plausible; none live-checked.

---

## 6. Commercial-source hits

- No hits across content + bib for: `klett.de`, `cornelsen.de`, `oup.com`, `cambridge.org`, `pearson.com`, `mheducation.com`, `wiley.com`. (Greppable scan deferred to the formal CI gate, which itself does not yet exist — flagged as S1.)

---

## 7. Legal / Impressum gaps

- `impressum.qmd`: **`TODO_IMPRESSUM`** placeholder, no name, no postal address, no contact, no § 5 TMG fields, no responsible-person line. — **S0**
- `datenschutz.qmd`: **`TODO_DATENSCHUTZ`** placeholder. — **S0** (if German jurisdiction applies)
- Jurisdiction is ambiguous: site copy + licence are English (`en-GB` per prompt overrides), yet `_quarto.yml` includes `_includes/vgwort.html` and `datenschutz.qmd` exists. Decide whether VG Wort + § 5 TMG actually apply (i.e., is Raban Heller hosting from Germany / addressing German readers?) before drafting either page.
- Contact email exposed in `_quarto.yml:126`, `about.qmd`, `README.md`: `58561665+r-heller@users.noreply.github.com` — GitHub noreply, low PII risk, but it is a deliverable mailto for "Kontakt" which some EU readers may treat as non-compliant with § 5 TMG (requires a directly reachable address). Open question for user.
- `analytics.html` is empty (commented Plausible block); no third-party tracker is currently loaded, which is good for the Datenschutz draft.

---

## 8. Build + reproducibility issues

- `quarto render` not attempted (requires local R + Python toolchain provisioning, multi-minute render budget for 32 listing pages, and is out-of-scope for read-only Phase 0). Deferred to Phase 2.
- `Rscript -e 'renv::restore()'`: **N/A**, no `renv.lock`.
- Pre-render hook: not configured. `_quarto.yml` does not invoke `R/build_artifacts.R` before render, so `artifacts/{graph.json,tutorials.csv,cooccurrence.csv}` is only refreshed by the `artifacts-rebuild.yml` workflow on push to `main` — i.e., after merge, not before render. Current artifacts are the bootstrap stubs (`{"nodes":[],"edges":[]}` and CSV headers only).
- `R/build_decision_tree.R` is referenced by `decision-tree/decision-assistant.qmd` and `decision-tree/decision-tree.qmd` (`fetch('../artifacts/decision-tree.json')`) but **`artifacts/decision-tree.json` does not exist**. Both pages will render but their JS will display the "data not yet available" fallback.
- `scripts/build_pagefind.sh`: not present; no Pagefind index produced; `docs/pagefind/pagefind.js` not built. Quarto's built-in navbar search uses Lunr by default, so search will work in degraded form, but it will not match the CTTIR template's offline-capable Pagefind.
- `_site/` (output-dir) is not in `.gitignore`. Currently empty in the working tree, but a local render would leave it tracked unless ignored.
- `.nojekyll` not present. GitHub Pages will run Jekyll on the deploy output by default and strip any `_…` directories. Critical S0 if the chosen deploy target is `docs/` or root.
- `python/requirements.txt` not opened/validated; assumed importable.

---

## 9. Open questions

1. **Deploy target.** Is GitHub Pages going to be configured for `main:/docs`, `main:/_site`, or a `gh-pages` branch? Current Pages settings cannot be inferred from the repo alone (returns 404). Affects the `output-dir` value, `.nojekyll` placement, and the future `publish.yml`.
2. **Jurisdiction.** Is this site published from Germany / addressed to German readers (→ § 5 TMG + Datenschutzerklärung + VG Wort all apply), or is it an EN-only project (→ delete `datenschutz.qmd` and `_includes/vgwort.html`, simplify `impressum.qmd` to a minimal "Editor / Contact" notice)?
3. **Contact address.** Is the GitHub noreply email acceptable as the public contact, or should a real (or aliased) address replace it before deploy?
4. **Fabricated counts policy.** All "2436 tutorials / 32 topics / 80 apps" copy + per-topic "150 / 120 / 105 / …" numbers refer to a future state, not the current zero-article state. Three options: (a) remove the numbers entirely until articles exist; (b) phrase them as "planned / target" everywhere; (c) keep them and add a banner explaining the roadmap. (a) is the only one fully consistent with Hard Rule #1.
5. **R or Python for build scripts?** Template expects `scripts/build_*.py`; this repo already uses `R/build_artifacts.R` and `R/build_decision_tree.R`. Stay in R (no template re-port needed) or port to Python for parity with sister sites?
6. **Pagefind.** Add Pagefind step + `scripts/build_pagefind.sh` (CTTIR-template-compatible), or accept Quarto's built-in Lunr search?
7. **Sister-site cross-link.** README + `about.qmd` link to `cttir.github.io/tutorials/`. Should the navbar also surface this, or is the README mention sufficient?
8. **VG Wort gate.** Keep `_includes/vgwort.html` and `vgwort-gate.yml`? Only meaningful for German-language content with ≥1800 chars. Currently the gate hard-fails on the legal `TODO_*` markers, which doubles as a useful pre-deploy guard even if VG Wort itself doesn't apply.
9. **Decision-tree JSON source.** `build_decision_tree.R` exists but its output is missing. Should `artifacts/decision-tree.json` be (a) committed as a seed, or (b) generated by a pre-render hook? Currently neither.
10. **Topic-colour collisions.** Accept that 32 topics share 8 Okabe-Ito colours (4× collisions), extend the palette, or switch to a continuous categorical scheme (e.g. d3.schemeTableau10 + d3.schemeSet3)?

---

## 10. Severity-ranked fix list

### S0 — blocks deploy

- **S0-1** GitHub Pages is not serving the site (`LIVE_URL` → 404). Configure Pages, decide deploy target, add `publish.yml` workflow that runs `quarto render` and deploys to the chosen branch/folder.
- **S0-2** Add `.nojekyll` at the deploy-output root to prevent Jekyll from stripping `_*` directories.
- **S0-3** `impressum.qmd` is `TODO_IMPRESSUM`. Decide jurisdiction (open question #2), then either populate or remove + delete the navbar/footer link.
- **S0-4** `datenschutz.qmd` is `TODO_DATENSCHUTZ`. Same disposition decision as S0-3.
- **S0-5** Remove or rephrase fabricated headline counts ("2436 tutorials / 32 topic areas / 80 apps" and per-topic "150 / 120 / …") on `index.qmd`, `about.qmd`, `README.md`, `shiny/index.qmd`, and every `tutorials/*/index.qmd` `topic-card-label`. Cannot be verified ⇒ Hard Rule #1 violation.
- **S0-6** Pin Quarto version: add `quarto-required:` to `_quarto.yml` and `with: { version: X.Y.Z }` to every workflow that calls `quarto-dev/quarto-actions/setup@v2`.

### S1 — should fix before deploy

- **S1-1** Add `_data/topics.yml` as single source of truth for the 32 topics (slug, display name, blurb, planned count). Drive `index.qmd` topic cards, `_quarto.yml` navbar, and `overview.js` colours off this file.
- **S1-2** Expand or replace `TOPIC_COLORS` in `js/overview.js` — current 8-colour palette collides across 32 topics (4× duplicates).
- **S1-3** Add front-matter validator workflow (every `tutorials/**/<slug>/index.qmd` has title, date, description, categories[0] ∈ topics.yml, kebab-case tags, labels ∈ allowed set). Currently zero articles, so this gate will pass trivially but must be in place before the first article PR.
- **S1-4** Add commercial-source gate workflow.
- **S1-5** Add Lighthouse a11y gate (soft fail) on `overview.html` + a random article.
- **S1-6** Add a pre-render hook in `_quarto.yml` to run `R/build_artifacts.R` so render-time artifacts are always fresh; or generate them in CI before `quarto render` in `publish.yml`.
- **S1-7** Generate `artifacts/decision-tree.json` (run `R/build_decision_tree.R`) and either commit it or wire it into the pre-render hook.
- **S1-8** Decide R-vs-Python for build scripts (open question #5). If staying with R, document the deviation in `README.md` or `PROJECT_CONCEPT.md` so it doesn't re-surface in future audits.
- **S1-9** Output-dir alignment: either change `_quarto.yml` `output-dir:` from `_site` to `docs` and add `.nojekyll` there, or keep `_site` and use a deploy workflow that pushes to `gh-pages`. Pick one and stick with it.
- **S1-10** Add `_site/` (or `docs/`) and `artifacts/decision-tree.json` to `.gitignore` once decided.
- **S1-11** Decide commercial-vs-noreply contact address (open question #3) and update `_quarto.yml`, `about.qmd`, `README.md` to a single source.

### S2 — nice to have

- **S2-1** `renv.lock` for R-dep reproducibility.
- **S2-2** Add `COVERAGE.md`, `LEGAL.md`, `ORIGINALITY.md`, `PROJECT_CONCEPT.md`, `README-network.md` (template governance files). Probably stub-only at this stage.
- **S2-3** Modularise `js/overview.js` into `assets/js/overview/{main,state,graph,search,legend,slider,heatmap,list,a11y}.js` for parity with CTTIR/tutorials template and easier per-feature maintenance.
- **S2-4** Add Pagefind step + `scripts/build_pagefind.sh` (only if open question #6 chooses Pagefind).
- **S2-5** Port `R/build_artifacts.R` → `scripts/build_graph.py` if porting to Python is chosen.
- **S2-6** `scripts/build_related.py` for the per-article "Related tutorials" block — only useful once articles exist.
- **S2-7** Manifest-freshness check (artifact mtimes vs. tutorial mtimes) in CI.

### S3 — deferred

- **S3-1** First-article batch (the actual 2436-page roadmap). Out of scope for this audit pass per Hard Rule #3.
- **S3-2** First Shiny-app deployment. Currently only two `.gitkeep` placeholders under `shiny-apps/`.
- **S3-3** API-liveness coverage. Only meaningful once tutorials exist under `tutorials/public-apis-and-datasets/`.
- **S3-4** Plausible vs. Matomo decision (already deferred in PLAN.md open questions).
- **S3-5** Tier 2/3 prioritisation (already deferred in PLAN.md open questions).

---

**Next step:** stop and wait for user to (a) answer §9 open questions and (b) approve which S0/S1 items to action in Phase 1.
