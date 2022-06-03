#!/usr/bin/env Rscript

library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("5_cluster_cross_correlations/src/functions.R")

conditions = c("overall", "S", "T", "M", "N", "L", "H", "talker", "meaning", "constraint")
for (condition in conditions) {
  # Load weight scores
  filepath <- paste("5_cluster_cross_correlations/data/weight_scores/weight_scores.RDS", sep = "")
  all_weight_scores <- readRDS(filepath)
  weight_scores <- all_weight_scores[[condition]]
  
  # Compute observed cluster scores with distance and weight scores
  observed_filename <- paste("5_cluster_cross_correlations/data/cluster_scores/", condition, "_observed.RDS", sep = "")
  observed <- readRDS(observed_filename)
  
  # Compute cluster scores with permuted weight scores
  permutations_filename <- paste("5_cluster_cross_correlations/data/cluster_scores/", condition, "_permutations.RDS", sep = "")
  permutations <- readRDS(permutations_filename)
  
  # Plot permutation test results
  hist_plot <- histogram(permutations$sum, observed$sum, title = condition)
  
  # Save data and figures
  fig_filename <- paste("5_cluster_cross_correlations/figs/", condition, ".png", sep = "")
  ggsave(hist_plot, filename = fig_filename, width = 8, height = 6)
}




