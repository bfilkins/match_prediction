
# Packages ####
source("R/environment/packages.R")
source_python("Python/environment/packages.py")

# Global ####
source("R/environment/globals.R")

# Theme ####
source("R/environment/theme.R")

# Load Data #### (break out load and query)
#source_python("Python/query/matches_api_query.py")
source("R/match_prediction/load_transform_match_data.R")
source("R/football_api/query_match_statistics.R")
source("R/match_prediction/prior_match_feature_engineering.R")


# Create App to Model Match Prediction ####
# Define UI for app ####

ui = shinyUI(
  fluidPage(
    #useShinyjs(),
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
              source("R/match_prediction/match_prediction_sidebar.R", local = TRUE)$value,
              
              tagList(
                PrimaryButton.shinyInput("showModal", text = "Show fuck", style = "background: grey; border: white"),
                reactOutput("modal")
              )
              
              )),
          mainPanel(
            width = 9,
            titlePanel(h1("Model Performance", align = "center")), 
            h4("ROC Curves and Model Performance Metrics", align = "center"), 
            column(width = 12,
            fluidRow(
              column(8,
            plotOutput(
              outputId = "roc_curve"
                ),
            
            tagList(
              PrimaryButton.shinyInput("show_explain_roc", text = "definitions", style = "background: grey; border: white; align-text: center;"),
              reactOutput("explain_roc")
              
            )),
            column(4,
                   style = "align-text: ceneter",
            DT::dataTableOutput(
              outputId = "performance_plot")
            )))
          )))
          )
        )
      )

  

thematic_shiny()

# Define Server
server <- function(input, output, session) {
  source("R/match_prediction/match_prediction_server.R", local = TRUE)$value
  }
# Create Shiny app ----
runGadget(ui, server, viewer = dialogViewer("Dialog Title", width = 1600, height = 1000))




