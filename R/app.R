
# Packages ####
source("R/environment/packages.R")
#source_python("Python/environment/packages.py")

# Global ####
source("R/environment/globals.R")

# Theme ####
source("R/environment/theme.R")

# Load Data ####
#source_python("Python/query/matches_api_query.py")
source("R/match_prediction/load_transform_match_data.R")

# Create App to Model Match Prediction ####
# Define UI for app ####

ui = shinyUI(
  fluidPage(
    useShinyjs(),
    tags$head(
      tags$style(
        source("R/environment/html.R", local = TRUE)$value)
      ),
    theme = my_theme,
    navbarPage(
      "football:",
      tabPanel(
        "match",
        fluid = TRUE,
        sidebarLayout(
          sidebarPanel(
            div(
              id = "match_prediction_sidebar",
              tags$tbody("Analysis Parameters"),
              source("R/match_prediction/match_prediction_sidebar.R", local = TRUE)$value,
              tagList(
                PrimaryButton.shinyInput("showModal", text = "Show fuck", style = "background: grey; border: white"),
                reactOutput("modal")
              )
              )
            ),
          mainPanel(
            titlePanel(h1("Model Performance", align = "center")), 
            h4("ROC Curves and Model Performance Metrics", align = "center"), 
            column(width = 12,
            fluidRow(
              column(8,
            plotOutput(
              outputId = "roc_curve",
              width = "100%"
                )),
            column(4,
            DT::dataTableOutput(
              outputId = "performance_plot")
            ))))
          )
        )
      )
    )
  )

thematic_shiny()

# Define Server
server <- function(input, output, session) {
  source("R/match_prediction/match_prediction_server.R", local = TRUE)$value
  }
# Create Shiny app ----
shinyApp(ui = ui, server = server)




