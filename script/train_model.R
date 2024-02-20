# train_model.R
args <- commandArgs(trailingOnly = TRUE)

# Check the number of arguments
if(length(args) != 2) {
  stop("You need to supply two arguments: [1] input CSV filename, [2] output RData filename.", call.=FALSE)
}

# Retrieve filenames from command line arguments
input_csv_filename <- args[1]
output_rdata_filename <- args[2]

# Check if the required package is installed
if (!require(forestat)) {
  # install forestat
  install.packages("forestat", repos="https://cloud.r-project.org/")
}

# Load the required package
library(forestat)

# Load data
forestData <- read.csv(input_csv_filename)

# Train model
forestData <- class.plot(forestData, model = "Richards",
                         interval = 5, number = 5,
                         H_start=c(a=20,b=0.05,c=1.0))

# Save model
save(forestData, file = output_rdata_filename)

