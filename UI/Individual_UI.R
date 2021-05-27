fluidPage(
  radioButtons(inputId = 'scatter-type',label = "Data Type",choices = structure(c('drug','dependency'),names=c('Compound Screening','Gene Dependency Screening')),inline = T,selected = 'drug'),
  fluidRow(column(3,selectizeInput(inputId = 'scatter-SelectFeature',label="Choose feature to show",choices=structure(drug.ref$PubChemID,names=drug.ref$without_tail))),column(3,br(),actionButton('scatter-submit',label = 'Submit')),column(6)),
  # uiOutput('scatter-colors'),
  shinycssloaders::withSpinner(plotlyOutput(outputId = 'scatter-plot',height = 1000))
)