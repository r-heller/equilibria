# Maintenance record — 30 October 2026

## Purpose, strategy and acceptance

This is an R teaching site for game theory and related methods: 246 configured
site pages across 32 topic areas, with one implemented Shiny explorer. Prioritize
executable correctness, defensible explanations, working navigation and honest
app availability. Release criteria for this local maintenance milestone are a
strict full-site render, independent checks of repaired algorithms, working
catalog/search/decision navigation and no broken rendered local links. Broader
scientific review, optional external backends and hosted operation remain distinct.

The original checkout is preserved. The candidate first incorporated existing
remote commits through `48a0e26`; their history and attribution were not rewritten.

## Material findings and repairs

- High — `_quarto.yml` permitted execution errors to become pages. Fail the build
  on an executable error and explicitly enumerate source families. Missing R
  dependencies and inconsistent CI inventories are corrected. Build and publish
  workflows now run source, algorithm, search and rendered-link checks.
- High — the 2×2 Nash solver missed boundary/degenerate equilibria. Enumerate all
  nine support pairs, representing complete point/segment/rectangle families.
  The tutorial and app use the same solver. Independent best-response checks
  cover 18,150 grid memberships; real browser checks cover Matching Pennies and
  the all-indifferent game's entire unit square.
- High — kidney matching used an impractical exponential search for 50 vertices.
  Use bounded exact binary optimization for the explicitly pairwise problem;
  109 small independent exhaustive cases protect optimality. This does not solve
  arbitrary kidney-exchange cycles or constitute clinical allocation software.
- High — the correlated-equilibrium entropy optimizer started infeasibly, used
  an incorrect normalization gradient and inconsistent matrix ordering. Enumerate
  2×2 CE vertices and optimize entropy over their convex mixtures. Linear welfare
  maximization uses the vertices directly. Independent obedience/normalization
  checks, four games, known uniform/unique solutions, row permutations and 7,084
  probability-grid comparisons pass. Correct Chicken payoffs and remove the false
  equivalence between maximizing joint entropy and minimizing mutual information.
- High — both secret-sharing demonstrations excluded zero polynomial coefficients;
  one also overflowed during modular inversion. Use full-field coefficients and
  bounded exact modular arithmetic, reject invalid shares/fields, and test 400
  reconstructions plus 3,084 modular inverses. The second tutorial's auction used
  plaintext sorting while claiming MPC privacy. Relabel it as a centralized ideal
  outcome benchmark, remove unsupported security/incentive claims, and correct
  first-price bids for U[10,100] valuations. These examples are not security tools.
- High — El Farol forecast scoring used future observations. Score the recorded
  forecasts only after the observed attendance arrives; hand-calculated regression
  cases protect the chronology. Remove unsupported chaos/symmetry conclusions.
- High — Clarke public-project charges used mismatched matrix dimensions. Correct
  the externality calculation; independently check pivotal/nonpivotal, no-build,
  tie and one-beneficiary cases.
- High — the combinatorial auction failed on numeric formatting, dropped matrix
  dimensions in `pmax`, and counted any two items as the specific A+B bundle.
  Preserve dimensions, check solver status, record actual A+B acquisition and
  compare the displayed algorithm to all 256 allocations and exact VCG payments.
- Medium — Moran fixation mishandled zero mutants and overflowed for large
  populations. Handle absorbing states and use log-sum-exp; verify neutral drift,
  constant-fitness closed forms and a 2,000-member population.
- High — the pivotal-mechanism example recycled one agent's utility across all
  agents, gave a subsidy instead of a charge for a negative pivotal type, and
  claimed it never ran a deficit. Correct utilities/externalities and the worked
  deficit of 32; 728 independent deviation comparisons pass. Use a sequential
  color scale for all observed pivotal-agent counts.
- High — the no-regret comparison could generate negative sampling probabilities
  in its first round. Bound and normalize linear MWU updates, scale Exp3 rewards
  to [0,1], and use horizon-dependent learning/exploration rates. Six 1,000-round
  learning runs and independent one-step formulas pass. Correct the distinction
  between CCE joint distributions and Nash marginals, linear/exponential weights,
  and the limits of one seeded trajectory.
- High — the preregistration example paired independent groups, diluted treatment
  across mixed conditions and misparameterized the ICC. Generate shared group
  effects for paired conditions, use the latent variance ratio and join exactly
  the intended pairs. Vectorization removes millions of per-observation data-frame
  allocations. Group-count, bound and shared-effect variance checks pass; naive
  unclustered analyses are explicitly invalid confirmatory alternatives. Power
  estimates, clipping and Monte Carlo uncertainty are qualified.
- High — the Monte Carlo example repeatedly integrated more than eleven million
  bids and mislabeled a right-rectangle sum as trapezoidal integration. Precompute
  actual trapezoidal quadrature and interpolate, vectorize auction revenue and
  compute running variances in linear time. Bids agree with uniform-value closed
  forms and 309 adaptive Beta integrals within 1e-7. Separate quadrature error
  from pointwise sampling intervals and remove unimplemented-feature claims.
- High — the Granger example's printed degrees of freedom did not account for
  dropped lags, and its prose identified economic leadership from predictive
  dependence. Correct the formula, validate input/rank, compare its actual helper
  with independent nested-model ANOVA, and qualify both toy scenarios and
  reduced-form impulse responses. Plot annotations now use computed p-values.
- Medium — final execution found incompatible VAR row/column arrays, mismatched
  columns when combining plot panels, and invalid plotmath labels. Normalize
  vector dimensions and panel columns, and use readable labels. Visual inspection
  then corrected a clipped label and reversed best-response arrows.
- Medium — other strict-render defects included XOR dimensions, singleton bundle
  loops, a shadowed bankruptcy endowment, inherited plot aesthetics, missing
  `tidyr`, nested export directories and a malformed 2×2 matrix constructor.
  Correct the affected examples and protect their meaningful edge cases.
- Medium — the folk-theorem worked incentive threshold and feasible-payoff claim
  were wrong. Derive the public grim-trigger threshold and state its assumptions.
  Qualify the limited support-enumeration helper: singular/unequal supports and
  equilibrium continua are outside its implemented scope.
- Medium — 122 tutorial links were broken. Resolve 84 to actual source pages and
  mark 38 unavailable topics as such. Repair nine absent targets in the decision
  assistant and add checks for its node edges and all dynamically generated URLs.
  The A–Z listing and topic counters split
  quoted CSV incorrectly; use the existing JSON inventory and DOM text instead.
  Four missing bibliography entries are added from primary sources. A source
  gate checks local targets and citation keys; Pagefind is pinned to 1.5.2.
- High — the overview imported Pagefind relative to its JavaScript directory,
  so searches returned no results. Resolve the module against the document URL,
  normalize directory/index/HTML URLs and ignore stale asynchronous search results.
  Browser searches pass at both the root and GitHub Pages deployment prefix.
  Keep the list usable when the external graph library fails; Reset zoom is safe
  in that state. The A–Z table now preserves readable mobile column widths with
  horizontal scrolling instead of crushing titles to a few characters per line.
- Medium — the rendered-link checker misinterpreted Quarto's prefixed 404 assets.
  Add an explicit deployment-prefix option and regression checks that still
  reject genuinely missing files and anchors.
- Medium — the DOI workflow treated denials/server errors as registered citations.
  Require successful Handle payloads, distinguish unknown/missing/registered, and
  test failure classifications. Actual DOI resolver checks passed; any documented
  unregistered exception remains explicitly unverified. Registration alone does
  not establish that a citation supports a scientific claim.
- Medium — the Shiny catalog implied many working apps. Keep one implemented app
  distinct from 80 planned entries. Correct license links and the site's prose/
  code footer. API failure reports now reach `gh` through a file rather than
  interpolating endpoint text into shell commands.

## Verification evidence

R 4.6.1, Quarto 1.10.19, Node 24 and Chromium on macOS ARM64. Source references,
repaired-algorithm regressions, app browser journeys and DOI resolver checks pass.
The strict full-site render passed in 694.41 seconds. A subsequent targeted
render updated the mobile catalog, and the final JavaScript resources were copied
from the same maintained source. Pagefind 1.5.2 indexed all 246 pages in two
languages. The final rendered gate checked 89,094 local references with zero
broken files or anchors. All 84 tutorials selected for an independent execution
pass completed after the recorded repairs; failures and interrupted performance
runs are retained separately.

Real browser checks passed for 198 tutorial counts plus the Shiny tutorial,
199 catalog rows, filtering and article links, the decision assistant, overview,
Pagefind search, deployment-prefix search/404 assets, mobile layout, and loss of
the external graph library. No page errors occurred. Desktop/mobile screenshots
and repaired scientific figures were visually inspected. The source-copy check
matched all 308 maintained site/algorithm/configuration/artifact files it covers.
Python link-resolution and Node URL-mapping regressions also pass. The preview
server was replaced after its small connection backlog caused test-only resets;
this was not hidden as a product pass.

Primary references consulted include Shamir's original secret-sharing paper
(https://dspace.mit.edu/entities/publication/91c51bfc-5678-409c-80c5-44ce8fcdbadf),
Nashpy's degeneracy documentation
(https://nashpy.readthedocs.io/en/stable/how-to/handle-degenerate-games.html),
primary publisher records for the added bibliography entries, and Pagefind's
installation documentation. Granger's prediction framework was checked against
his original paper (https://www.jstor.org/stable/1912791). Repository records
preserve the bibliography itself.

## First use and release boundaries

README.md provides exact dependencies, artifact generation, test, render, search,
local-server and Shiny launch commands. A static host serves tutorials and search;
the Shiny app needs its separate R process. The source must be in a normal visible
checkout for Quarto's discovery; local verification used an isolated visible copy.

A successful render is not a scientific validation of every explanation or
external data source. Optional Python integrations, actual deployment and live
external-data behavior were not independently qualified. Longer-term work should
prioritize domain review, deduplication of overlapping tutorials and additional
independent numerical oracles over adding more pages/apps.

Before publication, review the candidate and observed CI, confirm a working
publication contact and applicable privacy statements, and resolve the existing
Nash-app CC BY-SA notice versus repository-wide MIT code licensing. Existing
legal text and app notice were preserved. No deployment or legal acceptance is
claimed. Exact commands, failures, outputs and browser evidence are retained in
the dated portfolio audit's `equilibria/` directory.
