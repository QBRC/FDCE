#setwd('/project/bioinformatics/Xiao_lab/lcai/Drug_Response/app/FDC/')
# Global Variables and libraries ---------------------------------------
source('session_prep.R')


ui <- navbarPage(title = "Functional Data Consistency Explorer",theme = shinytheme("simplex"),
                 tabPanel(title="Tutorials",
                          source(file.path("UI", "Tutorials_UI.R"),  local = TRUE)$value),
                 tabPanel(title="Overall Consistency",
                          source(file.path("UI", "Overall_UI.R"),  local = TRUE)$value),
                 tabPanel(title="Pairwise Scatterplots",
                          source(file.path("UI", "Individual_UI.R"),  local = TRUE)$value),
                 tabPanel(title = "Datasets",
                          source(file.path("UI", "Datasets_UI.R"),  local = TRUE)$value
                 ),
                 tags$style(type="text/css",
                            ".shiny-output-error { visibility: hidden; }",
                            ".shiny-output-error:before { visibility: hidden; }"
                 )
)
server <- function(input, output,session) {
  source(file.path("Server", "Tutorials_Server.R"),  local = TRUE)$value
  source(file.path("Server", "Overall_Server.R"),  local = TRUE)$value
  source(file.path("Server", "Individual_Server.R"),  local = TRUE)$value
  source(file.path("Server", "Datasets_Server.R"),  local = TRUE)$value
}

shinyApp(server = server, ui = ui)
