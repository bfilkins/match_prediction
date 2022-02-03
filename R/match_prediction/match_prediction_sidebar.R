

sidebarPanel(
  width = 200,
  # fluidRow(
  #   div(style = "width: 50%", actionButton("toggle_filter", "", icon = icon("filter"))),
  #   div(style = "width: 50%", actionButton("toggle_parameters", "", icon = icon("flask"))),
  #   width = '100%'
  # ),
  div(
    id = "match_prediction_sidebar",
    tags$tbody("Analysis Parameters"),
    fluidRow(
      div(
        style="display: inline-block;vertical-align:top; width: 100%;",
        sliderInput(
          inputId = "game_lag",
          label = "Prior Games",
          value =  12,
          min = 1,
          max = 20,
          step = 1,
          animate = animationOptions(interval = 150, loop = TRUE)
        ),
        sliderInput(
          inputId = "n_trail",
          label = "Trail",
          value =  20,
          min = 10,
          max = 100,
        )
      )
    )
  )
)
