#!/usr/bin/env Rscript

#SBATCH --time=01:00:00
#SBATCH --partition=broadwl
#SBATCH --ntasks=1
#SBATCH	--mem-per-cpu=2G

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

# Get filepath
filepath <- paste("threshold_free_clustering/data/wilcoxon_results/", condition, ".RDS", sep = "")
cat(filepath)
w <- readRDS(filepath)

# Load distance scores
distance_scores <- readRDS("threshold_free_clustering/data/permutations/distance_scores.RDS")

# Compute weight scores
weight_scores <- normalize(w$w)

# Compute cluster scores with distance and weight scores
cluster_scores <- get_cluster_scores(distance_scores, weight_scores)

# Permute channel weights
permutations <- permute_clusters(distance_scores, weight_scores, 1)

# Plot permutation test results
hist_plot <- histogram(permutations$sum, cluster_scores$sum, title = condition)

# Save data and figures
observed_filename <- paste("threshold_free_clustering/data/permutations/", condition, "_observed.RDS", sep = "")
saveRDS(cluster_scores, file = observed_filename)
permutations_filename <- paste("threshold_free_clustering/data/permutations/", condition, "_permutations.RDS", sep = "")
saveRDS(permutations, file = permutations_filename)
fig_filename <- paste("threshold_free_clustering/figs/", condition, ".png", sep = "")
ggsave(hist_plot, filename = fig_filename, width = 8, height = 6)