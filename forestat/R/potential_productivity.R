# -*- coding: UTF-8 -*-
#' @title Calculate the potential productivity.
#' @description potential.productivity calculate the potential productivity of each tree based on model parameters(obtained from the parameterOutput function).
#' @details potential.productivity takes data_BA,data_V parameters as required inputs.
#' @inheritParams reality.productivity
#' @param code Codes for forest types.
#' @param age.min The minimum age of production potential.
#' @param age.max The maximum age of production potential
#' @param left Solving for the left boundary of the potential productivity.
#' @param right Solving for the right boundary of the potential productivity.
#' @param e Accuracy parameters for solving the forest density index according to Newton's iterative method.
#' @param maxiter Maximum number of iterations parameter for solving the forest density index according to Newton's iteration method.
#' @return A forestData class in which a data.frame with potential productivity parameters is added.
#' @examples
#' \dontrun{
#' forestData <- potential.productivity(forestData,code=1,
#'                                      age.min=5,age.max=150,
#'                                      left=0.05,right=100,
#'                                      e=1e-05,maxiter=50)
#' }
#' @export potential.productivity

potential.productivity <- function(forestData, code=1,
                                   age.min=5,age.max=150,
                                   left=0.05, right=100,
                                   e=1e-05, maxiter=50) {
  if(!inherits(forestData, "forestData")){
    stop("Only data in forestData format is available!")
  }
  if(!inherits(forestData$BAmodel,"modelobj")){
    stop("BA model is missing!")
  }
  if(!inherits(forestData$Biomodel,"modelobj")){
    stop("Bio model is missing!")
  }
  data_BA <- forestData$output$BA
  data_V <- forestData$output$Bio
  N <- 2+max(forestData$Input$LASTGROUP)
  Nrow <- c(data_BA$code == code)
  parameterBA <- list(b1 = data_BA[Nrow,2:(N-1)] %>%
                        as.numeric(.),
                      b2 = data_BA[Nrow,N],
                      b3 = data_BA[Nrow,N+1],
                      b4 = data_BA[Nrow,(N+2):(2*N-1)] %>%
                        as.numeric(.),
                      S0_BA = data_BA[Nrow,2*N]
  )

  parameterV <- list(v1 = data_V[Nrow,2:(N-1)] %>%
                       as.numeric(.),
                     v2 = data_V[Nrow,N],
                     v3 = data_V[Nrow,N+1],
                     v4 = data_V[Nrow,(N+2):(2*N-1)] %>%
                       as.numeric(.),
                     S0_V = data_V[Nrow,2*N]
  )
  LASTGROUP <- 1:max(forestData$Input$LASTGROUP)
  AGE <- age.min:age.max
  outputGet <- function(LASTGROUP){
    BAVI.opt(AGE,LASTGROUP,parameterBA,parameterV,left,right,e=1e-05,maxiter = 50,Smin=20,Smax=3000)
  }
  temp <- lapply(LASTGROUP, outputGet)
  output <- data.frame()
  AgeLastgroup <- data.frame()
  for (i in LASTGROUP) {
    output <- rbind(output,temp[[i]])
    for (j in AGE) {
      AgeLastgroup <- rbind(AgeLastgroup,data.frame(i,j))
    }
  }
  output <- cbind(output,AgeLastgroup)
  names(output) <- c("Max_GI","Max_MI","N1","D1","S0","S1","G0","G1","M0","M1","LASTGROUP","AGE")
  forestData$potential.productivity <- output
  return(forestData)
}
