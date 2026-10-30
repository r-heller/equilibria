# #equilibria

A teaching site on game theory, decision-making, simulation and related R methods.
The current source contains 246 site pages across 32 topic areas, including one
implemented Shiny Nash-equilibrium explorer. Other app catalog entries are marked
as planned. Selected tutorials provide interactive figures; executable examples
are teaching demonstrations, not validated scientific or operational tools.

**URL:** <https://r-heller.github.io/equilibria/>

## Build and use locally

Prerequisites: R and its package compilation tools, Quarto 1.10.19, Python 3 and
Node.js 24/npm. Local verification used R 4.6.1 on macOS ARM64. Start in a normal,
visible checkout directory; Quarto can exclude inputs under hidden parent paths.
Install the R dependencies once:

```bash
Rscript -e 'install.packages(c("tidyverse","here","knitr","kableExtra","plotly","scales","yaml","jsonlite","gridExtra","R6","deSolve","fredr","igraph","lpSolve","shiny","downlit","xml2","WDI","combinat","patchwork","httr2","reticulate"), repos="https://cloud.r-project.org")'
Rscript R/build_artifacts.R
Rscript R/build_decision_tree.R
python3 scripts/check-source-refs.py
node tests/test_search.mjs
python3 -m unittest discover -s tests
Rscript tests/test_tutorial_regressions.R
Rscript tests/test_nash_2x2.R
Rscript tests/test_pairwise_matching.R
Rscript tests/test_ce_entropy.R
Rscript tests/test_combinatorial.R
Rscript tests/test_doi_status.R
quarto render
bash scripts/build_pagefind.sh
python3 scripts/check-html-links.py _site /tmp/equilibria-links.json --base-path /equilibria/
python3 -m http.server 8000 --directory _site
```

Open <http://localhost:8000>. Browse the topic cards, filter the A–Z tutorial
list, or use Search. Search requires the Pagefind step after every render.
The optional Python examples use `python/requirements.txt` in a separate virtual
environment; those integrations were not independently qualified by this review.
A static site cannot execute Shiny. Start the implemented app separately:

```bash
Rscript -e 'shiny::runApp("shiny-apps/01-two-by-two-nash-explorer", host="127.0.0.1", port=3838)'
```

Open <http://localhost:3838>. Try Matching Pennies, then Custom with all eight
payoffs set to zero; the latter correctly displays the full equilibrium family.
The kidney-exchange demonstration solves pairwise exchanges only, with a bounded
integer-programming solver; it does not claim to solve arbitrary exchange cycles.

`Rscript scripts/check-dois.R` checks DOI registrations online and fails when a
resolver outage leaves a result unknown. Registration is not verification that a
citation supports the text. See [MAINTENANCE.md](MAINTENANCE.md) for findings,
observed checks, scientific limits and remaining publication work. Build and
publish workflows run the same source, algorithm and rendered-navigation gates.
No hosted CI or deployment is implied by local results.

## License

The prose of these materials is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); all code (scripts, chunks, examples) is licensed under the [MIT License](LICENSE-CODE.md).

The existing Nash app carries a separate CC BY-SA 4.0 notice. That notice is
preserved; its relationship to the repository-wide code license needs an owner
decision before redistribution under a single license.

## Author

Raban Heller · [ORCID 0000-0001-8006-9742](https://orcid.org/0000-0001-8006-9742) · [GitHub](https://github.com/r-heller)

## Use of LLM tools

Portions of these materials were prepared with assistance from large language model tooling for
narrowly defined, non-authorial tasks: copyediting, prose smoothing, Markdown/LaTeX formatting,
scaffolding of boilerplate files (CI configs, build scripts), code refactoring. The tools used were [Chat AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/),
the LLM service of KISSKI (GWDG), and a self-hosted **Mistral Small (24B, Apache-2.0)** run locally via
[Ollama](https://ollama.com/) and the `ollamar` R package — local inference only, with no data sent to
third parties for the self-hosted model.

All scientific claims, methodological choices, analyses, interpretations, and conclusions are the
author's own. No LLM-generated text was incorporated without review and revision, and every reference
was verified against its DOI, arXiv ID, or ISBN.
