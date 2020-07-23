

get_correlations <- function() { 
  correlations <- read.csv("data/aggregate/cross_correlation_data.csv")
  colnames(correlations) <- c("subject_number", "constraint", "meaning", "talker", paste("E", 1:128, sep = ""))
  return(correlations) }

get_rms <- function() {
  correlations <- read.csv("data/aggregate/RMS_data.csv")
  colnames(correlations) <- c("subject_number", "constraint", "meaning", "talker", paste("RMS_E", 1:128, sep = ""))
  return(correlations) }

# get_region_data_frame <- function(correlations, rms, area) {
  # Create a separate data frame for each region
  area <- "anterior"

  if (area == "anterior") {
    channels = paste("E", c(38, 39), sep = "")
  } else if (area == "middle") {
    channels = paste("E", c(40, 44, 45, 46), sep = "")
  } else if (area == "posterior") {
    channels = paste("E", c(50, 51, 57), sep = "")
  }
  
  region_df <- select(correlations, subject_number, constraint, meaning, talker, channels) %>%
    pivot_longer(cols = channels, names_to = "channel")
  # return(region_df)
# }


## MAIN:
library(dplyr)
library(tidyr)
correlations <- get_correlations()
rms <- get_rms()