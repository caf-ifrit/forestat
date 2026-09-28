#' Larch Dataset
#'
#' A dataset containing information about larch trees in the Winter Olympics core area.
#'
#' @format A data frame with 4538 rows and 18 variables:
#' \describe{
#'   \item{PLOT}{Sample plot identifier, indicating the plot number.}
#'   \item{TREE}{Tree species, which is "larch" in this dataset.}
#'   \item{D}{Diameter at breast height (DBH) of the tree, in centimeters.}
#'   \item{H}{Height of the tree, in meters.}
#'   \item{CBH}{Crown base height (branch-free height), in meters.}
#'   \item{LIFE}{Health status of the tree (e.g., "alive", "healthy", "unknown").}
#'   \item{CW_E}{Crown width in the east direction, in meters.}
#'   \item{CW_S}{Crown width in the south direction, in meters.}
#'   \item{CW_W}{Crown width in the west direction, in meters.}
#'   \item{CW_N}{Crown width in the north direction, in meters.}
#'   \item{X}{X-coordinate for individual tree location within the plot.}
#'   \item{Y}{Y-coordinate for individual tree location within the plot.}
#'   \item{SD}{Stand density, representing the density of trees within the plot.}
#'   \item{CLR}{Crown length ratio, which indicates the ratio of crown length to tree height.}
#'   \item{CW}{Overall crown width, in meters.}
#'   \item{CW_EW}{East-West crown width, in meters.}
#'   \item{CW_SN}{South-North crown width, in meters.}
#'   \item{AGE.GROUP}{Age group of the tree, which can be one of the following: "成熟林", "过熟林", "近熟林", "幼龄林", "中龄林".}
#' }
"larch"


#' Birch Dataset
#'
#' A dataset containing information about birch trees in the Winter Olympics core area.
#'
#'
#' @format A data frame with 2603 rows and 17 variables:
#' \describe{
#'   \item{PLOT}{Sample plot identifier, indicating the plot number.}
#'   \item{TREE}{Tree species, which is "birch" in this dataset.}
#'   \item{D}{Diameter at breast height (DBH) of the tree, in centimeters.}
#'   \item{H}{Height of the tree, in meters.}
#'   \item{CBH}{Crown base height (branch-free height), in meters.}
#'   \item{LIFE}{Health status of the tree (e.g., "alive", "healthy", "unknown").}
#'   \item{CW_E}{Crown width in the east direction, in meters.}
#'   \item{CW_S}{Crown width in the south direction, in meters.}
#'   \item{CW_W}{Crown width in the west direction, in meters.}
#'   \item{CW_N}{Crown width in the north direction, in meters.}
#'   \item{X}{X-coordinate for individual tree location within the plot.}
#'   \item{Y}{Y-coordinate for individual tree location within the plot.}
#'   \item{SD}{Stand density, representing the density of trees within the plot.}
#'   \item{CLR}{Crown length ratio, which indicates the ratio of crown length to tree height.}
#'   \item{CW}{Overall crown width, in meters.}
#'   \item{CW_EW}{East-West crown width, in meters.}
#'   \item{CW_SN}{South-North crown width, in meters.}
#' }
"birch"


#' Qinghai Spruce Dataset
#'
#' A dataset containing information about Qinghai spruce trees at the Xishui forest farm of Su’nan Yuguzu Autonomous County, China, in Gansu Qilian Mountain National Nature Reserve.
#'
#' @format A data frame with 402 rows and 24 variables:
#' \describe{
#'   \item{LIDAR-X}{LIDAR X-coordinate of the tree, representing spatial location data.}
#'   \item{LIDAR-Y}{LIDAR Y-coordinate of the tree, representing spatial location data.}
#'   \item{LH}{Tree height derived from LIDAR data, in meters.}
#'   \item{LHCB}{Crown base height derived from LIDAR data, in meters.}
#'   \item{LCW1}{Crown width measurement 1 derived from LIDAR data, in meters.}
#'   \item{LCW2}{Crown width measurement 2 derived from LIDAR data, in meters.}
#'   \item{LCW}{Average crown width derived from LIDAR data, in meters.}
#'   \item{CPA}{Crown projection area, representing the horizontal area of the crown, in square meters.}
#'   \item{X}{Ground X-coordinate of individual tree location within the plot.}
#'   \item{Y}{Ground Y-coordinate of individual tree location within the plot.}
#'   \item{Z}{Elevation of the tree base, in meters above sea level.}
#'   \item{PLOT}{Sample plot identifier, indicating the plot number.}
#'   \item{PLOT1}{Plot name or ID within the study area.}
#'   \item{OBS}{Observation number for the specific tree within the plot.}
#'   \item{D0}{Diameter at breast height (DBH) of the tree, in meters.}
#'   \item{H0}{Ground-measured height of the tree, in meters.}
#'   \item{HCB0}{Crown base height (branch-free height) measured on the ground, in meters.}
#'   \item{CW01}{Crown width measurement 1 measured on the ground, in meters.}
#'   \item{CW02}{Crown width measurement 2 measured on the ground, in meters.}
#'   \item{CW}{Average crown width measured on the ground, in meters.}
#'   \item{STEM}{Estimated biomass of the tree stem, in kilograms.}
#'   \item{BRANCH}{Estimated biomass of the tree branches, in kilograms.}
#'   \item{FOLIAGE}{Estimated biomass of the tree foliage, in kilograms.}
#'   \item{FRUIT}{Estimated biomass of the tree fruit, in kilograms.}
#' }
"picea"
