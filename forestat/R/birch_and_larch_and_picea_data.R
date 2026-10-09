#' Larch Dataset
#'
#' A dataset containing information about larch trees in the Winter Olympics core area.
#'
#' @format A data frame with 4538 rows and 18 variables:
#' \describe{
#'   \item{PLOT}{Numeric sample plot identifier.}
#'   \item{TREE}{Tree species code; always "larch" in this dataset.}
#'   \item{D}{Diameter at breast height (DBH) of the tree, in centimeters.}
#'   \item{H}{Height of the tree, in meters.}
#'   \item{CBH}{Crown base height (branch-free height), in meters.}
#'   \item{LIFE}{Tree condition code: "alive", "broken_head", "broken_tip", "healthy", or "unknown".}
#'   \item{CW_E}{Horizontal crown extent from the stem toward the east, in meters.}
#'   \item{CW_S}{Horizontal crown extent from the stem toward the south, in meters.}
#'   \item{CW_W}{Horizontal crown extent from the stem toward the west, in meters.}
#'   \item{CW_N}{Horizontal crown extent from the stem toward the north, in meters.}
#'   \item{X}{Within-plot X-coordinate of the tree, in meters; missing coordinates are \code{NA}.}
#'   \item{Y}{Within-plot Y-coordinate of the tree, in meters; missing coordinates are \code{NA}.}
#'   \item{SD}{Stand density, in trees per hectare.}
#'   \item{CLR}{Crown length ratio, calculated as crown length divided by tree height.}
#'   \item{CW}{Mean crown diameter, calculated as the mean of \code{CW_EW} and \code{CW_SN}, in meters.}
#'   \item{CW_EW}{East-west crown diameter, calculated as \code{CW_E + CW_W}, in meters.}
#'   \item{CW_SN}{South-north crown diameter, calculated as \code{CW_S + CW_N}, in meters.}
#'   \item{AGE.GROUP}{Age-group label stored in Chinese, with categories corresponding to young, middle-aged, near-mature, mature, and over-mature forest.}
#' }
#' @details Paired zero coordinates used as missing-value placeholders in the
#' source records are represented as \code{NA}; an isolated zero is retained as
#' a valid plot-boundary coordinate.
"larch"


#' Birch Dataset
#'
#' A dataset containing information about birch trees in the Winter Olympics core area.
#'
#'
#' @format A data frame with 2603 rows and 17 variables:
#' \describe{
#'   \item{PLOT}{Numeric sample plot identifier.}
#'   \item{TREE}{Tree species code; always "birch" in this dataset.}
#'   \item{D}{Diameter at breast height (DBH) of the tree, in centimeters.}
#'   \item{H}{Height of the tree, in meters.}
#'   \item{CBH}{Crown base height (branch-free height), in meters.}
#'   \item{LIFE}{Tree condition code: "alive", "broken_head", "dead", "healthy", "standing_dead", "unknown", or "withered_tip".}
#'   \item{CW_E}{Horizontal crown extent from the stem toward the east, in meters.}
#'   \item{CW_S}{Horizontal crown extent from the stem toward the south, in meters.}
#'   \item{CW_W}{Horizontal crown extent from the stem toward the west, in meters.}
#'   \item{CW_N}{Horizontal crown extent from the stem toward the north, in meters.}
#'   \item{X}{Within-plot X-coordinate of the tree, in meters; missing coordinates are \code{NA}.}
#'   \item{Y}{Within-plot Y-coordinate of the tree, in meters; missing coordinates are \code{NA}.}
#'   \item{SD}{Stand density, in trees per hectare.}
#'   \item{CLR}{Crown length ratio, calculated as crown length divided by tree height.}
#'   \item{CW}{Mean crown diameter, calculated as the mean of \code{CW_EW} and \code{CW_SN}, in meters.}
#'   \item{CW_EW}{East-west crown diameter, calculated as \code{CW_E + CW_W}, in meters.}
#'   \item{CW_SN}{South-north crown diameter, calculated as \code{CW_S + CW_N}, in meters.}
#' }
#' @details Paired zero coordinates used as missing-value placeholders in the
#' source records are represented as \code{NA}.
"birch"


#' Qinghai Spruce Dataset
#'
#' A dataset containing information about Qinghai spruce trees at the Xishui forest farm of Su'nan Yuguzu Autonomous County, China, in Gansu Qilian Mountain National Nature Reserve.
#'
#' @format A data frame with 402 rows and 24 variables:
#' \describe{
#'   \item{LIDAR-X}{Projected X-coordinate of the LIDAR-detected tree, in meters.}
#'   \item{LIDAR-Y}{Projected Y-coordinate of the LIDAR-detected tree, in meters.}
#'   \item{LH}{Tree height derived from LIDAR data, in meters.}
#'   \item{LHCB}{Crown base height derived from LIDAR data, in meters.}
#'   \item{LCW1}{East-west crown diameter derived from LIDAR data, in meters.}
#'   \item{LCW2}{South-north crown diameter derived from LIDAR data, in meters.}
#'   \item{LCW}{Mean LIDAR-derived crown diameter, calculated as the mean of \code{LCW1} and \code{LCW2}, in meters.}
#'   \item{CPA}{Crown projection area, in square meters.}
#'   \item{X}{Projected X-coordinate of the ground-measured tree, in meters.}
#'   \item{Y}{Projected Y-coordinate of the ground-measured tree, in meters.}
#'   \item{Z}{Elevation of the tree base, in meters above sea level.}
#'   \item{PLOT}{Character sample plot name, from "yd01" to "yd16".}
#'   \item{PLOT1}{Numeric sample plot identifier, from 1 to 16.}
#'   \item{OBS}{Tree observation identifier.}
#'   \item{D0}{Ground-measured diameter at breast height (DBH), in centimeters.}
#'   \item{H0}{Ground-measured height of the tree, in meters.}
#'   \item{HCB0}{Crown base height (branch-free height) measured on the ground, in meters.}
#'   \item{CW01}{Ground-measured east-west crown diameter, in meters.}
#'   \item{CW02}{Ground-measured south-north crown diameter, in meters.}
#'   \item{CW}{Mean ground-measured crown diameter, calculated as the mean of \code{CW01} and \code{CW02}, in meters.}
#'   \item{STEM}{Estimated biomass of the tree stem, in kilograms.}
#'   \item{BRANCH}{Estimated biomass of the tree branches, in kilograms.}
#'   \item{FOLIAGE}{Estimated biomass of the tree foliage, in kilograms.}
#'   \item{FRUIT}{Estimated biomass of the tree fruit, in kilograms.}
#' }
"picea"
