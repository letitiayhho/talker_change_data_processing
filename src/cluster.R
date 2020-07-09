get_clusters <- function(condition,
                         method = "euclidean",
                         distance = 3.5,
                         alpha = 0.05,
                         n = 11,
                         min_cluster_size = 2) {
  
  
  ## DSECRIPTION:
  ##  Identify clusters of spatially contiguous channels that show condition-dependent verdicality
  ## 
  ## INPUT:
  ##  condition (string) - "constraint", "meaning", or "talker"
  ##  method (string) - "euclidean", "rank", or "density" (optional, default = "euclidean")
  ##  distance (double) - distance between neighboring electrodes, see histogram function (optional, default = 3.5)
  ##  alpha (double) - significance level at which to include channels in clusters (optional, default = 0.05)
  ##  n (int) - sample size (optional, default = 11)
  ##  min_cluster_size (int) - smallest cluster size to output (optional, default = 2)
  ##
  ## OUTPUT:
  ##  (list) - list of lists containing the numbers of channels in each cluster
  
  
  ## FUNCTIONS:
  get_t_values <- function(condition) {
    t_values_raw <- read.csv("/Applications/eeglab2019/talker-change-data-processing/data/cluster_t_values.csv")
    
    # Get t_values for specified condition
    if (condition == "constraint"){
      t_values = t_values_raw[1,]
    } else if (condition == "meaning") {
      t_values = t_values_raw[2,]
    } else if (condition == "talker") {
      t_values = t_values_raw[3,]
    }
    
    # Return
    return(t_values)
  }
  
  
  get_coordinates <- function() {
    coordinates_fp <- file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate/average_channel_locations.sfp")
    coordinates_raw <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
      .[startsWith(as.character(.$V1), "E"), ]
    coordinates <- cbind(coordinates_raw$V2, coordinates_raw$V3, coordinates_raw$V4)
    
    # Return
    return(coordinates)
  }
  
  
  get_pairwise_distances <- function(coordinates) {
    distances <- as.matrix(dist(coordinates))
    
    # Return
    return(distances)
  }
  
  
  get_histogram_of_pairwise_distances <- function(distances) {
    sort_distances = as.vector(distances) %>%
      .[!duplicated(.)] %>%
      sort() %>%
      hist(., breaks = 50, main = "Histogram of pairwise distances")
  }
  

  actual_get_clusters <- function(distance, alpha, n, min_cluster_size, distances, t_values) {
    
    # Determine threshold for t-values based on specified alpha significance level
    t_threshold <- qt(1-(alpha/2)/1, df = n-1)
    
    # Identify neighboring channels of each electrode with t-values above threshold
    above_threshold_neighbors <- vector(mode = "list", length = nrow(distances))
    for (i in 1:nrow(distances)) {
      
      # Identify neighboring channels within the specified radius
      neighboring_channels = which(distances[i, ] < distance)
      
      # Subsetting the channels
      above_threshold_neighbors_indexes = which(abs(t_values[neighboring_channels]) > t_threshold)
      above_threshold_neighbors_for_each_channel = list(neighboring_channels[above_threshold_neighbors_indexes])
      above_threshold_neighbors[i] = above_threshold_neighbors_for_each_channel
    }
    
    # Loop through neighbors
    clusters <- vector(mode = "list")
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
          clusters[[j]] <- NA
          break
          
          # If there are no duplicates create a new cluster with the neighbors
        } else {
          cluster <- above_threshold_neighbors[[i]]
        }
      }
      
      # Add cluster to list of clusters
      clusters <- c(clusters, list(cluster))
    }
    
    # Replace clusters smaller than 2 with NA
    for (i in 1:length(clusters)) {
      if (length(clusters[[i]]) < 2) {
        clusters[[i]] <- NA
      }
    }
    
    # Remove NAs
    clusters <- clusters[!is.na(clusters)]
    
    # Return
    return(clusters)
  }
  
  
  ## MAIN:
  t_values <- get_t_values(condition)
  coordinates <- get_coordinates()
  distances <- get_pairwise_distances(coordinates)
  get_histogram_of_pairwise_distances(distances)
  clusters <- actual_get_clusters(distance, alpha, n, min_cluster_size, distances, t_values)
  return(clusters)
}


