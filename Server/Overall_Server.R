shinyjs::hide('overall-TablePwVars')
output$`overall-DensitySummary`<-renderPlot(gg.summary.dens.raw()/gg.pw.dens.raw()+plot_layout(heights = c(1,ifelse(input$`overall-type`=='drug',3,1))),height = 750)
output$`overall-TableSummary`<-renderDataTable(DT::datatable(drug.summary[,input$`overall-TableVars`,with=F],rownames = F,options=list(pageLength=20),caption = htmltools::tags$caption( style = 'caption-side: top; text-align: center; color:black;font-size:150%;',paste('Overall consistency of', input$`overall-type`,'screening data'))))

chosen.summary<-reactive({
  switch(match(input$`overall-type`,c('drug','dependency')),drug.summary,dependency.summary)
})

gg.summary.dens.raw<-reactive({
  switch(match(input$`overall-type`,c('drug','dependency')),g.summary.drug,g.summary.dependency)
})
translate.feature<-reactive({
  req(input$`overall-type`)
  ifelse(input$`overall-type`=='drug',drug.ref[match(input$`overall-SelectFeature`,PubChemID)][['without_tail']],input$`overall-SelectFeature`)
})
gg.summary.dens<-reactive({
  p.ref<-setDT(ggplot_build(gg.summary.dens.raw())$data[[1]])
  feature.summary.df<-rbind(p.ref[group==1][which.min(abs(p.ref[group==1][['x']]-chosen.summary()[chosen.summary()[[1]]==translate.feature()][['r (direct)']]))],
                            p.ref[group==2][which.min(abs(p.ref[group==2][['x']]-chosen.summary()[chosen.summary()[[1]]==translate.feature()][['r (indirect)']]))])
  gg.summary.dens.raw()+
    geom_point(feature.summary.df,mapping=aes(x = x,y=y),alpha=0.4,color=brewer.pal(6,'Accent')[6])+
    geom_point(mapping=aes(x=-1,y=0.95),alpha=0.4,color=brewer.pal(6,'Accent')[6])+
    geom_label(mapping=aes(x=-1,y=0.95),alpha=0.4,label=translate.feature(),hjust=-0.2)
})



gg.pw.dens.raw<-reactive({
  switch(match(input$`overall-type`,c('drug','dependency')),g.pw.drug,g.pw.dependency)
})
pairwise.df<-reactive({
  switch(match(input$`overall-type`,c('drug','dependency')),drug.pairwise,dependency.pairwise)
})
pw.cor.sub<-reactive({
  pairwise.df()[pairwise.df()[[4]]==input$`overall-SelectFeature`]
})
gg.pw.dens<-reactive({
  p.ref<-setDT(ggplot_build(gg.pw.dens.raw())$data[[1]])
  p.ref<-setDT(merge(p.ref,switch(match(input$`overall-type`,c('drug','dependency')),drug.ind.ref,dependency.ind.ref),by.x='PANEL',by.y='value'))
  find.dens<-function(pw.cor.sub,p.ref){
    data.table(pw.cor.sub,do.call(rbind,lapply(1:nrow(pw.cor.sub), FUN=function(i){
      p.ref[group==ifelse(pw.cor.sub[['assessment']][i]=='direct',1,2)][dat1==pw.cor.sub[['dat1']][i]&dat2==pw.cor.sub[['dat2']][i]][which.min(abs(x-pw.cor.sub[['r']][i]))][,c('x','y'),with=F]
    })))
  }
  gg.pw.dens.raw()+
    geom_point(find.dens(pw.cor.sub(),p.ref = p.ref),mapping = aes(x=x,y=y),color=brewer.pal(6,'Accent')[6])
})
pw.cor.sub2<-reactive({
  pw.cor.sub<-pw.cor.sub()[assessment==input$`overall-metaOption`][!is.na(r)][is.finite(r)][n.cell>=10]
  pw.cor.sub[,z:=sqrt(n.cell-3)*log((1+r)/(1-r)),]
  pw.cor.sub[pw.cor.sub[,.I[z==max(z)],by=.(dat1,dat2)]$V1]
})
pw.forest<-reactive({
  sub.meta<-with(pw.cor.sub2(),metacor(cor = r,n = n.cell, studlab = paste(dat1,dat2,sep = ' vs. ')))
  forest(sub.meta,comb.fixed = F,col.square = scales::alpha('black',0.3),col.diamond.random = 'black')
  grid.text(paste(translate.feature(),input$`overall-metaOption`,"pairwise correlation summary"), .5, .94, gp=gpar(cex=1.8))
})

observeEvent(input$`overall-type`,{
  output$`overall-TablePairwise`<-NULL
  output$`overall-Forest`<-NULL
  shinyjs::hide('overall-TablePwVars')
  updateSelectizeInput(session,'overall-SelectFeature',server = T,
                       choices = switch(match(input$`overall-type`,c('drug','dependency')),structure(drug.ref$PubChemID,names=drug.ref$without_tail),dependency.summary$gene))
  output$`overall-DensitySummary`<-renderPlot(gg.summary.dens.raw()/gg.pw.dens.raw()+plot_layout(heights = c(1,ifelse(input$`overall-type`=='drug',3,1))),height = 750)
  updateCheckboxGroupInput(session,'overall-TableVars',choices = colnames(chosen.summary()),
                           selected=switch(match(input$`overall-type`,c('drug','dependency')),c('compound','PubChemID','r (direct)','pv (direct)','pairs (direct)','datasets (direct(/indirect))'),c('gene','r (direct)','pv (direct)',"datasets")))
  updateCheckboxGroupInput(session,'overall-TablePwVars',choices=colnames(pw.cor.sub()),selected=c('assessment','dat1','dat2','r','pv','n.cell','n.feature'))
  output$`overall-TableSummary`<-renderDataTable(DT::datatable(chosen.summary()[,input$`overall-TableVars`,with=F],rownames = F,options=list(pageLength=20),caption = htmltools::tags$caption( style = 'caption-side: top; text-align: left; color:black;font-size:150%;',paste('Overall consistency of', input$`overall-type`,'screening data'))))
})
output$`overall-download`<-downloadHandler(
  filename = function() {paste0(input$`overall-type`,'_data_consistency_summary.csv')},
  content = function(file) write.csv(chosen.summary(), file)
)
observeEvent(input$`overall-submit`,{
  output$`overall-DensitySummary`<-renderPlot(isolate(gg.summary.dens()/gg.pw.dens())+plot_layout(heights = c(1,ifelse(input$`overall-type`=='drug',3,1))),height = 750)
  output$`overall-TablePairwise`<-renderDataTable(DT::datatable(isolate(pw.cor.sub())[,input$`overall-TablePwVars`,with=F],rownames = F,options=list(pageLength=5),filter = 'top',
                                                                caption = htmltools::tags$caption(style = 'caption-side: top; text-align: left; color:black;font-size:150%;',paste('Pairwise consistency of', isolate(translate.feature()),'data'))))
  shinyjs::show('overall-TablePwVars')
  if(nrow(isolate(pw.cor.sub2()))>1){
    output$`overall-Forest`<-renderPlot(isolate(pw.forest()),height = 600)
    output$`overall-NoForest`<-NULL
  }else{
    output$`overall-Forest`<-NULL
    output$`overall-NoForest`<-renderText('    Forest plot not generated due to insufficent number of pairs for meta-analysis')
  }
})
