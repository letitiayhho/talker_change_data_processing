# Pass in arguments
args <- commandArgs(trailingOnly = TRUE)
start_channel <- as.character(args[1])
end_channel <- as.character(args[2])

# Load libraries
library(dplyr)
library(ggplot2)
library(rethinking)
source("src/5_rms/functions.R")

# Load data
xcorr <- read.csv('data/5_rms/maximum.csv')
rms <- read.csv('data/5_rms/rms.csv')

# Average over rms for left and right superior parietal**
left_superior_parietal <- data.frame(rms$epoch_rms53, rms$epoch_rms54, rms$epoch_rms60, rms$epoch_rms61, rms$epoch_rms67) %>%
  rowMeans()
right_superior_parietal <- data.frame(rms$epoch_rms77, rms$epoch_rms78, rms$epoch_rms79, rms$epoch_rms85, rms$epoch_rms86) %>%
  rowMeans()

#Generate models and figures for channels in the specified range
for (channel_number in start_channel:end_channel) {
  model <- get_model_for_one_channel(left_superior_parietal, xcorr, channel_number)
}