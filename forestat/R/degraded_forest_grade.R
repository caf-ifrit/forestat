# -*- coding: UTF-8 -*-
#' @title Calculating degraded forest grade
#' @description Calculation of degraded forest grade.
#' @details Calculation of degraded forest grade, icluding p1, p2,p3, p4, p5, p1m, p2m, p3m, p4m, Z1, Z2, Z3, Z4, Z5, Z_sum, etc.
#' @param plot_data Preprocessed plot_data
#' @return res_data with degraded forest grade
#' @examples
#' \donttest{
#' # Load forest survey data
#' data(tree_1)
#' data(tree_2)
#' data(tree_3)
#' data(plot_1)
#' data(plot_2)
#' data(plot_3)
#'
#' # Preprocess the degraded forest data
#' plot_data <- degraded_forest_preprocess(tree_1,tree_2,tree_3,plot_1,plot_2,plot_3)
#'
#' # Calculation of degraded forest grade
#' res_data <- calc_degraded_forest_grade(plot_data)
#' }
#' @export calc_degraded_forest_grade
#' @import dplyr
#' @importFrom stats complete.cases

# Calculation of degraded forest grade
calc_degraded_forest_grade <- function(plot_data) {
  plot_data <- cal_indicator(plot_data)

  normal_plot_data <- plot_data %>% dplyr::filter(land_type.y == 111, complete.cases(p1, p2, p3, p4))
  abnormal_plot_data <- plot_data %>% dplyr::filter(land_type.y == 111, complete.cases(p1, p2, p3, p4))

  processlist <- I.divide_type(normal_plot_data, 30)

  res_list <- list()
  for (i in 1:length(processlist)) {
    data <- processlist[[i]]
    data$ID <- I.label(data)
    data$num <- I.degradation_indicator(data)[1]
    data$p1m <- I.degradation_indicator(data)[2]
    data$p2m <- I.degradation_indicator(data)[3]
    data$p3m <- I.degradation_indicator(data)[4]
    data$p4m <- I.degradation_indicator(data)[5]
    data$referenceID <- I.degradation_indicator(data)[6]
    res_list[[i]] <- data
  }
  res_data <- bind_rows(res_list)

  for (i in 1:nrow(res_data)) {
    res_data$Z1[i] <- I.discriminant_factor(res_data$referenceID[i], res_data$p1[i], res_data$p1m[i], M = 1)
    res_data$Z2[i] <- I.discriminant_factor(res_data$referenceID[i], res_data$p2[i], res_data$p2m[i], M = 2)
    res_data$Z3[i] <- I.discriminant_factor(res_data$referenceID[i], res_data$p3[i], res_data$p3m[i], M = 3)
    res_data$Z4[i] <- I.discriminant_factor(res_data$referenceID[i], res_data$p4[i], res_data$p4m[i], M = 4)
    if (res_data$disaster_level.y[i] == 0 | res_data$disaster_level.y[i] == 1) {
      res_data$Z5[i] <- 0
    } else {
      res_data$Z5[i] <- 1
    }
  }
  res_data <- mutate(res_data, Z = Z1 + Z2 + Z3 + Z4 + Z5,
                     Z_weights = Z1 + 0.75 * Z2 + 0.5 * Z3 + 0.5 * Z4 + 0.25 * Z5,
                     Z_grade = I.cal_grade(Z, 1),
                     Z_weights_grade = I.cal_grade(Z_weights, 2))

  return(res_data)
}

# Calculate indicators
# forest accumulation growth rate (p1), forest recruitment rate (p2), tree species reduction rate (p3), forest canopy cover reduction rate (p4), and forest disaster level (p5).
cal_indicator <- function(plot_data) {
  indicator <- mutate(plot_data, p1 = I.p1(standing_stock.x, standing_stock.y + forest_cutting_stock.y + forest_cutting_stock.z),
                      p2 = I.p2(standing_tree_1, recruitment_tree_23),
                      p3 = I.p3(tree_species_num_1, tree_species_num_3),
                      p4 = I.p4(crown_density.x, crown_density.y),
                      p5 = disaster_level.y)
  return(indicator)
}






