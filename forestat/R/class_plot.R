# -*- coding: UTF-8 -*-
#' @title Calculate tree height grading parameters
#' @description class.plot adds new variables: the original tree height grading and the adjusted tree height grading. And the existing variables are retained.
#' @details Input takes a data.frame with three variables ID,AGE,H and returns the tree height grading value of every sample(rows in the data.frame).
#' @param data A data.frame data in which at least four columns are required as input: ID, code, AGE, H
#' @param model A character in one of the six characters "Logistic","Richards","Korf","Gompertz","Weibull","Schumacher".This means that the calculation should use the model you choose to build the H model.
#' @param interval The intervals for tree height classification.
#' @param number The maximum value of the tree height classification interval.
#' @param a,b,c The initial parameters of the fitted model.
#' @param maxiter The maximum number of iterations to fit the model.
#' @return A data of forestData class with output values, models and model parameters.
#' @export class.plot
class.plot <- function(data,model="Logistic",
                       interval=5,number=5,a=30,b=10,c=0.5,
                       maxiter = 1000){
  dataList <- c("ID","AGE","H","code")
  modelList <- c("Logistic","Richards","Korf",
                 "Gompertz","Weibull","Schumacher")
  if(all(model != modelList)){
    stop("The model is unmatch!")
  }
  if(!all(dataList %in% colnames(data))){
    stop("Required data missing!")
  }

  formulaList <- list(Logistic=H ~ 1.3 + a/(1 + b * exp(-c * AGE)),
                      Richards=H ~ 1.3 + a * (1 - exp(-b * AGE))^c,
                      Korf=H ~ 1.3 + a * exp(-b * AGE^(-c)),
                      Gompertz=H ~ 1.3 + a * exp(-b * exp(-c * AGE)),
                      Weibull=H ~ 1.3 + a * (1 - exp(-b * AGE^c)),
                      Schumacher=H ~ 1.3 + a * exp(-b/AGE)
  )
  Input <- NULL

  Input <- class.initial(data,interval = interval,number = number)
  result <- class.get(Input,model = model,a = a,b = b,c = c,maxiter = maxiter)

  result$Hmodel$formule = formulaList[[model]]
  class(result$Hmodel) <- c("modelobj",class(result$Hmodel))

  result <- append(result,
                   list(BAmodel = NULL,
                        Biomodel = NULL
                        )
                   )
  data$LASTGROUP <- result$Input$LASTGROUP
  if(all(c("BA","S") %in% colnames(data))){
    BA_Model <- nlme(BA ~ a*(1-exp(-b*(S/1000)^c*AGE))^d, data=data, start=c(a=60, b=0.0002, c=10, d=0.1),
                     fixed = a+b+c+d~1,random = list(LASTGROUP=pdDiag(a~1)),
                     control=list(returnObject = TRUE))
    result$BAmodel <- list(formule = BA ~ a*(1-exp(-b*(S/1000)^c*AGE))^d,
                           residual = residuals(BA_Model),
                           initialValue = list(a=60, b=0.0002, c=10, d=0.1),
                           model = BA_Model
                           )
    result$Input$BA <- data$BA
    result$Input$S <- data$S
    class(result$BAmodel) <- c("modelobj",class(result$BAmodel))
  }
  if(all(c("Bio","S") %in% colnames(data))){
    Bio_Model <- nlme(Bio ~ a*(1-exp(-b*(S/1000)^c*AGE))^d, data=data, start=c(a=400, b=0.0008, c=8, d=0.16),
                fixed = a+b+c+d~1,random = list(LASTGROUP=pdDiag(a~1)),
                control=list(returnObject = TRUE))
    result$Biomodel <- list(formule = Bio ~ a*(1-exp(-b*(S/1000)^c*AGE))^d,
                           residual = residuals(Bio_Model),
                           initialValue = list(a=400, b=0.0008, c=8, d=0.16),
                           model = Bio_Model
    )
    result$Input$Bio <- data$Bio
    result$Input$S <- data$S
    class(result$Biomodel) <- c("modelobj",class(result$Biomodel))
  }

  result$output <- parameterEstimate(result)
  class(result$Input) <- c("dataobj",class(result$Input))
  class(result) <- c("forestData",class(result))
  return(result)
}
