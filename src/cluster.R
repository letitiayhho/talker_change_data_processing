get_clusters = function(distance = 3.5, alpha = 0.05, condition, n = 10, min_cluster_size = 2) {
  library(dplyr)
  
  ## Setting global variables
  t_threshold = qt(1-alpha/1, df = n-1)
  
  ## Load data
  setwd("/Applications/eeglab2019/talker-change-data-processing")
  t_values_raw = read.csv("data/cluster_t_values.csv")
  coords_raw = read.delim("data/302/channel_locations.sfp", header = FALSE, sep = "", dec = ".") %>%
    .[startsWith(as.character(.$V1), "E"), ]
  
  ## Get t_values
  if (condition == 'constraint'){
    t_values = t_values_raw[1,]
  } else if (condition == 'meaning') {
    t_values = t_values_raw[2,]
  } else if (condition == 'talker') {
    t_values = t_values_raw[3,]
  }
  
  ## Get pairwise Euclidean distance
  coords = cbind(coords_raw$V2, coords_raw$V3, coords_raw$V4)
  distances = as.matrix(dist(coords))
  
  ## Get histogram of pairwise distances
  # sort_distances = as.vector(distances) %>%
  #   .[!duplicated(.)] %>%
  #   sort() %>%
  #   hist(., breaks = 50, main = 'Histogram of pairwise distances')

  ## Get clusters
  above_threshold_neighbors = vector(mode = "list", length = nrow(distances))
  for (i in 1:nrow(distances)) {
    neighboring_channels = which(distances[i, ] < distance)
    above_threshold_neighbors_indexes = which(abs(t_values[neighboring_channels]) > t_threshold)
    above_threshold_neighbors_for_each_channel = list(neighboring_channels[above_threshold_neighbors_indexes])
    above_threshold_neighbors[i] = above_threshold_neighbors_for_each_channel
  }
  
  # Initialize list of clusters
  clusters = vector(mode = "list")
  
  # Loop through neighbors
  for (i in 1:length(above_threshold_neighbors)) {
    # Continue if neighbors is empty
    if (length(above_threshold_neighbors[[i]]) == 0) {
      next
    }
    
    # Add to clusters if clusters is empty
    if (length(clusters) == 0) {
      cluster = above_threshold_neighbors[[i]]
      clusters = list(c(cluster))
    }
    
    # Loop through existing clusters to identify cluster with overlap
    for (j in 1:length(clusters)) {
      # Add each neighbor to each cluster and see if there are duplicates
      comparison = c(clusters[[j]], above_threshold_neighbors[[i]])
      
      # If there are duplicates keep the cluster merged and remove duplicates
      if (TRUE %in% duplicated(comparison)) {
        cluster = unique(comparison)
        clusters[[j]] = NA
        break
        
        # If there are no duplicates create a new cluster with the neighbors
      } else {
        cluster = above_threshold_neighbors[[i]]
      }
    }
    # Add cluster to list of clusters
    clusters = c(clusters, list(cluster))
  }
  
  # Replace clusters smaller than 2 with NA
  for (i in 1:length(clusters)) {
    if (length(clusters[[i]]) < 2) {
      clusters[[i]] = NA
    }
  }
  # Remove NAs
  clusters = clusters[!is.na(clusters)]
}


