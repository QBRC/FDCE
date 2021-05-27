fluidPage(
  radioButtons(inline = T,'tutorial-choose',label = "Functionality:",
               choices = c("Overall Consistency"="1","Pairwise Scatterplots"="2","Datasets"="3")),
  fluidRow(column(1),column(10,shinycssloaders::withSpinner(slickROutput("tutorial-slickr"))),column(1)))