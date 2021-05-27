fluidPage(
  radioButtons('data-type',choices = c('Preview data'='view','Download data'='download'),label = "Preview or Download",inline = T),
  sidebarLayout(
    sidebarPanel(width = 2,shinyTree('data-viewTree',multiple = F,checkbox = F, theme="proton", themeIcons = FALSE, themeDots = FALSE),
                 shinyTree('data-downloadTree',multiple = T,checkbox = T, theme="proton", themeIcons = FALSE, themeDots = FALSE),
                 useShinyjs(),actionButton('data-submit','Preview'),actionButton('data-prepButton', label="Prepare for download"),downloadButton(outputId = 'data-download', label="Download"),div(textOutput('data-check'))),
    mainPanel(width = 10,verbatimTextOutput('data-chosen'),shinycssloaders::withSpinner(dataTableOutput('data-table')))
  )
)