# -*- coding: UTF-8 -*-
#' @title Calculate the site classes based on stand height growth
#' @description class.plot adds new variables: the original height classes and the adjusted height classes. And the existing variables are retained.
#' @details Input takes a data.frame with three variables ID, AGE, H and returns height classes of every sample (rows in the data.frame).
#' @param data A data.frame data in which at least four columns are required as input: ID, code, AGE, H.
#' @param model Type of model used for building the H-model (stand height model), options are `Logistic`, `Richards`, `Korf`, `Gompertz`, `Weibull`, or `Schumacher`.
#' @param interval The initial stand age interval for height classes.
#' @param number The maximum number of initial height classes.
#' @param H_start The initial parameters for fitting the H-model, the default value is c(a=20,b=0.05,c=1.0).
#' @param maxiter The maximum number of iterations to fit the H-model.
#' @param BA_start The initial parameters for fitting the BA-model, the default value is c(a = 80, b = 0.0001, c = 8, d = 0.1).
#' @param Bio_start The initial parameters for fitting the Bio-model, the default value is c(a=450, b=0.0001, c=12, d=0.1).
#' @return A data of forestData class with output values, models and model parameters.
#' @examples
#' \donttest{
#' # Load sample data
#' data("forestData")
#'
#' # Build a model based on the forestData and return a forestData class object
#' forestData <- class.plot(forestData,model="Richards",
#'                          interval=5,number=5,maxiter=1000,
#'                          H_start=c(a=20,b=0.05,c=1.0))
#' }
#' @export class.plot
class.plot <- function(data,model="Richards",
                       interval=5,number=5,maxiter=1000,
                       H_start=c(a=20,b=0.05,c=1.0),
                       BA_start = c(a = 80, b = 0.0001, c = 8, d = 0.1),
                       Bio_start = c(a=450, b=0.0001, c=12, d=0.1)){
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
  result <- class.get(Input,model = model,H_start=H_start,maxiter = maxiter)

  result$Hmodel$formule = formulaList[[model]]
  class(result$Hmodel) <- c("modelobj",class(result$Hmodel))

  result <- append(result,
                   list(BAmodel = NULL,
                        Biomodel = NULL
                        )
                   )
  data$LASTGROUP <- result$Input$LASTGROUP
  if(all(c("BA","S") %in% colnames(data))){
    BA_Model <- nlme(BA ~ a*(1-exp(-b*(S/1000)^c*AGE))^d, data=data, start=BA_start,
                     fixed = a+b+c+d~1,random = list(LASTGROUP=pdDiag(a~1)),
                     control=list(returnObject = TRUE))
    result$BAmodel <- list(formule = BA ~ a*(1-exp(-b*(S/1000)^c*AGE))^d,
                           residual = residuals(BA_Model),
                           initialValue = BA_start,
                           model = BA_Model
                           )
    result$Input$BA <- data$BA
    result$Input$S <- data$S
    class(result$BAmodel) <- c("modelobj",class(result$BAmodel))
  }

  if(all(c("Bio","S") %in% colnames(data))){
    Bio_Model <- nlme(Bio ~ a*(1-exp(-b*(S/1000)^c*AGE))^d, data=data, start=Bio_start,
                      fixed = a+b+c+d~1,random = list(LASTGROUP=pdDiag(a~1)),
                      control=list(returnObject = TRUE))
    result$Biomodel <- list(formule = Bio ~ a*(1-exp(-b*(S/1000)^c*AGE))^d,
                            residual = residuals(Bio_Model),
                            initialValue = Bio_start,
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
