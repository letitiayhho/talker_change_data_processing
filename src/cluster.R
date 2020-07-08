# get_clusters = function(distance, min_cluster_size, t_threshold) {

  ## RECOMMENDED DISTANCE = 5 (see histogram)
  distance = 4
  t_threshold = 2.2281 # 0.05
  ## 0.1, 0.01 or 0.05, enter DF (n-1), enter alpha, get two-sided t
  condition = "talker"
  
  library(dplyr)
  
  ## Load data
  setwd("/Applications/eeglab2019/talker-change-data-processing")
  t_values_raw = read.csv("data/cluster_t_values.csv")
  coords_raw = read.delim("data/302/channel_locations.sfp", header = FALSE, sep = "", dec = ".") %>%
    .[startsWith(as.character(.$V1), "E"), ]

  ## Get pairwise Euclidean distance
  coords = cbind(coords_raw$V2, coords_raw$V3, coords_raw$V4)
  distances = as.matrix(dist(coords))
  
  ## Get histogram of pairwise distances
  # sort_distances = as.vector(distances) %>%
  #   .[!duplicated(.)] %>%
  #   sort() %>%
  #   hist(., breaks = 50, main = 'Histogram of pairwise distances')

  ## Get t_values
  if (condition == 'constraint'){
    t_values = t_values_raw[1,]
  } else if (condition == 'meaning') {
    t_values = t_values_raw[2,]
  } else if (condition == 'talker') {
    t_values = t_values_raw[3,]
  }

  ## Get clusters
  above_threshold_neighbors = vector(mode = "list", length = nrow(distances))
  for (i in 1:nrow(distances)) {
    neighboring_channels = which(distances[i,] < distance)
    above_threshold_neighbors_indexes = which(abs(t_values[neighboring_channels]) > 2)
    above_threshold_neighbors_for_each_channel = list(neighboring_channels[above_threshold_neighbors_indexes])
    above_threshold_neighbors[i] = above_threshold_neighbors_for_each_channel
  }

  clusters = vector(mode = "list")
  # List 1: above threshold neighbors for each channel
  # List 2: compiled clusters

  # Loop through neighbors
  for (i in 1:length(above_threshold_neighbors)) {
    
    # Continue if neighbors is an empty list
    if (length(above_threshold_neighbors[[i]]) == 0) {next}
    
    # Check if there is overlap with any cluster
    
      # Create one long vector of all clusters
    
    
    
      
    # Loop through existing clusters to identify cluster with overlap
    for (j in 1:nrow(clusters)) {
      
      # Add each neighbor to each cluster and see if there are duplicates
      comparison = c(above_threshold_neighbors[[i]], clusters[[j]])

      if (FALSE %in% duplicated(comparison)) {  # If there are no duplicates create a new cluster with the neighbors
        cluster = above_threshold_neighbors[[i]]
      } else if (TRUE %in% duplicated(duplicates)) { # If there are duplicates keep the cluster merged and remove duplicates
        cluster = unique(comparison)
      }
      clusters = c(clusters, cluster)
    }
  }
    
    
    
    # Read through each value in the clusters
    # Loop through values within each cluster
      # If read value is in a cluster,
    # final_list = c(final_list, cluster)
  # }

