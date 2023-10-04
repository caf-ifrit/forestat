# -*- coding: UTF-8 -*-
#' @title Preprocess the degraded forest data
#' @description Preprocess the degraded forest data and return the plot_data.
#' @details tree_1, tree_2, tree_3 are required to include the fields "plot_id", "inspection_type", and "tree_species_code". plot_1, plot_2, and plot_3 are required to include the fields "plot_id", "standing_stock", "forest_cutting_stock", "crown_density", "disaster_level", "origin", "dominant_tree_species", "age_group", "naturalness", and "land_type".
#' @param tree_1 Tree data for the 1st period
#' @param tree_2 Tree data for the 2nd period
#' @param tree_3 Tree data for the 3rd period
#' @param plot_1 Plot data for the 1st period
#' @param plot_2 Plot data for the 2nd period
#' @param plot_3 Plot data for the 3rd period
#' @return Preprocessed plot_data
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
#' }
#' @export degraded_forest_preprocess
#' @import dplyr
#' @importFrom rlang .data

# Preprocess the data and return the plot_data.
degraded_forest_preprocess <- function(tree_1, tree_2, tree_3, plot_1, plot_2, plot_3) {
  tree_required_fields <- c("plot_id", "inspection_type", "tree_species_code")
  plot_required_fields <- c("plot_id", "standing_stock", "forest_cutting_stock", "crown_density", "disaster_level", "origin", "dominant_tree_species", "age_group", "naturalness", "land_type")

  tree_1 <- check_data(tree_1, tree_required_fields)
  tree_2 <- check_data(tree_2, tree_required_fields)
  tree_3 <- check_data(tree_3, tree_required_fields)
  plot_1 <- check_data(plot_1, plot_required_fields)
  plot_2 <- check_data(plot_2, plot_required_fields)
  plot_3 <- check_data(plot_3, plot_required_fields)

  standing_tree <- select(tree_1, c("plot_id", "inspection_type", "tree_species_code")) %>%
    filter(!(.data$inspection_type %in% c(13, 14, 15, 17))) %>%
    group_by(.data$plot_id) %>%
    summarise(standing_tree_1 = n(), tree_species_num_1 = n_distinct(.data$tree_species_code))

  recruitment_tree_2 <- select(tree_2, c("plot_id", "inspection_type")) %>%
    filter(.data$inspection_type == 12) %>%
    group_by(.data$plot_id) %>%
    summarise(recruitment_tree = n())

  tree_species_num <- select(tree_3, c("plot_id", "inspection_type", "tree_species_code")) %>%
    filter(!(.data$inspection_type %in% c(13, 14, 15, 17))) %>%
    group_by(.data$plot_id) %>%
    summarise(tree_species_num_3 = n_distinct(.data$tree_species_code))

  recruitment_tree_3 <- select(tree_3, c("plot_id", "inspection_type")) %>%
    filter(.data$inspection_type == 12) %>%
    group_by(.data$plot_id) %>%
    summarise(recruitment_tree = n()) %>%
    full_join(tree_species_num, by = c("plot_id"))

  recruitment_tree_3[is.na(recruitment_tree_3$recruitment_tree), ]$recruitment_tree <- 0

  recruitment_tree <- full_join(recruitment_tree_3, recruitment_tree_2, by = c("plot_id"))
  recruitment_tree[is.na(recruitment_tree$recruitment_tree.x), ]$recruitment_tree.x <- 0
  recruitment_tree[is.na(recruitment_tree$recruitment_tree.y), ]$recruitment_tree.y <- 0
  recruitment_tree <- mutate(recruitment_tree, recruitment_tree_23 = recruitment_tree$recruitment_tree.x + recruitment_tree$recruitment_tree.y)

  plot_1 <- select(plot_1, all_of(plot_required_fields)) %>%
    left_join(select(standing_tree, c("plot_id", "tree_species_num_1", "standing_tree_1")), by = c("plot_id"))

  plot_3 <- select(plot_3, all_of(plot_required_fields)) %>%
    left_join(select(recruitment_tree, c("plot_id", "tree_species_num_3", "recruitment_tree_23")), by = c("plot_id"))

  plot_13 <- inner_join(plot_1, plot_3, by = c("plot_id"))
  plot_123 <- inner_join(plot_13, select(plot_2, c("plot_id", "naturalness.z" = "naturalness", "standing_stock.z" = "standing_stock", "forest_cutting_stock.z" = "forest_cutting_stock")), by = c("plot_id"))
  plot_data <- left_join(plot_123, data.frame(origin.y = c(11, 12, 13, 21, 22, 23, 24), origin = c(1, 1, 1, 2, 2, 2, 2)), by = c("origin.y"))

  return(plot_data)
}

# Check if the data contains the required_fields and return the filtered result
check_data <- function(data, required_fields) {
  missing_fields <- setdiff(required_fields, colnames(data))

  if (length(missing_fields) > 0) {
    error_msg <- paste("The dataframe is missing the following fields:", paste(missing_fields, collapse = ", "))
    stop(error_msg)
  } else {
    filtered_data <- data[, required_fields]
    filtered_data$plot_id <- as.character(filtered_data$plot_id)
    return(filtered_data)
  }
}

