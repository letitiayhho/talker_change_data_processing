get_multilevel_data <- function() {
  ## DESCRIPTION:
  ##  Wrapper script for get_clusters in src/. Gets all clusters for each subject, 
  ##  matches it up to condition codes, adds subject numbers. Concatenates data
  ##  for all subjects into one data frame
  ##
  ## OUTPUT:
  ##  (data.frame) - Data frame containing cluster sizes, condition codes, and
  ##                 subject numbers
  ##  Saves as .csv files in data/aggregate
  
  ## SOURCE:
  setwd("/Users/letitiaho/src/talker_change_data_processing")
  source("src/functions.R")
  source("src/get_clusters.R")
  library(dplyr)
  
  
  ## MAIN:
  subject_numbers <- as.numeric(readLines('scripts/subject_numbers.txt'))
  neighbors <- get_neighbors()
  
  # Iterate over all subjects and concatenate their data into one data.frame
  cluster_data <- data.frame()
  for (subject_number in subject_numbers) {
    
    # Clear subject_data
    print(subject_number)
    subject_data <- data.frame()
    
    # Get condition codes
    subject_data <- read.csv(file.path("data", subject_number, "condition.csv"))

    # Get subject numbers
    subject_data$subject_number <- rep(subject_number, nrow(subject_data))

    # Get cluster sizes
    original <- read.csv(file.path("./data", subject_number, "maximum.csv"), header = FALSE)
    shuffled <- read.csv(file.path("./data", subject_number, "sample_shuffles.csv"), header = FALSE)
    subject_data$cluster_sizes <- get_clusters(original, shuffled, neighbors)

    # Combine into one data frame
    cluster_data <- rbind(cluster_data, subject_data)
  }

  write_csv(cluster_data, "data/aggregate/clusters.csv")
}


