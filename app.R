
renv::restore()
# Load packages ####
source("R/environment/packages.R")
#source_python("Python/environment/packages.py")

# Define aws connections
source("R/environment/aws_connect.R")

# Define global vars and functions ####
source("R/environment/globals.R")

# Define theme for shiny app ####
source("R/environment/theme.R")

# Load aws data
source("R/environment/load_aws_data.R")


# Query and Save Data ####
#(this will all be modified when it points at AWS)
# source("R/environment/define_query_functions.R")
# source_python("Python/environment/define_query_functions.py")
# source("R/environment/query_fixtures_and_statistics.R")

# Load data #### (loads local data)
#source("R/match_prediction/load_transform_match_data.R")

# non-app server script for development (move all this into server)
#source("R/match_prediction/prior_match_feature_engineering.R")

# Create app to explore modeling match outcome predictions using prior match data ####

# Define ui for app

ui = shinyUI(
  fluidPage(
    tags$head(
      tags$style(
        source("R/environment/html.R", local = TRUE)$value)
      ),
    theme = my_theme,
    navbarPage(
      "pitch prophet:",
      tabPanel(
        "Team Stats",
        fluidRow( 
          style = "padding: 10px",
          column( 6, div(htmlOutput("logo_home_team", style = "text-align: center; display: block; margin-left: auto; margin-right: auto; padding: 15px;"))),
          column( 6, div(htmlOutput("logo_away_team", style = "text-align: center; display: block; margin-left: auto; margin-right: auto; padding: 15px;")))
        )),
      tabPanel(
        "match outcome prediction",
        fluid = TRUE,
        sidebarLayout(
          sidebarPanel(
            width = 3,
            div(
              id = "match_prediction_sidebar",
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
                        choices = c("logistic regression","trees"),
                        multiple = TRUE
                      ),
                      tagList(
                        PrimaryButton.shinyInput("showModal", text = "Show modal", style = "background: grey; border: white"),
                        reactOutput("modal")
                      )
                    )
                  )
                )
              )
              )
            ),
          mainPanel(
            width = 9,
            titlePanel(h1("Model Performance", align = "center")), 
            h4("ROC Curves and Model Performance Metrics", align = "center"), 
            column(width = 12,
            fluidRow(
              column(8,
            plotOutput(outputId = "roc_curve"),
            tagList(
              PrimaryButton.shinyInput("show_explain_roc", text = "definitions", style = "background: grey; border: white; align-text: center;"),
              reactOutput("explain_roc")
            )),
            reactableOutput(outputId = "performance_plot")
            )
            )
          )
          )
        )
      )
    )
  )

  

#thematic_shiny()

# Define server
server <- function(input, output, session) {
  source("R/match_prediction/server.R", local = TRUE)$value
  }

# Create shiny app ----
runApp(list(ui = ui, server = server),host="127.0.0.1",port=5013, launch.browser = TRUE)



