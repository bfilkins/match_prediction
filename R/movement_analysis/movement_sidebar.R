

sidebarPanel(
  width = 200,
  # fluidRow(
  #   div(style = "width: 50%", actionButton("toggle_filter", "", icon = icon("filter"))),
  #   div(style = "width: 50%", actionButton("toggle_parameters", "", icon = icon("flask"))),
  #   width = '100%'
  # ),
  div(
    id = "movement_sidebar",
    tags$tbody("Analysis Parameters"),
    fluidRow(
      div(
        style="display: inline-block;vertical-align:top; width: 100%;",
        sliderInput(
          inputId = "match_time",
          label = "Match Time",
          value =  3670,
          min = 5000,
          max = max_frame,
          step = 10,
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
