mainPanel(
  verticalLayout(
    tabPanel(
      "Match Prediction",
      fluidRow(
        column(
          width = 10,
          plotlyOutput(outputId = "roc_curve", height = 200)
          )
        )
      )
    )
  )
