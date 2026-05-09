# Generation log — #equilibria

One line per Claude Code turn. Append-only.

| Date | Phase | Deliverable | Notes |
|------|-------|-------------|-------|
| 2026-05-08 | 1 | Repo + skeleton | initial bootstrap with CTTIR-style architecture |
| 2026-05-08 | 2 | Article template + frontmatter contract | canonical template, figure standards, charcount refinement |
| 2026-05-08 | 3 | CI gates refined | all 8 workflows hardened: figure-check excludes template, citation-check robust DOI parsing, api-liveness opens issues |
| 2026-05-08 | 4.1 | Article: nash-equilibrium-mixed | foundations — Mixed-strategy Nash equilibrium in 2×2 games |
| 2026-05-08 | 4.2 | Article: iterated-prisoners-dilemma-axelrod | classical-games — Axelrod's IPD tournament replicated in R |
| 2026-05-08 | 4.3 | Article: replicator-dynamics-rps | evolutionary-gt — Replicator dynamics for RPS with deSolve |
| 2026-05-08 | 4.4 | Article: spatial-prisoners-dilemma-nowak-may | simulations — Nowak & May 1992 lattice PD with cluster formation |
| 2026-05-08 | 4.5 | Article: cuban-missile-crisis-signaling-game | real-world-data — Crisis as signaling game under incomplete information |
| 2026-05-08 | 4.6 | Article: trolley-problem-as-game | ethics — Trolley Problem under moral uncertainty with EMV |
| 2026-05-08 | 4.7 | Article: perceptron-to-deep-learning | ai-ml — Rosenblatt → Minsky-Papert → backprop → deep learning in R |
| 2026-05-08 | 4.8 | Article: world-bank-wdi-economic-indicators | public-apis — WDI data for game-theoretic calibration |
| 2026-05-08 | 4.9 | Shiny app + tutorial: two-by-two-nash-explorer | shiny — Complete app with solver, BR plot, payoff surfaces |
| 2026-05-08 | 4.10 | Article: publication-ready-ggplot-theme | visualization — theme_publication() end-to-end + Okabe-Ito showcase |
| 2026-05-08 | 5.1 | Batch: foundations ×4 | dominant-strategies-IESDS, extensive-form-SPE, zero-sum-minimax, nash-bargaining |
| 2026-05-08 | 5.2 | Batch: classical-games ×5 | PD-formal, battle-of-sexes, matching-pennies, stag-hunt, chicken-hawk-dove |
| 2026-05-08 | 5.3 | Batch: new-section seeds ×4 | decision-theory/EU-VNM, cooperative-gt/shapley, mechanism-design/vickrey, behavioral-gt/ultimatum |
| 2026-05-08 | 5.4 | Batch: auction + bayesian seeds ×2 | auction-theory/first-price-sealed-bid, bayesian-methods/bayesian-games-incomplete-information |
| 2026-05-08 | 5.5 | Batch: 6 section seeds (behavioral-econ → history) | prospect-theory, spectrum-auction, IV-causal, MPC-crypto, public-goods-experiment, GT-timeline |
| 2026-05-08 | 5.6 | Batch: 6 section seeds (info-theory → optimization) | entropy-info, matrix-games, MARL, network-formation, centrality, lemke-howson |
| 2026-05-08 | 5.7 | Batch: 5 section seeds (R-pkg → ethics-apps) | R-package-dev, reproducible-workflow, hypothesis-testing, VAR-models, algorithmic-fairness |
| 2026-05-08 | 5.8 | Batch 3: foundations ×4 | signaling-games-PBE, correlated-equilibrium, folk-theorem, rationalizability |
| 2026-05-08 | 5.9 | Batch 3: evolutionary-gt ×2 | ESS-definition, moran-process-finite-populations |
| 2026-05-08 | 5.10 | Batch 3: auction-theory ×3 | revenue-equivalence, common-value-winners-curse, GSP-auction |
| 2026-05-08 | 5.11 | Batch 3: mechanism-design ×3 | VCG-mechanism, deferred-acceptance, mechanism-design-intro |
| 2026-05-08 | 5.12 | Batch 3: cooperative-gt ×2 | core-stability, voting-power-indices |
| 2026-05-08 | 5.13 | Batch 3: cross-section ×6 | public-goods-punishment, colonel-blotto, bank-runs, allais-paradox, global-games, arms-race |
| 2026-05-08 | 5.14 | refs: +11 BibTeX entries | VCG lineage, Gale-Shapley, Gibbard, Fehr-Gächter |
| 2026-05-08 | 5.15 | Batch 4: simulations + ai-ml ×2 | monte-carlo-game-equilibria, gans-minimax-game |
| 2026-05-08 | 5.16 | Batch 4: 6 second articles (group A) | nudge, tragedy-of-commons, DiD-strategic, ZKP, dictator-game, nash-existence-proof |
| 2026-05-08 | 5.17 | Batch 4: 6 second articles (group B) | VOI-games, LP-duality-zero-sum, fictitious-play, congestion-games, cascades, support-enumeration |
| 2026-05-08 | 5.18 | Batch 4: 6 second articles (group C) | FRED-data, testthat-GT, quarto-params, bootstrap-GT, granger-causality, privacy-game |
| 2026-05-09 | 5.19 | Batch 5: evolutionary-gt + cooperative-gt ×2 | hawk-dove-war-of-attrition, rubinstein-alternating-offers |
| 2026-05-09 | 5.20 | Batch 5: 6 third articles (group A) | reserve-prices, reference-dependence, level-k, penalty-kicks, climate-coalition, ABM-markets |
| 2026-05-09 | 5.21 | Batch 5: 6 third articles (group B) | trust-game, network-PG, mental-accounting, adversarial-ML, RDD-strategic, cheap-talk |
| 2026-05-09 | 5.22 | Batch 5: 6 third articles (group C) | voting-paradoxes, plotly-dashboards, power-law-networks, eigenvalue-repeated, selten-THP, blockchain |
| 2026-05-09 | 5.23 | Batch 6: foundations + auction-theory ×2 | backward-induction-centipede, all-pay-auction-lobbying |
| 2026-05-09 | 5.24 | Batch 6: 6 articles (group A) | ggplot2-annotations, structural-estimation, MLE-game-estimation, docker-environments, S4-classes, openai-gym-RL |
| 2026-05-09 | 5.25 | Batch 6: 6 articles (group B) | gradient-descent-NE, SHAP-values, fair-division, matching-pennies-exp, combinatorial-auctions, AI-alignment |
| 2026-05-09 | 5.26 | Batch 6: 6 articles (group C) | replicator-mutator, coalition-formation, information-design, hyperbolic-discounting, ambiguity-Ellsberg, OPEC-cartel |
