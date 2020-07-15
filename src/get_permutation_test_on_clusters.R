get_permutation_test_on_clusters <- function(condition, sliding_method = "cross_correlation") {
  
  ## DESCRIPTION:
  ##  Conduct a permutation test on the clusters
  ## 
  ## INPUT:
  ##  condition (string) - "constraint", "meaning", or "talker"
  ##  sliding_method (string) - "cross_correlation", "convolution" (optional, default = "cross_correlation")
  ##
  ## OUTPUT:
  ##  p (double) - p-value of permutation test with 1000 permutations
  
  
  ## FUNCTIONS:
  get_t_values <- function(condition, sliding_method) {
    t_values_fn <- paste(sliding_method, "_t_values.csv", sep = "")
    t_values_fp <- file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate", t_values_fn)
    t_values_raw <- read.csv(t_values_fp)
    
    # Get t_values for specified condition
    if (condition == "constraint"){
      t_values <- as.numeric(t_values_raw[1,])
    } else if (condition == "meaning") {
      t_values <- as.numeric(t_values_raw[2,])
    } else if (condition == "talker") {
      t_values <- as.numeric(t_values_raw[3,])
    }
    
    # Return
    return(t_values)
  }
  
  
  get_cluster_statistic <- function(t_values, clusters) {
    
    # Sum t-values in each cluster
    cluster_statistics = c();
    for (i in 1:length(clusters)) {
      cluster_t_sum <- sum(t_values[clusters[[i]]])
      cluster_statistics[i] <- cluster_t_sum
    }

    # Find max summed t-value
    index = which.max(abs(cluster_statistics))
    cluster_statistic = cluster_statistics[index]
    
    # Return
    return(cluster_statistic)
  }
  
  
  get_permuted_cluster_statistic <- function(t_values, condition, sliding_method) {
    # Permute t-values
    permuted_t_values <- sample(t_values)
    
    # Get clusters for new t-values
    permuted_clusters <- get_clusters(permuted_t_values, condition, sliding_method)
    
    # Compute cluster statistic
    permuted_cluster_statistic <- get_cluster_statistic(permuted_t_values, permuted_clusters)
  }
  
  
  ## SOURCE:
  source('/Applications/eeglab2019/talker-change-data-processing/src/get_clusters.R', echo=TRUE)
  library(ggplot2)
  
  
  ## MAIN:
  observed_t_values <- get_t_values(condition, sliding_method)
  observed_clusters <- get_clusters(observed_t_values, condition, sliding_method)
  observed_cluster_statistic <- get_cluster_statistic(observed_t_values, observed_clusters)
  null_values <- replicate(10, get_permuted_cluster_statistic(observed_t_values, condition, sliding_method))


  ## REPORT:
  # Histogram of permutation test
  ggplot(data.frame(null_values), aes(x = null_values)) +
    geom_histogram(bins = 20) +
    geom_vline(xintercept = observed_cluster_statistic, color = 'red')

  # P-value of permutation test
  p <- (sum(abs(null_values) > abs(observed_cluster_statistic)) + 1)/(1000 + 1)

  # constraint_t_values <- get_t_values("constraint", "cross_correlation")
  # constraint_clusters <- get_clusters(constraint_t_values, "constraint", "cross_correlation")
  # return(constraint_clusters)
  
  ## RETURN:
  return(p)
  
}