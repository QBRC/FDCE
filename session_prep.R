# libraries
library(slickR)
library(meta)
library(shiny)
library(ggplot2)
library(GGally)
library(mclust)
library(patchwork)
library(tidyr)
library(openxlsx)
library(DT)
library(openxlsx)
library(RColorBrewer)
library(shinyjs)
library(Cairo)
library(data.table)
library(dplyr)
library(shinycssloaders)
library(plotly)
library(shinyTree)
library(shinythemes)
library(shinydashboardPlus)
library(grid)
# common settings
options(shiny.usecairo=T)
options(stringsAsFactors = F)
# setwd('/project/DPDS//Xiao_lab/lcai/Drug_Response/app/FDC/')
load('data/input.RData')
# merge drug.summary
drug.summary<-data.table(direct.drug.summary[,1:2,with=F],drug.ref[match(direct.drug.summary$PubChemID,PubChemID),-c(1:2),with=F],
                         setNames(as.data.frame(direct.drug.summary[,c('r','pv','pairs')]),paste(c('r','pv','pairs'),'(direct)')),
                         setNames(as.data.frame(indirect.drug.summary[,c('r','pv','pairs')]),paste(c('r','pv','pairs'),'(indirect)')),
                         `datasets (direct(/indirect))`=ifelse(direct.drug.summary$datasets==indirect.drug.summary$datasets,direct.drug.summary$datasets,paste(direct.drug.summary$datasets,indirect.drug.summary$datasets,sep = '/')),
                         `meta analysis (direct(/indirect))`=ifelse(direct.drug.summary$meta_analysis==indirect.drug.summary$meta_analysis,direct.drug.summary$meta_analysis,paste(direct.drug.summary$meta_analysis,indirect.drug.summary$meta_analysis,sep = '/')))
dependency.summary<-data.table(direct.dependency.summary[,1,with=F],
                         setNames(as.data.frame(direct.dependency.summary[,c('r','pv')]),paste(c('r','pv'),'(direct)')),
                         setNames(as.data.frame(indirect.dependency.summary[,c('r','pv')]),paste(c('r','pv'),'(indirect)')),
                         direct.dependency.summary[,4:6,with=F])


gg.summary.list<-list(drug=g.summary.drug,dependency=g.summary.dependency)