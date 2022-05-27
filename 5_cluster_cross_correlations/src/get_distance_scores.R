#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("5_cluster_cross_correlations/src/functions.R")

# Get pairwise distances
coordinates <- get_coordinates()
distances <- get_pairwise_distances(coordinates)

# Get distance score by normalizing then taking the inverse
distance_scores <- 1/distances

# Plot
distances_hist <- get_histogram_of_pairwise_distances(distances, title = "Pairwise distances")
ggsave(distances_hist, filename = '5_cluster_cross_correlations/figs/pairwise_distances.png', width = 8, height = 6)
inverse_distances_hist <- get_histogram_of_pairwise_distances(distance_scores, title = "Distance scores")
ggsave(inverse_distances_hist, filename = '5_cluster_cross_correlations/figs/distance_scores.png', width = 8, height = 6)

# Save variable
saveRDS(distance_scores, file = '5_cluster_cross_correlations/data/distance_scores/distance_scores.RDS')
