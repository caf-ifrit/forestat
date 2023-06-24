# -*- coding: UTF-8 -*-
#' @title Summary of forestData
#' @description Generates summary statistics for forestData objects.
#' @details The summary includes the summary of raw data, the model, the model parameters, potential productivity and real productivity in forestData(if available)
#' @param object A forestData object (after class.plot).
#' @param ... Additional arguments affecting the summary produced.
#' @return A summary object of class "summary.forestData"
#' @examples
#' \donttest{
#' # Load the forestat.csv sample data
#' forestData <- read.csv(system.file("extdata", "forestData.csv", package = "forestat"))
#'
#' # Build a model based on the forestData and return a forestData class object
#' forestData <- class.plot(forestData,model="Richards",
#'                          interval=5,number=5,maxiter=1000,
#'                          H_start=c(a=20,b=0.05,c=1.0))
#'
#' # Get the summary data of the forestData object
#' summary(forestData)
#' }
#' @export
summary.forestData <- function(object, ...){
  structure(object, class="summary.forestData")
  print.summary.forestData(object)
}


print.summary.forestData <- function (x, ...){
  H <- NULL
  S <- NULL
  BA <- NULL
  Bio <- NULL
  Max_GI <- NULL
  Max_MI <- NULL
  BAI <- NULL
  VI <- NULL
  data <- x
  if(all(c("BA","Bio") %in% colnames(data$Input))){
    select(data$Input,H,S,BA,Bio) %>% summary(.) %>% print(.)
  } else if("BA" %in% colnames(data$Input)){
    select(data$Input,H,S,BA) %>% summary(.) %>% print(.)
  } else if("Bio" %in% colnames(data$Input)){
    select(data$Input,H,S,Bio) %>% summary(.) %>% print(.)
  } else{
    select(data$Input,H) %>% summary(.) %>% print(.)
  }
  cat("\n")
  if(inherits(data$Hmodel,"modelobj")){
    model <- data$Hmodel$model
    parameter <- data$output$H
    cat("H-model Parameters:\n")
    print(summary(model))
    print.parameters(parameter)
  }
  cat("\n")
  if(inherits(data$BAmodel,"modelobj")){
    model <- data$BAmodel$model
    parameter <- data$output$BA
    cat("BA-model Parameters:\n")
    print(summary(model))
    print.parameters(parameter)
  }
  cat("\n")
  if(inherits(data$Biomodel,"modelobj")){
    model <- data$Biomodel$model
    parameter <- data$output$Bio
    cat("Bio-model Parameters:\n")
    print(summary(model))
    print.parameters(parameter)
  }
  cat("\n")
  if("potential.productivity" %in% names(data)){
    select(data$potential.productivity,Max_GI,Max_MI) %>% summary(.) %>% print(.)
  }
  cat("\n")
  if("reality.productivity" %in% names(data)){
    select(data$reality.productivity,BAI,VI) %>% summary(.) %>% print(.)
  }
}

print.parameters <- function(x, ...){
  parameter <- x
  cat("\n")
  cat("Concise Parameter Report:\n")
  cat("Model Coefficients:\n")
  print(parameter[c("a1","a2","a3","a4","a5","b","c")],row.names = F)
  cat("\n")
  cat("Model Evaluations:\n")
  print(parameter[c("pe","RMSE","R2","Var","TRE","AIC","BIC","logLik")],row.names = F)
  cat("\n")
  cat("Model Formulas:\n")
  print(parameter[c("Func","Spe")],row.names = F)
}
