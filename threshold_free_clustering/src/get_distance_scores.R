#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("threshold_free_clustering/src/functions.R")

# Compute distance scores

# Get pairwise distances
coordinates <- get_coordinates()
distances <- get_pairwise_distances(coordinates)
distances_hist <- get_histogram_of_pairwise_distances(distances, title = "Histogram of pairwise distances")
ggsave(distances_hist, filename = 'threshold_free_clustering/figs/distances.png', width = 8, height = 6)

# Get distance score by standardizing then taking the inverse of the distance
distance_scores <- get_distance_score(distances)
inverse_distances_hist <- get_histogram_of_pairwise_distances(distance_scores, title = "Histogram of inverse and normalized pairwise distances")
ggsave(inverse_distances_hist, filename = 'threshold_free_clustering/figs/inverse_normed_distances.png', width = 8, height = 6)

# Save variable
saveRDS(distance_scores, file = 'threshold_free_clustering/data/distance_scores/distance_scores.RDS')