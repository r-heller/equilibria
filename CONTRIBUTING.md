# Contributing to #equilibria

Thank you for your interest in contributing.

## Workflow

1. Fork the repository.
2. Create a feature branch (`feat/<topic>-<slug>`).
3. Follow the article template and frontmatter contract (see `_quarto.yml` and existing articles).
4. Ensure your article has ≥ 2500 prose characters (run `Rscript -e 'source("R/check_charcount.R"); check_all_articles()'`).
5. Verify all citations resolve to real DOIs, arXiv IDs, or PubMed IDs.
6. Include both a static publication-ready figure and an interactive figure.
7. Open a pull request against `main`.

## Standards

- **Code:** R primary, Python via `reticulate` for advanced topics.
- **Figures:** Okabe-Ito colorblind-safe palette. Static: PDF + PNG @ 300dpi. Interactive: plotly/htmlwidgets.
- **Citations:** Every academic reference must have a verifiable DOI, arXiv ID, or PubMed ID.
- **Ethics:** Descriptive of frameworks, never prescriptive on contested issues.
- **Data:** No PII. Aggregated, anonymized, redistribution-licensed only. License documented.

## License

By contributing, you agree that your contributions will be licensed under the MIT License (code) and CC BY 4.0 (content).
