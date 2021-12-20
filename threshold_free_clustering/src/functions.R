get_coordinates <- function() {
  # setwd("/Users/letitiaho/src/talker_change_data_processing/")
  # read.delim("3_channel_locations/data/average_channel_locations.sfp")
  coordinates_fp <- file.path("3_channel_locations/data/average_channel_locations.sfp")
  coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
    .[startsWith(as.character(.$V1), "E"), ] %>%
    .[c("V2", "V3", "V4")]
  names(coordinates) <- c("x", "y", "z")
  
  # Return
  return(coordinates)
}


get_pairwise_distances <- function(coordinates) {
  distances <- as.matrix(dist(coordinates))
  rownames(distances) <- NULL
  colnames(distances) <- NULL
  
  # Return
  return(distances)
}

get_histogram_of_pairwise_distances <- function(distances, title) {
  sort_distances <- as.vector(distances) %>%
    .[!duplicated(.)] %>%
    sort()
  plot <- ggplot(data.frame(sort_distances), aes(x = sort_distances)) +
    geom_histogram() +
    ggtitle(title)
  return(plot)
}

get_distance_score <- function(distances) {
  # Standardize score from 0 to 1
  st_distances <- (distances-min(distances, na.rm = TRUE))/(max(distances, na.rm = TRUE)-min(distances, na.rm = TRUE))
 
  # Take inverse
  distance_score <- 1/st_distances
  
  # Remove lower triangle
  distance_score[lower.tri(distance_score, diag = TRUE)] <- NaN
  
  return(distance_score)
}

sigmoid <- function(x, spread = sd(x), shift = 0.5) {
  return(1/(1+exp((-x+mean(x))/spread))+shift)
}

standardize <- function(x, new_mean = 0, new_sd = 1) {
  x <- scale(x)
  x <- x*new_sd + new_mean
  return(x)
}

histogram <- function(shuffled_values, original_value = NaN, title = "", xlim = NaN) {
  plot <- ggplot(data.frame(shuffled_values), aes(x = shuffled_values)) +
    geom_histogram(bins = 10) +
    ggtitle(title)
  if (!is.na(original_value)) {
    plot <- plot + geom_vline(xintercept = original_value, color ='firebrick2', size = 2, na.rm = TRUE)
  }
  if (!is.na(xlim)) {
    plot <- plot + xlim(xlim)
  }
  return(plot)
}

get_cluster_scores <- function(distance_scores, weight_scores) {
  # Compute score
  pair_scores <- matrix(NaN, nrow = 128, ncol = 128)
  # for each channel
  for (i in 1:128) {
    # for each channel pair
    for (j in 1:128) {
      # get their distance score
      if (upper.tri(distance_scores)[i, j]) {
        distance_score <- distance_scores[i, j]
        
        # get their combined weights
        weight <- weight_scores[i] * weight_scores[j]
        
        # multiple distance score with combined weights to get their pair score
        pair_score <- distance_score * weight
        
        # sum all the pair scores of the total cluster score
        pair_scores[i, j] <- pair_score
      }
    }
  }
  cluster_scores <- list("sum" = sum(pair_scores, na.rm = TRUE),
                         "max" = max(pair_scores, na.rm = TRUE))
  return(cluster_scores)
}

permute_clusters <- function(distance_scores, weight_scores, reps) {
  permuted_scores <- list("max" = c(), "sum" = c())
  for (i in 1:reps) {
    cat(as.character(i))
    permuted <- sample(weight_scores)
    cluster_scores <- get_cluster_scores(distance_scores, permuted)
    permuted_scores$max <- c(permuted_scores$max, cluster_scores$max)
    permuted_scores$sum <- c(permuted_scores$sum, cluster_scores$sum)
  }
  return(permuted_scores)
}

