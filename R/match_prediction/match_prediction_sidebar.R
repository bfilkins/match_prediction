

div(
  width = 200,
  div(
    tags$h4("Analysis Parameters", align = "ceneter"),
    fluidRow(
      div(
        style="display: inline-block; vertical-align:top; width: 100%;",
        sliderInput(
          inputId = "game_lag",
          label = "Prior Games",
          value =  12,
          min = 1,
          max = 20,
          step = 1,
          animate = animationOptions(interval = 150, loop = TRUE)),
          selectizeInput(
            inputId = "models_selected",
            label = "Prior Games",
            choices = c("logistic regression","trees")
           )
        )
      )
    )
  )



