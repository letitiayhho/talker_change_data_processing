get_coordinates <- function() {
  coordinates_fp <- file.path("5_cluster_cross_correlatinorons/data/average_channel_locations.sfp")
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

# sigmoid <- function(x, spread = sd(x), shift = 0.5) {
sigmoid <- function(x, spread = 1, shift = 0) {
  return(1/(1+exp((-x+mean(x))/spread))+shift)
}

normalize <- function(x) {
  normed <- (x-min(x))/(max(x)-min(x))
  return(normed)
}

standardize <- function(x, new_mean = 0, new_sd = 1) {
  x <- scale(x)
  x <- x*new_sd + new_mean
  return(x)
}

histogram <- function(x, observed = NaN, xlab = "", title = "", xlim = NaN) {
  plot <- ggplot(data.frame(x), aes(x = x)) +
    geom_histogram(bins = 20) +
    ggtitle(title) +
    xlab(xlab)
  if (!is.na(observed)) {
    plot <- plot + geom_vline(xintercept = observed, color ='firebrick2', size = 2, na.rm = TRUE)
  }
  if (!is.na(xlim)) {
    plot <- plot + xlim(xlim)
  }
  return(plot)
}

compute_chan_scores <- function(distance_scores, weight_scores) {
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
  chan_scores <- c()
  pair_scores[is.na(pair_scores)] <- 0

  for (i in 1:128) {
    chan_scores <- c(chan_scores, sum(pair_scores[i,], pair_scores[,i])/2)
  }

  return(chan_scores)
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
    cat(as.character(i), ", ")
    permuted <- sample(weight_scores)
    cluster_scores <- get_cluster_scores(distance_scores, permuted)
    permuted_scores$max <- c(permuted_scores$max, cluster_scores$max)
    permuted_scores$sum <- c(permuted_scores$sum, cluster_scores$sum)
  }
  return(permuted_scores)
}

