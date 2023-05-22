# -*- coding: UTF-8 -*-
#' @importFrom  nlme nlme pdDiag fixed.effects
#' @importFrom  stats coef uniroot AIC BIC formula logLik var
#' @importFrom graphics legend lines par points text
#' @import dplyr

####Tree height grading####
utils::globalVariables(".")
class.get <- function(data,model="Logistic",a=30,b=10,c=0.1,maxiter = 1000){


  temp <- mutate(data,LASTGROUP = class0)
  k2 <- 0
  LASTGROUP <- temp$LASTGROUP
  class0 <- rep(0,length(LASTGROUP))
  #Each iteration changes LASTGROUP,
  #here is used to determine whether the value of LASTGROUP remains the same after the iteration.
  while(any(class0!=LASTGROUP) & k2 <= maxiter){
    class0 <- LASTGROUP
    modelInformation <- build.model(data = temp,model,a,b,c)

    if (any(class(modelInformation)=="try-error" )){
      if(k2==0){
        stop("The model do not converge, please change the initial value!")
      } else {
        stop(paste("The iterations stop at k2 = ",k2+1,sep = ""))
      }
    } else {
      lastgroupInput <- list(H = temp$H,AGE = temp$AGE,
                             a = coef(modelInformation)$a,
                             b = coef(modelInformation)$b,
                             c = coef(modelInformation)$c)

      temp$LASTGROUP <- lastgroup(model = model,H = lastgroupInput$H,
                                  AGE = lastgroupInput$AGE,
                                  a = lastgroupInput$a,
                                  b = lastgroupInput$b,
                                  c = lastgroupInput$c)
    }
    LASTGROUP <- temp$LASTGROUP
    k2 <- k2+1
  }
  data$LASTGROUP <- temp$LASTGROUP
  data <- list(Input = data,
               Hmodel = list(residual = residuals(modelInformation),
                             initialValue = list(a=a,b=b,c=c),
                             model = modelInformation)
               )
  return(data)
}

build.model <- function(data,model="Logistic",a=30,b=10,c=0.1){
  if(model=="Logistic"){
    try<-try(model1<-nlme(H~1.3+a/(1+b*exp(-c*AGE)),data=data,
                          start=c(a=a,b=b,c=c),fixed = a+b+c~1,
                          random = list(LASTGROUP=pdDiag(a~1))), TRUE)
  } else if(model=="Richards"){
    try<-try(model1<-nlme(H~1.3+a*(1-exp(-b*AGE))^c,data=data,
                          start=c(a=a,b=b,c=c),fixed = a+b+c~1,
                          random = list(LASTGROUP=pdDiag(a~1))), TRUE)
  } else if(model=="Korf"){
    try<-try(model1<-nlme(H~1.3+a*exp(-b*AGE^(-c)),data=data,
                          start=c(a=a,b=b,c=c),fixed = a+b+c~1,
                          random = list(LASTGROUP=pdDiag(a~1))), TRUE)
  } else if(model=="Gompertz"){
    try<-try(model1<-nlme(H~1.3+a*exp(-b*exp(-c*AGE)),data=data,
                          start=c(a=a,b=b,c=c),fixed = a+b+c~1,
                          random = list(LASTGROUP=pdDiag(a~1))), TRUE)
  } else if(model=="Weibull"){
    try<-try(model1<-nlme(H~1.3+a*(1-exp(-b*AGE^c)),data=data,
                          start=c(a=a,b=b,c=c),fixed = a+b+c~1,
                          random = list(LASTGROUP=pdDiag(a~1))), TRUE)
  } else if(model=="Schumacher"){
    try<-try(model1<-nlme(H~1.3+a*exp(-b/AGE),data=data,
                          start=c(a=a,b=b),fixed = a+b~1,
                          random = list(LASTGROUP=pdDiag(a~1))), TRUE)
  }
  modelInformation <- try
  return(modelInformation)
}

class.initial <- function(data,interval=5,number=5){
  ID <- NULL
  AGE <- NULL
  H <- NULL
  AGE.class <- NULL
  min.H <- NULL
  class.interval <- NULL
  class0 <- NULL
  code <- NULL
  temp <- select(data,ID,AGE,H) %>%
    mutate(.,AGE.class=floor(AGE/interval)*interval)
  temp <- group_by(temp,AGE.class) %>%
    summarise(n=n(), min.H=min(H), max.H=max(H), class.interval=(max(H)-min(H))/number) %>%
    left_join(temp,.,by=c("AGE.class"))
  if(all(temp$n %>% unique(.) > 1)){
    temp <- mutate(temp,class0=floor((H-min.H)/class.interval)+1)
    temp[temp$class0==number+1,]$class0 <- number
    data$class0 <- temp$class0
  } else {
    temp1 <- filter(temp,n > 1) %>%
      mutate(.,class0=floor((H-min.H)/class.interval)+1)
    temp1[temp1$class0==number+1,]$class0 <- number
    temp2 <- filter(temp,n <= 1)
    temp2$class0 <- 1
    temp <- bind_rows(temp1,temp2)
    data <- left_join(data,select(temp,ID,class0),by=c("ID"))
  }
  data <- select(data,code,ID,AGE,H,class0)
  return(data)
}

Hvalue <- function(AGE,a,b,c,model="Logistic"){
  data <- data.frame(a = a,b = b,c = c)
  if(model=="Logistic"){
    logistic<-function(data){
      a <- data[1]
      b <- data[2]
      c <- data[3]
      Hvalues<-a/(1+b*exp(-c*AGE))+1.3
      return(Hvalues)
    }
    Hvalues <- apply(data,1,logistic)
  } else if(model=="Richards"){
    richards<-function(data){
      a <- data[1]
      b <- data[2]
      c <- data[3]
      Hvalues<-a*(1-exp(-b*AGE))^c+1.3
      return(Hvalues)
    }
    Hvalues <- apply(data,1,richards)
  } else if(model=="Korf"){
    korf<-function(data){
      a <- data[1]
      b <- data[2]
      c <- data[3]
      Hvalues<-a*exp(-b*AGE^(-c))+1.3
      return(Hvalues)
    }
    Hvalues <- apply(data,1,korf)
  } else if(model=="Gompertz"){
    gompertz<-function(data){
      a <- data[1]
      b <- data[2]
      c <- data[3]
      Hvalues<-a*exp(-b*exp(-c*AGE))+1.3
      return(Hvalues)
    }
    Hvalues <- apply(data,1,gompertz)
  } else if(model=="Weibull"){
    weibull<-function(data){
      a <- data[1]
      b <- data[2]
      c <- data[3]
      Hvalues<-a*(1-exp(-b*AGE^c))+1.3
      return(Hvalues)
    }
    Hvalues <- apply(data,1,richards)
  } else if(model=="Schumacher"){
    schumacher<-function(data){
      a <- data[1]
      b <- data[2]
      c <- data[3]
      Hvalues<-a*exp(-b/AGE)+1.3
      return(Hvalues)
    }
    Hvalues <- apply(data,1,schumacher)
  }
  ####detect NA/NAN####
  if(any(is.nan(Hvalues) | is.na(Hvalues))){
    warning("Attention to Hvalues!")
  }
  return(Hvalues)
}

lastgroup<-function(H,AGE,a,b,c,model="Logistic"){
  Hvalues <- Hvalue(AGE,a,b,c,model=model)
  minus <- function(Hvalues){
    Abs <- abs(H-Hvalues)
    return(Abs)
  }
  groups <- apply(Hvalues, 2, minus)
  lastgroups <- apply(groups,1,which.min)
  return(lastgroups)
}

####Calculations of potential productivity####
SNGV <- function(Spro,AGE,parameterBA,parameterV,left_value,right_value,
                 e=1e-05,maxiter = 50,opt_or_not = T){
  b1 <- NULL
  b2 <- NULL
  b3 <- NULL
  b4 <- NULL
  S0_BA <- NULL

  v1 <- NULL
  v2 <- NULL
  v3 <- NULL
  v4 <- NULL
  S0_V <- NULL
  for(i in names(parameterBA)){
    assign(i,parameterBA[[i]])
  }
  for(i in names(parameterV)){
    assign(i,parameterV[[i]])
  }
  AGE <- ifelse(AGE<=3,5,AGE)
  GetMI <- function(Spro){
    if(length(Spro) == 1){
      S <- Spro
    } else {
      S <- Spro[2:3]
    }

    ####to be revised here####
    S[S==0] <- 25
    S[S<30] <- S[S<30]+20
    ####detection####
    tryBA <- b2*(S/S0_BA)^b3*AGE
    if(any(tryBA < 1e-16)){
      warning("Parameters in BA may be inappropriate")
      tryBA[tryBA < 1e-16] <- 1e-16
    }
    G0 <- b1*(1-exp(-tryBA))^b4
    D0<-(40000*G0/(pi*20^1.605*S))^(200/79)
    ####N0 is prone to NAN####
    N0<-40000*G0/(pi*D0^2)
    is.na(N0) %>% tryBA[.]
    rootFind <- function(N0){
      N0 <- N0[1]
      baf<-function(x){b1*(1-exp(-b2*((100/pi*x)^0.8025*N0^0.1975/S0_BA)^b3*(AGE+1)))^b4-x}
      try<-try(uniroot(baf,interval = c(left_value,right_value),
                       lower = left_value+1,extendInt="yes")[[1]]
               ,silent=T)
      iter <- 0
      while(class(try)=="try-error"){
        iter <- iter+1
        left_value <- left_value+0.05
        try<-try(uniroot(baf,interval = c(left_value,right_value),
                         lower = left_value+1,extendInt="yes")[[1]]
                 ,silent=T)
        if(iter>=500){
          warning("No appropriate G1 values!")
        }
      }
      return(try)
    }
    G1 <- sapply(N0,rootFind) %>% as.numeric(.)
    S0 <- N0*(D0/20)^1.605
    S1 <- (100/pi*G1)^0.8025*N0^0.1975
    D1 <- (40000*G1/(pi*20^1.605*S1))^(200/79)
    N1 <- 40000*G1/(pi*D1^2)
    M0 <- v1*(1-exp(-v2*(S/S0_V)^v3*AGE))^v4
    M1 <- v1*(1-exp(-v2*(S1/S0_V)^v3*(AGE+1)))^v4
    cgrowth <- data.frame(G1-G0,M1-M0,N1,D1,S0,S1,G0,G1,M0,M1)
    return(cgrowth)
  }
  MI <- GetMI(Spro)[2] %>% unlist(.) %>% as.numeric(.)

  MI.opt <- function(MI,Spro){
    step <- 0
    while(all(abs(MI[1]-MI[2])>e,step<maxiter)){
      if(all(MI[1]-MI[2]>=0)){
        Spro[4] <- Spro[3]
        Spro[2] <- Spro[1]+0.382*(Spro[4]-Spro[1])
        Spro[3] <- Spro[1]+0.618*(Spro[4]-Spro[1])
      } else {
        Spro[1] <- Spro[2]
        Spro[2] <- Spro[1]+0.382*(Spro[4]-Spro[1])
        Spro[3] <- Spro[1]+0.618*(Spro[4]-Spro[1])
      }
      MI <- GetMI(Spro)[2] %>% unlist(.) %>% as.numeric(.)
      step <- step+1
    }
    return(Spro)
  }

  if(opt_or_not == T){
    Spro <- MI.opt(MI,Spro)
    cgrowth <- GetMI(Spro) %>% colMeans(.)
  } else {
    cgrowth <- GetMI(Spro)
  }

  return(cgrowth)
}

BAVI.opt<-function(AGE,LASTGROUP,parameterBA,parameterV,left,right,
                   e=1e-05,maxiter = 50,Smin=20,Smax=3000){
  b4 <- parameterBA$b4
  parameterBA$b4 <- ifelse(is.na(b4[2]),b4[1],b4[LASTGROUP])
  v4 <- parameterV$v4
  parameterV$v4 <- ifelse(is.na(b4[2]),v4[1],v4[LASTGROUP])
  parameterBA$b1 <- parameterBA$b1[LASTGROUP]
  parameterV$v1 <- parameterV$v1[LASTGROUP]
  Spro <- c(Smin,Smin+0.382*(Smax-Smin),Smin+0.618*(Smax-Smin),Smax)
  MIoptGet <- function(AGE){
    MI <- SNGV(Spro,AGE,parameterBA,parameterV,left,right,e=1e-05,maxiter = 50,opt_or_not = T)
  }
  MIopt <- lapply(AGE,MIoptGet) %>% as.data.frame(.) %>% t(.)
  colnames(MIopt) <- c("Max_GI","Max_MI","N1","D1","S0","S1","G0","G1","M0","M1")
  rownames(MIopt) <- c()
  return(MIopt)
}

BAVI<-function(AGE,S,LASTGROUP,parameterBA,parameterV,left,right){
  b4 <- parameterBA$b4
  parameterBA$b4 <- ifelse(is.na(b4[2]),b4[1],b4[LASTGROUP])
  v4 <- parameterV$v4
  parameterV$v4 <- ifelse(is.na(b4[2]),v4[1],v4[LASTGROUP])
  parameterBA$b1 <- parameterBA$b1[LASTGROUP]
  parameterV$v1 <- parameterV$v1[LASTGROUP]
  cgrowth<-SNGV(Spro = S,AGE,parameterBA,parameterV,left,right,e=1e-05,maxiter = 50,opt_or_not = F)
  colnames(cgrowth) <- c("Max_GI","Max_MI","N1","D1","S0","S1","G0","G1","M0","M1")
  rownames(cgrowth) <- c()
  return(cgrowth)
}

####plot functions####
build_plotModel <- function(data,type){
  if(type == "H"){
    Model<-nlme(H ~ a*(1-exp(-b*AGE))^c+1.3,data=data,
                start=c(a=15,b=0.01,c=0.5),
                fixed = a+b+c~1,random = list(LASTGROUP=pdDiag(a~1)),
                control=list(returnObject = TRUE))
  }else if(type == "BA"){

    Model<-nlme(BA ~ a*(1-exp(-b*(S/1000)^c*AGE))^d, data=data, start=c(a=60, b=0.0002, c=10, d=0.1),
                fixed = a+b+c+d~1,random = list(LASTGROUP=pdDiag(a~1)),
                control=list(returnObject = TRUE))
  }else if(type == "Bio"){
    Model<-nlme(Bio ~ a*(1-exp(-b*(S/1000)^c*AGE))^d, data=data, start=c( a=400, b=0.0008, c=8, d=0.16),
                fixed = a+b+c+d~1,random = list(LASTGROUP=pdDiag(a~1)),
                control=list(returnObject = TRUE))
  }
  return(Model)
}

esti_H<-function(AGE_seq, g,aa,bb,cc){
  H<-aa[g]*(1-exp(-bb[g]*AGE_seq))^cc[g]+1.3
  return (H)
}

esti_BA<-function(AGE_seq,S,g,aa,bb,cc,dd){
  BA<-aa[g]*(1-exp(-bb[g]*(S/1000)^cc[g]*AGE_seq))^dd[g]
  return (BA)
}

esti_Bio<-function(AGE_seq,S,g,aa,bb,cc,dd){
  Bio<-aa[g]*(1-exp(-bb[g]*(S/1000)^cc[g]*AGE_seq))^dd[g]
  return (Bio)
}

DrawFigure<-function(data,aa,bb,cc,S,type,xlab,ylab,
                     legend.lab,title,dd=NA){
  AGE_min<-min(data$AGE)
  AGE_max<-max(data$AGE)
  AGE_seq<-seq(AGE_min,AGE_max,0.5)
  Tdata <- data[data$LASTGROUP==1,]
  if(type == "H"){
    ylab <- ifelse(is.na(ylab),"Height (m)",ylab)
    type_esti <- esti_H(AGE_seq,1,aa,bb,cc)
    ylimMax <- max(esti_H(AGE_seq,5,aa,bb,cc))
  }else if(type == "BA"){
    ylab <- ifelse(is.na(ylab),
                   expression(paste("Basal area(",m^2,"/",hm^2,")")),
                   ylab)
    type_esti <- esti_BA(AGE_seq,S,1,aa,bb,cc,dd)
    ylimMax <- max(esti_BA(AGE_seq,S,5,aa,bb,cc,dd))
  }else if(type == "Bio"){
    ylab <- ifelse(is.na(ylab),
                   expression(paste("Biomass(t/",hm^2,")")),
                   ylab)
    type_esti <- esti_Bio(AGE_seq,S,1,aa,bb,cc,dd)
    ylimMax <- max(esti_Bio(AGE_seq,S,5,aa,bb,cc,dd))
  }
  ylimMin <- min(type_esti)
  plot(Tdata$AGE,
       Tdata[,type],xlab=xlab,
       ylab=ylab,
       ylim=c(ylimMin-1,ylimMax+1),xlim=c(0,AGE_max+2),cex=1,cex.lab=1.5,
       cex.axis=1.5,"p",col=1,pch=1)
  #diff in lwd
  lines(AGE_seq,type_esti,col=1,lwd=3)
  text((AGE_max-AGE_min)/5,ylimMax+0.5,title,cex=2)
  for (i in 2:5){
    Tdata <- data[data$LASTGROUP==i,]
    a<-i
    if (i==9){
      a<-"steelblue4"
    }
    if (i==10){
      a<-"orange4"
    }
    #diff in cex
    points(Tdata$AGE,Tdata[,type],cex=1,"p",col=a,pch=1)
    if(type == "H"){
      type_esti <- esti_H(AGE_seq,i,aa,bb,cc)
    }else if(type == "BA"){
      type_esti <- esti_BA(AGE_seq,S,i,aa,bb,cc,dd)
    }else if(type == "Bio"){
      type_esti <- esti_Bio(AGE_seq,S,i,aa,bb,cc,dd)
    }

    lines(AGE_seq,type_esti,col=i,lwd=3)
  }
  legend("bottomright", title = legend.lab, legend=c("1","2","3","4","5"),col=c(1,2,3,4,5),
         "l", ncol= 5, lty=1,bty="n",lwd=2,cex=1,y.intersp = 1)# rainbow(3)
}

DrawFigure2<-function(data,aa,bb,cc,S,type,xlab,ylab,
                      legend.lab,title,dd=NA){
  AGE_min<-min(data$AGE)
  AGE_max<-max(data$AGE)
  AGE_seq<-seq(AGE_min,AGE_max,0.5)
  Tdata <- data[data$LASTGROUP==1,]
  Tdata <- data[data$LASTGROUP==1,]
  if(type == "H"){
    ylab <- ifelse(is.na(ylab),"Height (m)",ylab)
    type_esti <- esti_H(AGE_seq,1,aa,bb,cc)
    ylimMax <- max(esti_H(AGE_seq,5,aa,bb,cc))
  }else if(type == "BA"){
    ylab <- ifelse(is.na(ylab),
                   expression(paste("Basal area(",m^2,"/",hm^2,")")),
                   ylab)
    type_esti <- esti_BA(AGE_seq,S,1,aa,bb,cc,dd)
    ylimMax <- max(esti_BA(AGE_seq,S,5,aa,bb,cc,dd))
  }else if(type == "Bio"){
    ylab <- ifelse(is.na(ylab),
                   expression(paste("Biomass(t/",hm^2,")")),
                   ylab)
    type_esti <- esti_Bio(AGE_seq,S,1,aa,bb,cc,dd)
    ylimMax <- max(esti_Bio(AGE_seq,S,5,aa,bb,cc,dd))
  }
  ylimMin <- min(type_esti)

  plot(AGE_seq,type_esti,xlab=xlab,
       ylab=ylab,ylim=c(ylimMin-1,ylimMax+1),xlim=c(0,AGE_max+2),
       cex=1,cex.lab=1.3,cex.axis=1.3,"l",col=1,pch=1,lwd=3)
  #diff in lwd
  # lines(AGE_seq,type_esti,col=1,lwd=3)
  text((AGE_max-AGE_min)/5,ylimMax+0.5,title,cex=2)
  for (i in 2:5){
    Tdata <- data[data$LASTGROUP==i,]
    a<-i
    if (i==9){
      a<-"steelblue4"
    }
    if (i==10){
      a<-"orange4"
    }
    # points(Tdata$AGE,Tdata[,type],cex=1,"p",col=a,pch=1)
    if(type == "H"){
      type_esti <- esti_H(AGE_seq,i,aa,bb,cc)
    }else if(type == "BA"){
      type_esti <- esti_BA(AGE_seq,S,i,aa,bb,cc,dd)
    }else if(type == "Bio"){
      type_esti <- esti_Bio(AGE_seq,S,i,aa,bb,cc,dd)
    }

    lines(AGE_seq,type_esti,col=i,lwd=3)
  }
  legend("bottomright", title = legend.lab, legend=c("1","2","3","4","5"),col=c(1,2,3,4,5),
         "l", ncol= 5, lty=1,bty="n",lwd=2,cex=1,y.intersp = 1)# rainbow(3)
}

####Model parameter estimation####
parameterEstimate <- function(forestData){
  num=1
  H_jieguo <- NULL
  BA_jieguo <- NULL
  Bio_jieguo <- NULL
  if (inherits(forestData$Hmodel, "modelobj")){
    H_Model <- forestData$Hmodel$model
    H_Coef <- data.frame(code = num,
                         a1 = coef(H_Model)[1,1],
                         a2 = coef(H_Model)[2,1],
                         a3 = coef(H_Model)[3,1],
                         a4 = coef(H_Model)[4,1],
                         a5 = coef(H_Model)[5,1],
                         b = coef(H_Model)[1,2],
                         c = coef(H_Model)[1,3])
    H_jieguo <- data.frame(H_Coef, index.f(H_Model,forestData$Input$H,num,m=3)[4:ncol(index.f(H_Model,forestData$Input$H,num,m=3))])
  }
  if(inherits(forestData$BAmodel, "modelobj")){
    BA_Model <- forestData$BAmodel$model
    d1 = coef(BA_Model)[1,4]
    BA_Coef <- data.frame(code = num,
                          a1 = coef(BA_Model)[1,1],
                          a2 = coef(BA_Model)[2,1],
                          a3 = coef(BA_Model)[3,1],
                          a4 = coef(BA_Model)[4,1],
                          a5 = coef(BA_Model)[5,1],
                          b = coef(BA_Model)[1,2],
                          c = coef(BA_Model)[1,3],
                          d1 = coef(BA_Model)[1,4],
                          d2 = d1, d3= d1, d4= d1, d5 =d1,
                          Sbase = 1000,
                          Smean = mean(forestData$Input$S))
    BA_jieguo <- data.frame(BA_Coef, index.f(BA_Model,forestData$Input$BA,num,m=4)[5:ncol(index.f(BA_Model,forestData$Input$BA,num,m=4))])
  }
  if(inherits(forestData$Biomodel, "modelobj")){
    Bio_Model <- forestData$Biomodel$model
    d1 = coef(Bio_Model)[1,4]
    Bio_Coef <- data.frame(code = num,
                           a1 = coef(Bio_Model)[1,1],
                           a2 = coef(Bio_Model)[2,1],
                           a3 = coef(Bio_Model)[3,1],
                           a4 = coef(Bio_Model)[4,1],
                           a5 = coef(Bio_Model)[5,1],
                           b = coef(Bio_Model)[1,2],
                           c = coef(Bio_Model)[1,3],
                           d1 = coef(Bio_Model)[1,4],
                           d2 = d1, d3= d1, d4= d1, d5 =d1,
                           Sbase = 1000,
                           Smean = mean(forestData$Input$S))
    Bio_jieguo <- data.frame(Bio_Coef, index.f(Bio_Model,forestData$Input$Bio,num,m=4)[5:ncol(index.f(Bio_Model,forestData$Input$Bio,num,m=4))])
  }

  parameter_list <- list()
  parameter_list$H <- H_jieguo
  parameter_list$BA <- BA_jieguo
  parameter_list$Bio <- Bio_jieguo
  class(parameter_list) <- c("parameterobj",class(parameter_list))
  return(parameter_list)
}

FittingEvaluationIndex<-function(EstiH,ObsH){
  temp <- !is.na(EstiH) & !is.na(ObsH)
  EstiH <- EstiH[temp]
  ObsH <- ObsH[temp]
  Index<-array(dim=5)
  n<-length(ObsH)
  e<-ObsH-EstiH
  e1<-ObsH-mean(ObsH)
  pe<-mean(e)
  var2<-var(e)
  RMSE<-sqrt(pe^2+var2*(n-1)/n)
  R2<-1-sum(e^2)/sum((e1)^2)
  TRE<-100*sum(e^2)/sum((EstiH)^2)
  Index[1]<-pe
  Index[2]<-RMSE
  Index[3]<-R2
  Index[4]<-var2
  Index[5]<-TRE
  dimnames(Index)<-list(c("pe","RMSE","R2","Var","TRE"))
  return(Index)
}


index.f<-function(model,var,num,m=6){
  if(any(c("nls","lm","glm") %in% class(model))){
    TT<-c(coef(model),rep(NA,m-length(coef(model))))
    TT<-c(TT,FittingEvaluationIndex(fitted(model),var),AIC=AIC(model),BIC=BIC(model),logLik=as.numeric(logLik(model)))
  } else if (any(c("lme","nlme") %in% class(model))) {
    TT<-c(fixed.effects(model),rep(NA,m-length(fixed.effects(model))))
    TT<-c(TT,FittingEvaluationIndex(fitted(model),var),AIC=AIC(model),BIC=BIC(model),logLik=model$logLik)
  } else if ("glmmTMB" %in% class(model)) {
    TT1<-unname(c(fixed.effects(model)[[1]],fixed.effects(model)[[2]]))
    TT<-c(TT1,rep(NA,m-length(TT1)))
    TT<-c(TT,FittingEvaluationIndex(fitted(model),var),AIC=AIC(model),BIC=BIC(model),logLik=as.numeric(logLik(model)))
  } else {
    message("Please check the attribute of model!")
    return(NULL)
  }
  TT<-rbind(TT,data.frame())
  names(TT)<-c(paste0("a",1:m), "pe","RMSE","R2","Var","TRE","AIC","BIC","logLik")
  TT$Func<-paste(paste0("model",num),paste(formula(model)[2],formula(model)[1],formula(model)[3],collapse = " "),sep=":")
  if (any(c("lme","nlme") %in% class(model))){
    TT$Spe<-paste(paste0("model",num),model$call$random[2],sep=":")
    model$call$random
  } else {
    TT$Spe<-"None"
  }
  return(TT)
}


