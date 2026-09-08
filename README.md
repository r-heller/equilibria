# #equilibria

Comprehensive tutorials on game theory, decision-making, simulation, AI/ML, and the data behind them — with runnable R examples and interactive apps throughout.

**URL:** <https://r-heller.github.io/equilibria/>

## Scope

- Comprehensive coverage across 32 topic areas
- Interactive Shiny applications paired with selected tutorials
- R primary, Python via `reticulate` for advanced topics
- Publication-ready static figures + interactive visualizations in every article

## Build

```bash
# Prerequisites: Quarto, R, Python
quarto render
```

## License

The prose of these materials is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); all code (scripts, chunks, examples) is licensed under the [MIT License](LICENSE-CODE.md).

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
