# Packages ####
source("R/environment/packages.R")
source_python("Python/environment/packages.py")

# Global ####
source("R/environment/globals.R")

# Theme ####
source("R/environment/theme.R")

# Load Data ####
source_python("Python/query/matches_api_query.py")
#source("R/environment/load_data.R")

# Model Goal Position ####
#source("R/movement_analysis/predicting_goalie_position.R")

# Define UI for app ####
ui = shinyUI(
  fluidPage(
    useShinyjs(),
    tags$head(tags$style(source("R/environment/html.R", local = TRUE)$value)),
    theme = my_theme,
    navbarPage(
      "football:", 
      tabPanel(
        "movement tracking",
        fluid = TRUE,
        sidebarLayout(
          div(
            id = "movement_sidebar", 
            source("R/movement_analysis/movement_sidebar.R", local = TRUE)$value
            ),
          source("R/movement_analysis/movement_tab.R", local = TRUE)$value
        ),
        actionButton("movement_sidebar_button","", icon = icon("bars"),
                     style = "position: absolute; right: 20px; top: 3px"
                     ),
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  source("R/movement_analysis/movement_server.R", local = TRUE)$value
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)




