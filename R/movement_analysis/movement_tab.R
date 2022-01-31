mainPanel(
  verticalLayout(
      tabPanel(
        "Position Analysis",
        fluidRow(
            column(
              width = 10, 
              plotlyOutput(outputId = "ball_x_density_plot", height = 200)
              )
            ),
        fluidRow(
          column(
            width = 10,
            plotlyOutput(outputId = "movement_plot")
          ), 
        column( 
          width = 2,
          plotlyOutput(outputId = "ball_y_density_plot", width = 200)
          )
        )
      )
    )
  )
