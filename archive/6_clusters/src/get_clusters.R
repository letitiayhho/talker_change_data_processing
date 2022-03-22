get_clusters <- function(original, shuffled, neighbors) {
  ## DESCRIPTION:
  ##  Currently gets the size of the largest cluster in each trial for a single subject 
  ##  specified as an input. Can also yield the number of the channels included in the 
  ##  largest cluster.
  ##
  ## INPUT:
  ##  subject_number (char) 
  ##
  ## OUTPUT:
  ##  (numeric) - n_trials long array containing the size of the largest cluster for each trial

  # Identifies significant trials for each channel, easier doing it this way
  # since you can index the original data and resampled data using the same 
  # index. Basically recodes every value in the original data with a bool.
  sig_channels <- original*0
  for (i in 1:128) {
    p <- sapply(original[[i]], FUN = function(x) proportion(shuffled[[i]], x))
    sig <- sapply(p, FUN = function(x) is_sig(x))
    sig_channels[[i]] <- sig
  }
  sig_channels_list <- apply(sig_channels, MARGIN = 1, FUN = function(x) which(x))
  
  
  ## Identify largest clusters
  largest_clusters <- list()
  n_trials = nrow(original)
  for (i in 1:n_trials) {
    active <- get_list_item(sig_channels_list, i)
    
    # Skip trial if number of active channels is less than or equal to 1
    # can"t add empty vector to the end of a nested list for some reason
    if (length(active) <= 1) {
      largest_clusters[i] <- NA
      next
    }
    
    # For each channel get a list of all of its active neighbors
    active_neighbors <- get_active_neighbors(neighbors, active)
    
    # Condense that nested list to find the separate clusters
    clusters <- cluster(active_neighbors)
    
    # Skip trial number of clusters is 0
    if (length(clusters) == 0) {
      largest_clusters[i] <- NA
      next
    }
    
    # Get the largest cluster in that trial
    largest_clusters[i] <- list(get_largest_cluster(clusters))
  }

  ## Get the sizes of the largest clusters
  cluster_sizes <- sapply(largest_clusters, function(x) length(x))
  cluster_sizes[cluster_sizes == 1] <- 0
  
  return(cluster_sizes)
}