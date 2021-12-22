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
observed <- get_cluster_scores(distance_scores, weight_scores)

# Compute cluster scores with permuted weight scores
permutations <- permute_clusters(distance_scores, weight_scores, 1)

# Plot permutation test results
hist_plot <- histogram(permutations$sum, observed$sum, title = condition)

# Save data and figures
observed_filename <- paste("threshold_free_clustering/data/cluster_scores/", condition, "_observed.RDS", sep = "")
saveRDS(observed, file = observed_filename)
permutations_filename <- paste("threshold_free_clustering/data/cluster_scores/", condition, "_permutations.RDS", sep = "")
saveRDS(permutations, file = permutations_filename)
fig_filename <- paste("threshold_free_clustering/figs/", condition, ".png", sep = "")
ggsave(hist_plot, filename = fig_filename, width = 8, height = 6)
