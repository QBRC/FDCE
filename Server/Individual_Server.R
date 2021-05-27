output$`scatter-plot`<-NULL

get.drug.df<-function(drug.cid){ 
  sub.drug.list<-lapply(names(drug.annot.list),function(s){
    cid.ind<-which(drug.annot.list[[s]][['PubChemID']]==drug.cid)
    if(length(cid.ind)>0) drug.list[[s]][,c(1,cid.ind+1),with=F]
  })
  sub.drug.list<-structure(sub.drug.list,names=names(drug.annot.list))[which(!unlist(lapply(sub.drug.list,is.null)))]
  all.cells<-unique(unlist(lapply(sub.drug.list,FUN=function(x) x[[1]])))
  all.cells<-data.table(cell_line=all.cells)%>%separate(cell_line,into=c(NA,'lineage'),sep='_',remove=F,extra = 'merge')
  df<-data.table(all.cells,do.call(cbind,lapply(names(sub.drug.list),FUN=function(s){
    colnames(sub.drug.list[[s]])[-1]<-paste(s,colnames(sub.drug.list[[s]])[-1],sep = "\n")
    sub.drug.list[[s]][match(all.cells[[1]],Cell_line_Name),-1,with=F]
  })))
  # deal with this problematic dataset
  polley.ind<-grep('Polley',colnames(df))
  if(length(polley.ind)!=0){
    if(!is.na(polley.ind)){
      if(length(setdiff(unique(df[[polley.ind]]),NA))<3) df<-df[,-polley.ind,with=F]
    }
  }
  df
}
get.gene.df<-function(gene){ 
  sub.dep.list<-lapply(names(dependency.list),function(s){
    gene.ind<-match(gene,colnames(dependency.list[[s]]))
    if(length(gene.ind)>0) dependency.list[[s]][,c(1,gene.ind),with=F]
  })
  sub.dep.list<-structure(sub.dep.list,names=names(dependency.list))[which(!unlist(lapply(sub.dep.list,is.null)))]
  all.cells<-unique(unlist(lapply(sub.dep.list,FUN=function(x) x[[1]])))
  all.cells<-data.table(cell_line=all.cells)%>%separate(cell_line,into=c(NA,'lineage'),sep='_',remove=F,extra = 'merge')
  data.table(all.cells,do.call(cbind,lapply(names(sub.dep.list),FUN=function(s){
    colnames(sub.dep.list[[s]])[-1]<-paste(s,colnames(sub.dep.list[[s]])[-1],sep = "\n")
    sub.dep.list[[s]][match(all.cells[[1]],Cell_line_Name),-1,with=F]
  })))
}
get.df<-reactive({
  switch(match(input$`scatter-type`,c('drug','dependency')),
         get.drug.df(input$`scatter-SelectFeature`),get.gene.df(input$`scatter-SelectFeature`))
})

my_scatter <- function(data, mapping, ...) {
  ggplot(data = data, mapping=mapping) +
    geom_point(...,size=1,alpha=0.2,aes(text=cell_line,color=lineage))
}

my_dens <- function(data, mapping, ...) {
  X <- eval_data_col(data, mapping$x);X<-X[!is.na(X)]
  if(length(unique(X))==1){
    x.class<-NULL
  }else{
    mc<-Mclust(X,G=2,modelNames = 'E')
    if(!is.null(mc)){
      bi<-round(diff(mc$parameters$mean)/sqrt(mc$parameters$variance$sigmasq)*sqrt(prod(mc$parameters$pro)),2)
      x.class<-c('low','high')[mc$classification]
    }else{x.class<-NULL}
  }
  x.bw<-bw.nrd0(X)
  d<-density(X,bw=x.bw)
  g<-ggplot()+geom_line(mapping=aes(x=d$x,y=d$y),color='black')
  if(!is.null(x.class)){
    x.df<-data.table(x=X,class=x.class)
    d1<-density(x.df[class=='low'][['x']],bw=x.bw);d2<-density(x.df[class=='high'][['x']],bw=x.bw)
    fracs<-table(x.class)/length(X)
    g<-g+geom_line(mapping=aes(x=d1$x,y=d1$y*fracs['low']),color='blue')+geom_line(mapping=aes(x=d2$x,y=d2$y*fracs['high']),color='red')
    g.ref<-ggplot_build(g)
    g<-g+annotate('text',x=g.ref$layout$panel_scales_x[[1]]$range$range[1]+0.5*abs(diff(g.ref$layout$panel_scales_x[[1]]$range$range)),
                  y=g.ref$layout$panel_scales_y[[1]]$range$range[2]-0.15*abs(diff(g.ref$layout$panel_scales_y[[1]]$range$range)),label=bi,hjust=0.5)
  }
  g
}
observeEvent(input$`scatter-type`,{
  output$`scatter-plot`<-NULL
  updateSelectizeInput(session,'scatter-SelectFeature',server = T,
                       choices = switch(match(input$`scatter-type`,c('drug','dependency')),structure(drug.ref$PubChemID,names=drug.ref$without_tail),dependency.summary$gene))
})
observeEvent(input$`scatter-submit`,{
  output$`scatter-plot`<-renderPlotly(isolate(
    ggplotly(ggpairs(get.df(),columns = 3:ncol(get.df()),lower = list(continuous=my_scatter),diag = list(continuous=my_dens))+theme_classic()+theme(panel.border = element_rect(fill=NA)),tooltip = c('text'))%>% 
      layout(height = 300+ncol(get.df())*80, width = 300+ncol(get.df())*80)
  ))
})

