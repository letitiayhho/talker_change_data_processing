library(dplyr)
library(ggplot2)
library(rethinking)
theme_set(theme_minimal())  
setwd('~/src/talker_change_data_processing/')
source('5_rms/src/meaning_models_functions.R')

# Load data
xcorr <- read.csv('5_rms/data/maximum.csv')
xcorr <- xcorr[xcorr$talker == "S",]
rms <- read.csv('5_rms/data/rms.csv')
rms <- rms[rms$talker == "S",]

rms <- rms[rms$talker == "S",]
xcorr <- read.csv('5_rms/data/maximum.csv')
xcorr <- xcorr[xcorr$talker == "S",]
rms <- read.csv('5_rms/data/rms.csv')
rms <- rms[rms$talker == "S",]
left_superior_parietal <- data.frame(rms$epoch_rms53, rms$epoch_rms54, rms$epoch_rms60, rms$epoch_rms61, rms$epoch_rms67) %>%
  rowMeans()
get_model_for_one_channel(left_superior_parietal, xcorr, 42)
