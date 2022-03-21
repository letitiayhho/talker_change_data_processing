#!/usr/bin/env Rscript

library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("threshold_free_clustering/src/functions.R")

# Get command line args
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("One argument ('S', 'T', 'talker', 'meaning', etc) must be supplied", call.=FALSE)
}
condition = args[1]

# Load distance scores
distance_scores <- readRDS("threshold_free_clustering/data/distance_scores/distance_scores.RDS")

# Load weight scores
filepath <- paste("threshold_free_clustering/data/weight_scores/", condition, ".RDS", sep = "")
weight_scores <- readRDS(filepath)

# Compute observed cluster scores with distance and weight scores
chan_scores <- compute_chan_scores(distance_scores, weight_scores)

# Save data and figures
save_filename <- paste("threshold_free_clustering/data/chan_scores/", condition, ".RDS", sep = "")
saveRDS(chan_scores, file = save_filename)
