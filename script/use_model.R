# use_model.R
args <- commandArgs(trailingOnly = TRUE)

# Check if the correct number of arguments is provided
if(length(args) != 3) {
  stop("You need to supply three arguments: [1] productivity_type (potential or realized), [2] trained model file name (rda file), [3] output txt file name.", call. = FALSE)
}

# Parse the arguments
productivity_type <- args[1]
rdata_file_name <- args[2]
output_file_name <- args[3]

# Check if the required package is installed
if (!require(forestat)) {
  # install forestat
  install.packages("forestat", repos="https://cloud.r-project.org/")
}

# Load the required package
library(forestat)

# Load the RData file
load(rdata_file_name)

# Check if 'forestData' exists in the loaded data
if(!exists("forestData")) {
  stop("The loaded data does not contain the 'forestData' object", call. = FALSE)
}

# Call the appropriate function based on productivity_type
if(productivity_type == 'potential') {
  forestData <- potential.productivity(forestData, code=1,
                                     age.min=5, age.max=150,
                                     left=0.05, right=100,
                                     e=1e-05, maxiter = 50) 
} else if(productivity_type == 'realized') {
  forestData <- realized.productivity(forestData, 
                                   left=0.05, right=100)
} else {
  stop("The productivity_type argument must be 'potential' or 'realized'", call. = FALSE)
}

# Get the summary data of the forestData object
summary(forestData)

# Capture the output of summary(forestData)
summary_output <- capture.output(summary(forestData))

# Save the captured output to a text file
writeLines(summary_output, output_file_name)
