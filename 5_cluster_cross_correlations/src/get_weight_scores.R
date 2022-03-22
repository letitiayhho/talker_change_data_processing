#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
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
cat(condition)

# Normalize w-score to compute weight scores
filepath <- paste("threshold_free_clustering/data/wilcoxon/", condition, ".RDS", sep = "")
w <- readRDS(file = filepath)

# Get weight scores
weight_scores <- abs_normalize(w$w, condition)

# Save variables
save_filepath <- paste("threshold_free_clustering/data/weight_scores/", condition, ".RDS", sep = "")
saveRDS(weight_scores, file = save_filepath)