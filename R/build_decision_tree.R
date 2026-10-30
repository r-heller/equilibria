# build_decision_tree.R — generates decision-tree.json for the
# game-theoretic model/solution concept selection wizard.
# Output goes to artifacts/decision-tree.json.

suppressPackageStartupMessages(library(jsonlite))

#' Build the decision tree for model selection
#' @param output_file Path for output JSON
build_decision_tree <- function(output_file = "artifacts/decision-tree.json") {
  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)

  # Each node: id, question (or result), children (yes/no or multiple options)
  tree <- list(
    id = "root",
    question = "What type of strategic interaction are you analyzing?",
    options = list(
      list(
        label = "Players choose actions simultaneously",
        next_id = "simultaneous"
      ),
      list(
        label = "Players choose actions sequentially",
        next_id = "sequential"
      ),
      list(
        label = "A designer sets the rules for players",
        next_id = "mechanism"
      ),
      list(
        label = "Players form coalitions",
        next_id = "cooperative"
      )
    ),
    nodes = list(
      # --- Simultaneous ---
      list(
        id = "simultaneous",
        question = "Is information complete (all players know the payoff structure)?",
        options = list(
          list(label = "Yes", next_id = "sim_complete"),
          list(label = "No", next_id = "sim_incomplete")
        )
      ),
      list(
        id = "sim_complete",
        question = "Is the game zero-sum?",
        options = list(
          list(label = "Yes", next_id = "result_minimax"),
          list(label = "No", next_id = "sim_nonzero")
        )
      ),
      list(
        id = "result_minimax",
        result = "Zero-sum game — use the Minimax Theorem",
        tutorials = list("tutorials/foundations/zero-sum-minimax-theorem/")
      ),
      list(
        id = "sim_nonzero",
        question = "Is the game repeated?",
        options = list(
          list(label = "Yes", next_id = "sim_repeated"),
          list(label = "No — one-shot", next_id = "result_nash")
        )
      ),
      list(
        id = "result_nash",
        result = "Normal-form game — find Nash equilibrium (pure or mixed)",
        tutorials = list(
          "tutorials/foundations/nash-equilibrium-mixed/"
        )
      ),
      list(
        id = "sim_repeated",
        question = "Is the horizon finite or infinite?",
        options = list(
          list(label = "Finite", next_id = "result_finite_repeated"),
          list(label = "Infinite", next_id = "result_folk_theorem")
        )
      ),
      list(
        id = "result_finite_repeated",
        result = "Finite repeated game — use backward induction from the last stage",
        tutorials = list("tutorials/foundations/backward-induction-centipede/")
      ),
      list(
        id = "result_folk_theorem",
        result = "Infinite repeated game — investigate repeated-game incentive conditions",
        tutorials = list("tutorials/foundations/folk-theorem-perfect-monitoring/")
      ),
      list(
        id = "sim_incomplete",
        question = "Do players have private types/information?",
        options = list(
          list(label = "Yes", next_id = "result_bayesian"),
          list(label = "Partial/ambiguous", next_id = "result_robust")
        )
      ),
      list(
        id = "result_bayesian",
        result = "Bayesian game — find Bayesian Nash equilibrium",
        tutorials = list("tutorials/bayesian-methods/bayesian-games-incomplete-information/")
      ),
      list(
        id = "result_robust",
        result = "Consider robust mechanism design or global games",
        tutorials = list("tutorials/bayesian-methods/global-games-coordination/")
      ),
      # --- Sequential ---
      list(
        id = "sequential",
        question = "Is information perfect (each player observes all previous moves)?",
        options = list(
          list(label = "Yes", next_id = "result_backward_induction"),
          list(label = "No", next_id = "seq_imperfect")
        )
      ),
      list(
        id = "result_backward_induction",
        result = "Extensive-form game with perfect information — use backward induction / SPE",
        tutorials = list("tutorials/foundations/backward-induction-centipede/")
      ),
      list(
        id = "seq_imperfect",
        question = "Are there signaling or belief-updating aspects?",
        options = list(
          list(label = "Yes", next_id = "result_pbe"),
          list(label = "No", next_id = "result_spe")
        )
      ),
      list(
        id = "result_pbe",
        result = "Signaling game — find Perfect Bayesian Equilibrium or Sequential Equilibrium",
        tutorials = list("tutorials/foundations/signaling-games-pbe/")
      ),
      list(
        id = "result_spe",
        result = "Extensive-form game — find Subgame Perfect Equilibrium",
        tutorials = list("tutorials/foundations/extensive-form-subgame-perfection/")
      ),
      # --- Mechanism design ---
      list(
        id = "mechanism",
        question = "What is the designer's goal?",
        options = list(
          list(label = "Allocate goods/resources efficiently", next_id = "mech_allocation"),
          list(label = "Match agents to each other", next_id = "result_matching"),
          list(label = "Aggregate preferences (voting)", next_id = "result_voting")
        )
      ),
      list(
        id = "mech_allocation",
        question = "Can the designer use monetary transfers?",
        options = list(
          list(label = "Yes", next_id = "result_vcg"),
          list(label = "No", next_id = "result_no_money")
        )
      ),
      list(
        id = "result_vcg",
        result = "Use VCG mechanism or Myerson optimal auction",
        tutorials = list("tutorials/mechanism-design/")
      ),
      list(
        id = "result_no_money",
        result = "Mechanism design without money",
        tutorials = list("tutorials/ethics-and-game-theory/fair-division-cake-cutting/")
      ),
      list(
        id = "result_matching",
        result = "Two-sided matching — use Gale-Shapley or Top Trading Cycles",
        tutorials = list("tutorials/mechanism-design/")
      ),
      list(
        id = "result_voting",
        result = "Social choice / voting — consider Arrow's theorem and specific rules",
        tutorials = list("tutorials/mechanism-design/")
      ),
      # --- Cooperative ---
      list(
        id = "cooperative",
        question = "Are payoffs transferable between coalition members?",
        options = list(
          list(label = "Yes (TU game)", next_id = "result_shapley"),
          list(label = "No (NTU game)", next_id = "result_ntu")
        )
      ),
      list(
        id = "result_shapley",
        result = "TU cooperative game — compute Shapley value, core, nucleolus",
        tutorials = list("tutorials/cooperative-gt/")
      ),
      list(
        id = "result_ntu",
        result = "Bargaining problem — consider the Nash bargaining solution",
        tutorials = list("tutorials/foundations/nash-bargaining-solution/")
      )
    )
  )

  writeLines(
    jsonlite::toJSON(tree, auto_unbox = TRUE, pretty = TRUE),
    output_file
  )
  message("Decision tree written to ", output_file)
  invisible(tree)
}

if (sys.nframe() == 0) {
  build_decision_tree()
}
