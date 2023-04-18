#' @title ForestData Plot
#' @description Plot example figures about the forestData.
#' @param x A data of forestData class.
#' @param model.type A character in one of the three characters H,BA,Bio.This means that the figure should use the model you choose to plot.
#' @param plot.type A character in one of the four characters "Curve","residuals","Scatter_Curve","Scatter".This means that the picture is drawn of the type you have chosen
#' @param xlab The title for the x axis.
#' @param ylab The title for the y axis.
#' @param legend.lab The title for the legends.
#' @param title The text for the title.
#' @param ... Additional arguments affecting the figure plotted.
#' @export
#' @import ggplot2
#' @importFrom stats residuals fitted
plot.forestData <-function(x,model.type="H",
                           plot.type="Curve",
                           xlab=NA,ylab=NA,legend.lab="Site class",
                           title="Oak broadleaf mixed",...){
  model.type.list <- c("H","BA","Bio")
  plot.type.list <- c("Curve","residuals","Scatter_Curve","Scatter")
  if(all(plot.type != plot.type.list)){
    stop("Wrong Plot Type!Please type in Curve,residuals,Scatter_Curve or Scatter!")
  }
  if(all(model.type != model.type.list)){
    stop("Wrong Model Type!Please type in H,BA or Bio!")
  }
  if(!inherits(x, "forestData")){
    stop("Only data in forestData format is available!")
  }
  if(plot.type == "Curve"){
    xlab <- ifelse(is.na(xlab),"Stand age (year)",xlab)
    plot_Curve(x,type=model.type,xlab=xlab,
               ylab=ylab,legend.lab=legend.lab,
               title=title)
  } else if(plot.type == "residuals"){
    xlab <- ifelse(is.na(xlab),"residuals",xlab)
    plot_residuals(x,type=model.type,xlab=xlab,
                   ylab=ylab,legend.lab=legend.lab,
                   title=title)
  } else if(plot.type == "Scatter_Curve"){
    xlab <- ifelse(is.na(xlab),"Stand age (year)",xlab)
    plot_Scatter_Curve(x,type=model.type,xlab=xlab,
                       ylab=ylab,legend.lab=legend.lab,
                       title=title)
  } else if(plot.type == "Scatter"){
    xlab <- ifelse(is.na(xlab),"Stand age (year)",xlab)
    plot_Scatter(x,type=model.type,xlab=xlab,
                 ylab=ylab,legend.lab=legend.lab,
                 title=title)
  }
}


plot_Curve <- function(forestData,type="H",xlab="Stand age (year)",
                       ylab=NA,legend.lab="Site class",
                       title="Oak broadleaf mixed"){
  temp <- forestData$grading
  if(type == "H"){
    plotModel <- forestData$Hmodel$model
  } else if(type == "BA"){
    plotModel <- forestData$BAmodel$model
  } else if(type == "Bio"){
    plotModel <- forestData$Biomodel$model
  }


  aa <- as.numeric(coef(plotModel)[,1])
  bb <- as.numeric(coef(plotModel)[,2])
  cc <- as.numeric(coef(plotModel)[,3])

  if(type != "H"){
    dd <- as.numeric(coef(plotModel)[,4])
  }else{
    dd <- NA
  }
  S <- mean(temp$S)
  par(mfrow=c(1,1),mar=c(4.5,5.5,1,1))
  DrawFigure2(temp,aa,bb,cc,S,type,xlab,ylab,
              legend.lab,title,dd)
}

plot_residuals <- function(forestData,type="H",xlab="residuals",
                           ylab=NA,legend.lab="Site class",
                           title="Oak broadleaf mixed"){
  temp <- forestData$grading
  if(type == "H"){
    plotModel <- forestData$Hmodel$model
    ylab <- ifelse(is.na(ylab),"Height fitted values",ylab)
  } else if(type == "BA"){
    plotModel <- forestData$BAmodel$model
    ylab <- ifelse(is.na(ylab),"Basal area fitted values",ylab)
  } else if(type == "Bio"){
    plotModel <- forestData$Biomodel$model
    ylab <- ifelse(is.na(ylab),"Biomass fitted values",ylab)
  }
  temp$residuals <- residuals(plotModel)
  temp$fitted <- fitted(plotModel)

  ggplot(data=temp,aes_string(x="residuals",y="fitted",
                              color=factor(temp$LASTGROUP),
                              shape=factor(temp$LASTGROUP)))+
    geom_point()+
    labs(title = title,x=xlab,y=ylab)+
    guides(color=guide_legend(title=legend.lab),
           shape=guide_legend(title=legend.lab))+
    theme(legend.justification = c(1,1), # legend.position = c(0.9,0.4),
          legend.background = element_blank(),
          legend.key = element_blank())+
    facet_wrap(~LASTGROUP)
}

plot_Scatter_Curve <- function(forestData,type="H",xlab="Stand age (year)",
                               ylab=NA,legend.lab="Site class",
                               title="Oak broadleaf mixed"){
  temp <- forestData$grading
  if(type == "H"){
    plotModel <- forestData$Hmodel$model
  } else if(type == "BA"){
    plotModel <- forestData$BAmodel$model
  } else if(type == "Bio"){
    plotModel <- forestData$Biomodel$model
  }

  aa <- as.numeric(coef(plotModel)[,1])
  bb <- as.numeric(coef(plotModel)[,2])
  cc <- as.numeric(coef(plotModel)[,3])

  if(type != "H"){
    dd <- as.numeric(coef(plotModel)[,4])
  }else{
    dd <- NA
  }
  S <- mean(temp$S)
  par(mfrow=c(1,1),mar=c(4.5,5.5,1,1))
  DrawFigure(temp,aa,bb,cc,S,type,xlab,ylab,
             legend.lab,title,dd)
}

plot_Scatter <- function(forestData,type="H",xlab="Stand age (year)",
                         ylab=NA,legend.lab="Site class",
                         title="Oak broadleaf mixed"){
  temp <- forestData$grading
  if(type == "H"){
    plotModel <- forestData$Hmodel$model
    ylab <- ifelse(is.na(ylab),"Height (m)",ylab)
  } else if(type == "BA"){
    plotModel <- forestData$BAmodel$model
    ylab <- ifelse(is.na(ylab),"Basal area (m2/hm)",ylab)
  } else if(type == "Bio"){
    plotModel <- forestData$Biomodel$model
    ylab <- ifelse(is.na(ylab),"Biomass",ylab)
  }

  ggplot(data=temp,aes_string(x="AGE",y=type,color=factor(temp$LASTGROUP),
                              shape=factor(temp$LASTGROUP)))+geom_point()+
    labs(title = title,x=xlab,y=ylab)+
    guides(color=guide_legend(title=legend.lab),
           shape=guide_legend(title=legend.lab))+
    theme(legend.position = c(1,0.32),
          legend.justification = c(1,1),
          legend.background = element_blank(),
          legend.key = element_blank())+
    facet_wrap(~LASTGROUP)
}
