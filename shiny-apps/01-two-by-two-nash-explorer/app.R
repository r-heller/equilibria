# 2×2 Nash Equilibrium Explorer — Shiny App
# Part of #equilibria (https://r-heller.github.io/equilibria/)
# License: CC BY-SA 4.0

library(shiny)
library(ggplot2)
library(plotly)

# --- Okabe-Ito palette ---
okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7", "#999999")

# --- Nash equilibrium solver for 2x2 bimatrix games ---
solve_nash_2x2 <- function(A, B) {
  equilibria <- list()

  # Check all four pure strategy profiles
  pure_profiles <- list(c(1,1), c(1,2), c(2,1), c(2,2))
  for (profile in pure_profiles) {
    i <- profile[1]; j <- profile[2]
    # Row player: is i a best response to j?
    br_row <- A[1, j] >= A[2, j] && A[i, j] >= A[3 - i, j]
    # Col player: is j a best response to i?
    br_col <- B[i, 1] >= B[i, 2] && B[i, j] >= B[i, 3 - j]

    # More careful: check if i maximises A[., j] and j maximises B[i, .]
    br_row <- (A[i, j] >= A[3 - i, j])
    br_col <- (B[i, j] >= B[i, 3 - j])

    if (br_row && br_col) {
      equilibria <- c(equilibria, list(list(
        type = "Pure",
        p = ifelse(i == 1, 1, 0),
        q = ifelse(j == 1, 1, 0),
        row_payoff = A[i, j],
        col_payoff = B[i, j],
        label = paste0("(", c("T","B")[i], ", ", c("L","R")[j], ")")
      )))
    }
  }

  # Mixed strategy equilibrium
  # Row player mixes: col player must be indifferent
  # q * B[1,1] + (1-q) * B[1,2] = q * B[2,1] + (1-q) * B[2,2]
  # Col player mixes: row player must be indifferent
  # p * A[1,1] + (1-p) * A[2,1] = p * A[1,2] + (1-p) * A[2,2]

  denom_q <- (B[1,1] - B[1,2]) - (B[2,1] - B[2,2])
  denom_p <- (A[1,1] - A[2,1]) - (A[1,2] - A[2,2])

  if (abs(denom_q) > 1e-10 && abs(denom_p) > 1e-10) {
    q_star <- (B[2,2] - B[1,2]) / denom_q  # P(col plays L) to make row indifferent — wait
    # Actually: for ROW to be indifferent, COL must mix with prob q on L:
    # q*A[1,1] + (1-q)*A[1,2] = q*A[2,1] + (1-q)*A[2,2]
    # q*(A[1,1] - A[2,1]) + (1-q)*(A[1,2] - A[2,2]) = 0
    # q*(A[1,1] - A[2,1] - A[1,2] + A[2,2]) = A[2,2] - A[1,2]
    q_star <- (A[2,2] - A[1,2]) / denom_p

    # For COL to be indifferent, ROW must mix with prob p on T:
    # p*B[1,1] + (1-p)*B[2,1] = p*B[1,2] + (1-p)*B[2,2]
    # p*(B[1,1] - B[2,1] - B[1,2] + B[2,2]) = B[2,2] - B[2,1]
    p_star <- (B[2,2] - B[2,1]) / denom_q

    if (p_star > 0 && p_star < 1 && q_star > 0 && q_star < 1) {
      row_payoff <- p_star * (q_star * A[1,1] + (1 - q_star) * A[1,2]) +
                    (1 - p_star) * (q_star * A[2,1] + (1 - q_star) * A[2,2])
      col_payoff <- p_star * (q_star * B[1,1] + (1 - q_star) * B[1,2]) +
                    (1 - p_star) * (q_star * B[2,1] + (1 - q_star) * B[2,2])

      equilibria <- c(equilibria, list(list(
        type = "Mixed",
        p = round(p_star, 4),
        q = round(q_star, 4),
        row_payoff = round(row_payoff, 4),
        col_payoff = round(col_payoff, 4),
        label = sprintf("(%.3f, %.3f)", p_star, q_star)
      )))
    }
  }

  equilibria
}


# --- UI ---
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
    .payoff-input { width: 80px; display: inline-block; }
    .matrix-table td { padding: 8px 12px; text-align: center; }
    .matrix-table th { padding: 8px 12px; text-align: center; font-weight: bold; }
    .eq-card { background: #f8f9fa; border-left: 4px solid #0072B2;
               padding: 12px; margin: 8px 0; border-radius: 4px; }
    h2 { color: #0072B2; }
  "))),

  titlePanel("2×2 Nash Equilibrium Explorer"),
  p("Enter payoffs for a 2×2 bimatrix game and explore pure and mixed Nash equilibria."),

  fluidRow(
    column(4,
      h4("Payoff Matrix"),
      p("Format: (Row player, Column player)"),

      # Preset games
      selectInput("preset", "Load preset game:",
                  choices = c("Custom", "Prisoner's Dilemma", "Battle of the Sexes",
                              "Matching Pennies", "Stag Hunt", "Chicken/Hawk-Dove"),
                  selected = "Prisoner's Dilemma"),

      tags$table(class = "matrix-table",
        tags$tr(tags$th(""), tags$th("Left (L)"), tags$th("Right (R)")),
        tags$tr(
          tags$th("Top (T)"),
          tags$td(
            div(class = "payoff-input", numericInput("a11", "Row", 3, width = "70px")),
            div(class = "payoff-input", numericInput("b11", "Col", 3, width = "70px"))
          ),
          tags$td(
            div(class = "payoff-input", numericInput("a12", "Row", 0, width = "70px")),
            div(class = "payoff-input", numericInput("b12", "Col", 5, width = "70px"))
          )
        ),
        tags$tr(
          tags$th("Bottom (B)"),
          tags$td(
            div(class = "payoff-input", numericInput("a21", "Row", 5, width = "70px")),
            div(class = "payoff-input", numericInput("b21", "Col", 0, width = "70px"))
          ),
          tags$td(
            div(class = "payoff-input", numericInput("a22", "Row", 1, width = "70px")),
            div(class = "payoff-input", numericInput("b22", "Col", 1, width = "70px"))
          )
        )
      ),

      hr(),
      h4("Nash Equilibria"),
      uiOutput("equilibria_display")
    ),

    column(8,
      h4("Best Response Plot"),
      plotlyOutput("br_plot", height = "500px"),
      hr(),
      h4("Expected Payoff Surfaces"),
      fluidRow(
        column(6, plotlyOutput("row_payoff_plot", height = "350px")),
        column(6, plotlyOutput("col_payoff_plot", height = "350px"))
      )
    )
  ),

  hr(),
  p(style = "color: grey; font-size: 0.85em;",
    "Part of ", tags$a(href = "https://r-heller.github.io/equilibria/", "#equilibria"),
    " — Game Theory, Decision-Making & Strategic Interaction. ",
    "License: CC BY-SA 4.0.")
)


# --- Server ---
server <- function(input, output, session) {

  # Preset loader
  observeEvent(input$preset, {
    presets <- list(
      "Prisoner's Dilemma" = list(a11=3, b11=3, a12=0, b12=5, a21=5, b21=0, a22=1, b22=1),
      "Battle of the Sexes" = list(a11=3, b11=2, a12=0, b12=0, a21=0, b21=0, a22=2, b22=3),
      "Matching Pennies"    = list(a11=1, b11=-1, a12=-1, b12=1, a21=-1, b21=1, a22=1, b22=-1),
      "Stag Hunt"           = list(a11=4, b11=4, a12=0, b12=3, a21=3, b21=0, a22=3, b22=3),
      "Chicken/Hawk-Dove"   = list(a11=0, b11=0, a12=-1, b12=2, a21=2, b21=-1, a22=-5, b22=-5)
    )
    if (input$preset != "Custom") {
      vals <- presets[[input$preset]]
      for (nm in names(vals)) {
        updateNumericInput(session, nm, value = vals[[nm]])
      }
    }
  })

  # Reactive matrices
  matrices <- reactive({
    A <- matrix(c(input$a11, input$a21, input$a12, input$a22), nrow = 2)
    B <- matrix(c(input$b11, input$b21, input$b12, input$b22), nrow = 2)
    list(A = A, B = B)
  })

  # Compute equilibria
  eq_results <- reactive({
    m <- matrices()
    solve_nash_2x2(m$A, m$B)
  })

  # Display equilibria
  output$equilibria_display <- renderUI({
    eqs <- eq_results()
    if (length(eqs) == 0) {
      return(div(class = "eq-card", "No equilibria found (check payoffs)."))
    }
    cards <- lapply(eqs, function(eq) {
      div(class = "eq-card",
        tags$b(paste0(eq$type, " NE: ", eq$label)),
        br(),
        sprintf("p(Top) = %.3f, q(Left) = %.3f", eq$p, eq$q),
        br(),
        sprintf("Payoffs: Row = %.3f, Col = %.3f", eq$row_payoff, eq$col_payoff)
      )
    })
    do.call(tagList, cards)
  })

  # Best response plot
  output$br_plot <- renderPlotly({
    m <- matrices()
    A <- m$A; B <- m$B
    eqs <- eq_results()

    q_seq <- seq(0, 1, length.out = 200)
    p_seq <- seq(0, 1, length.out = 200)

    # Row player's best response: for each q, which p maximises expected payoff?
    # E_row(p, q) = p*(q*A[1,1] + (1-q)*A[1,2]) + (1-p)*(q*A[2,1] + (1-q)*A[2,2])
    # = p*(q*(A[1,1]-A[2,1]) + (1-q)*(A[1,2]-A[2,2])) + q*A[2,1] + (1-q)*A[2,2]
    # BR_row(q) = 1 if coeff > 0, 0 if coeff < 0, [0,1] if coeff = 0

    row_br_data <- lapply(q_seq, function(q) {
      coeff <- q * (A[1,1] - A[2,1]) + (1 - q) * (A[1,2] - A[2,2])
      if (abs(coeff) < 1e-10) {
        data.frame(q = c(q, q), p_br = c(0, 1), player = "Row BR")
      } else if (coeff > 0) {
        data.frame(q = q, p_br = 1, player = "Row BR")
      } else {
        data.frame(q = q, p_br = 0, player = "Row BR")
      }
    }) |> do.call(rbind, args = _)

    # Column player's best response: for each p, which q maximises expected payoff?
    col_br_data <- lapply(p_seq, function(p) {
      coeff <- p * (B[1,1] - B[1,2]) + (1 - p) * (B[2,1] - B[2,2])
      if (abs(coeff) < 1e-10) {
        data.frame(q_br = c(0, 1), p = c(p, p), player = "Col BR")
      } else if (coeff > 0) {
        data.frame(q_br = 1, p = p, player = "Col BR")
      } else {
        data.frame(q_br = 0, p = p, player = "Col BR")
      }
    }) |> do.call(rbind, args = _)

    # Plot
    p_plot <- ggplot() +
      geom_path(data = row_br_data, aes(x = q, y = p_br),
                color = okabe_ito[5], linewidth = 1.5, alpha = 0.8) +
      geom_path(data = col_br_data, aes(x = q_br, y = p),
                color = okabe_ito[6], linewidth = 1.5, alpha = 0.8) +
      labs(x = "q = P(Column plays Left)", y = "p = P(Row plays Top)",
           title = "Best Response Correspondences") +
      xlim(0, 1) + ylim(0, 1) +
      theme_minimal(base_size = 12) +
      theme(panel.grid.minor = element_blank())

    # Add equilibrium points
    if (length(eqs) > 0) {
      eq_df <- do.call(rbind, lapply(eqs, function(e) {
        data.frame(q = e$q, p = e$p, label = e$label)
      }))
      p_plot <- p_plot +
        geom_point(data = eq_df, aes(x = q, y = p, text = label),
                   color = okabe_ito[3], size = 5, shape = 18)
    }

    ggplotly(p_plot, tooltip = "text") |>
      config(displaylogo = FALSE,
             modeBarButtonsToRemove = c("select2d", "lasso2d"))
  })

  # Row player expected payoff surface
  output$row_payoff_plot <- renderPlotly({
    m <- matrices()
    A <- m$A
    grid <- expand.grid(p = seq(0, 1, by = 0.02), q = seq(0, 1, by = 0.02))
    grid$payoff <- with(grid,
      p * (q * A[1,1] + (1-q) * A[1,2]) + (1-p) * (q * A[2,1] + (1-q) * A[2,2])
    )

    plot_ly(grid, x = ~q, y = ~p, z = ~payoff, type = "contour",
            colorscale = list(c(0, okabe_ito[6]), c(1, okabe_ito[3])),
            contours = list(showlabels = TRUE)) |>
      layout(title = "Row player expected payoff",
             xaxis = list(title = "q (P Col plays L)"),
             yaxis = list(title = "p (P Row plays T)")) |>
      config(displaylogo = FALSE)
  })

  # Col player expected payoff surface
  output$col_payoff_plot <- renderPlotly({
    m <- matrices()
    B <- m$B
    grid <- expand.grid(p = seq(0, 1, by = 0.02), q = seq(0, 1, by = 0.02))
    grid$payoff <- with(grid,
      p * (q * B[1,1] + (1-q) * B[1,2]) + (1-p) * (q * B[2,1] + (1-q) * B[2,2])
    )

    plot_ly(grid, x = ~q, y = ~p, z = ~payoff, type = "contour",
            colorscale = list(c(0, okabe_ito[6]), c(1, okabe_ito[3])),
            contours = list(showlabels = TRUE)) |>
      layout(title = "Column player expected payoff",
             xaxis = list(title = "q (P Col plays L)"),
             yaxis = list(title = "p (P Row plays T)")) |>
      config(displaylogo = FALSE)
  })
}

shinyApp(ui = ui, server = server)
