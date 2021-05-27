fluidPage(
  column(5,
         radioButtons(inputId = 'overall-type',label = "Data type",choices = structure(c('drug','dependency'),names=c('Compound Screening','Gene Dependency Screening')),inline = T,selected = 'drug'),
         fluidRow(column(4,selectizeInput(inputId = 'overall-SelectFeature',label="Choose feature to highlight",choices=structure(drug.ref$PubChemID,names=drug.ref$without_tail))),
                  column(5,radioButtons('overall-metaOption','Correlation input for forest plot',choices = c('Direct'='direct','Indirect'='indirect'),inline = T)),
                  column(3,br(),actionButton('overall-submit',label = 'Submit'))),
         shinycssloaders::withSpinner(plotOutput(outputId = 'overall-DensitySummary',height = "750px")),textOutput('overall-NoForest'),plotOutput('overall-Forest')
  ),
  column(7,
         fluidRow(
           column(3,
                  br(),br(),br(),
                  checkboxGroupInput('overall-TableVars', 'Columns to show:', colnames(drug.summary),
                                     selected = c('compound','PubChemID','r (direct)','pv (direct)','pairs (direct)','datasets (direct(/indirect))')),
                  downloadButton('overall-download',label = 'Download Table')
           ),
           column(9,
                  shinycssloaders::withSpinner(dataTableOutput(outputId = 'overall-TableSummary'))
           )
         ),
         fluidRow(
           column(3,
                  br(),br(),br(),br(),
                  useShinyjs(),
                  checkboxGroupInput('overall-TablePwVars', 'Columns to show:', choices =c('assessment','dat1','dat2','r','pv','n.cell','n.feature'), selected=c('assessment','dat1','dat2','r','pv','n.cell','n.feature'))
           ),
           column(9,
                  br(),
                  dataTableOutput(outputId = 'overall-TablePairwise'))
         )
  )
)