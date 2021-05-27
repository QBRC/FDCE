shinyjs::hide('data-download')
shinyjs::hide('data-prepButton')
output$`data-downloadTree`<-renderTree(data_size.tree)
output$`data-viewTree`<-renderTree(data.tree)
beautify.df<-function(x){
  x[ ,which(sapply(x,is.numeric))]<-round(x[ ,which(sapply(x,is.numeric)), with=FALSE],3)
  x
}
output$`data-table`<-renderDataTable(DT::datatable(data.overview,rownames = F,options = list(pageLength=5),caption = htmltools::tags$caption( style = 'caption-side: top; text-align: center; color:black;font-size:150%;',"Overview of all datasets")))
observeEvent(input$`data-type`,{
  output$`data-check`<-NULL
  if(input$`data-type`=='download'){
    shinyjs::hide('data-submit');shinyjs::show('data-prepButton')
    shinyjs::show('data-downloadTree');shinyjs::hide('data-viewTree')
    output$`data-table`<-renderDataTable(DT::datatable(data.overview,rownames = F,options = list(pageLength=5),caption = htmltools::tags$caption( style = 'caption-side: top; text-align: center; color:black;font-size:150%;',"Overview of all datasets")))
  }else{
    shinyjs::hide('data-prepButton');shinyjs::hide('data-download');shinyjs::show('data-submit')
    shinyjs::show('data-viewTree');shinyjs::hide('data-downloadTree')
  }
})
download.targets<-reactive({sapply(grep("data|annotation",names(unlist(get_selected(input$`data-downloadTree`, format = "slices"))),value=T),FUN=function(x) unlist(strsplit(x,split = ' (',fixed = T))[1])})
download.sizes<-reactive({
  file.size<-sapply(grep("data|annotation",names(unlist(get_selected(input$`data-downloadTree`, format = "slices"))),value=T),FUN=function(x) unlist(strsplit(x,split = ' (',fixed = T))[2])
  file.size<-gsub(')','',file.size)
  file.size<-sapply(file.size,FUN=function(x) as.numeric(gsub("K|M","",x))*ifelse(grepl("M",x),1000,1))
  cumsum(file.size)
})
download.files<-reactive({paste0('data/',gsub('.annotation','.annot.rds',gsub('.data','.rds',gsub('.','-',download.targets(),fixed = T))))})
view.target<-reactive({grep("data|annotation",names(unlist(get_selected(input$`data-viewTree`, format = "slices"))),value=T)})
view.file<-reactive({paste0('data/',gsub('.annotation','.annot.rds',gsub('.data','.rds',gsub('.','-',view.target(),fixed = T))))})

observeEvent(input$`data-downloadTree`,{
  output$`data-check`<-NULL
  shinyjs::show('data-prepButton')
  shinyjs::hide('data-download')
})
observeEvent(input$`data-viewTree`,{
  output$`data-check`<-NULL
})
observeEvent(input$`data-prepButton`, {
  if(length(download.targets())>0){
    shinyjs::html("data-check", "")
    dat.list<-lapply(download.files(),readRDS)
    old.wd<-getwd()
    setwd(tempdir())
    unlink("*.zip")
    lapply(1:length(download.files()),FUN=function(i){
      fwrite(dat.list[[i]],paste0(download.targets()[i],'.csv'))
    })
    withProgress(session, min = 0, max = rev(download.sizes())[1], {
      setProgress(message = 'Packing files')
      first.item<-T
      for(i in 1:length(download.targets())){
        setProgress(value = c(0,download.sizes())[i])
        csf.f<-paste0(download.targets(),'.csv')[i]
        if(first.item){
          msg<-system(paste("zip download.zip",csf.f));first.item<-F
        }else{
          msg<-paste(msg,system(paste("zip -u download.zip",csf.f)),sep = "\n")
        }
      }

    })
    unlink("*.csv")
    setwd(old.wd)
    shinyjs::hide('data-prepButton')
    shinyjs::show('data-download')
  }else{
    output$`data-check`<-renderText("Please select something.")
  }
})


output$`data-download` <- downloadHandler(
  filename = function(){
    'download.zip'
  },
  content = function(file){file.copy(paste0(tempdir(),"/download.zip"), file)}, 
  contentType = "application/zip"
)

observeEvent(input$`data-submit`,{
  if(length(view.target())==0){
    output$`data-check`<-renderText("Please select one data or annotation")
  }else{
    output$`data-table`<-renderDataTable(isolate({
      view.dat<-readRDS(view.file()); if(ncol(view.dat)>50) view.dat<-view.dat[,1:50,with=F]
      DT::datatable(beautify.df(view.dat),rownames = F,options = list(pageLength=5),caption = htmltools::tags$caption( style = 'caption-side: top; text-align: center; color:black;font-size:150%;',paste("Preview of",view.target(),"(show up to 50 columns)")))
    }))
  }
})

# need to beautify dataset and fix download issue