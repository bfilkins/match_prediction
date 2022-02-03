
# Packages ####
source("R/environment/packages.R")
source_python("Python/environment/packages.py")

# Global ####
source("R/environment/globals.R")

# Theme ####
source("R/environment/theme.R")

# Load Data ####
source_python("Python/query/matches_api_query.py")
source("R/match_prediction/load_transform_match_data.R")

# Model Match Prediction ####

#source("R/match_analysis.R")

# Define UI for app #### Need to refactor UI
ui = shinyUI(
  fluidPage(
    useShinyjs(),
    tags$head(tags$style(source("R/environment/html.R", local = TRUE)$value)),
    theme = my_theme,
    navbarPage(
      "football:", 
      tabPanel(
        "Match Prediction",
        fluid = TRUE,
        sidebarLayout(
          div(
            id = "match_prediction_sidebar", 
            source("R/match_prediction/match_prediction_sidebar.R", local = TRUE)$value
            ),
          source("R/match_prediction/match_prediction_tab.R", local = TRUE)$value
        ),
        actionButton("match_prediction_sidebar_button","", icon = icon("bars"),
                     style = "position: absolute; right: 20px; top: 3px"
                     ),
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  source("R/match_prediction/match_prediction_server.R", local = TRUE)$value
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)




