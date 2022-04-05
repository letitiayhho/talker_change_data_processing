#!/usr/bin/env Rscript

library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("5_cluster_cross_correlations/src/functions.R")

# Get command line args
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("One argument ('S', 'T', 'talker', 'meaning', etc) must be supplied", call.=FALSE)
} 
condition = args[1]

# Load distance scores
distance_scores <- readRDS("5_cluster_cross_correlations/data/distance_scores/distance_scores.RDS")

# Load weight scores
filepath <- paste("5_cluster_cross_correlations/data/weight_scores/weight_scores.RDS", sep = "")
all_weight_scores <- readRDS(filepath)
weight_scores <- all_weight_scores[[condition]]

# Compute observed cluster scores with distance and weight scores
observed <- get_cluster_scores(distance_scores, weight_scores)

# Compute cluster scores with permuted weight scores
permutations <- permute_clusters(distance_scores, weight_scores, 1000)

# Plot permutation test results
hist_plot <- histogram(permutations$sum, observed$sum, title = condition)

# Save data and figures
observed_filename <- paste("5_cluster_cross_correlations/data/cluster_scores/", condition, "_observed.RDS", sep = "")
saveRDS(observed, file = observed_filename)
permutations_filename <- paste("5_cluster_cross_correlations/data/cluster_scores/", condition, "_permutations.RDS", sep = "")
saveRDS(permutations, file = permutations_filename)
fig_filename <- paste("5_cluster_cross_correlations/figs/", condition, ".png", sep = "")
ggsave(hist_plot, filename = fig_filename, width = 8, height = 6)
