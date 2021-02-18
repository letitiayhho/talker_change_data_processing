## 1. 

subset <- function(data, channel, level, shuffle_number = NULL) {
  column_heading <- paste("mean_", channel, sep = "")
  subset <- data[[column_heading]][data$condition == level]
  if (is.null(shuffle_number)) {
    return(data[[column_heading]][data$condition == level])
  } else {
    return(data[[column_heading]][(data$condition == level) & (data$shuffle_number == shuffle_number)])
  }
}

histogram <- function(shuffled_values, original_value, title) {
  ggplot(data.frame(shuffled_values), aes(x = shuffled_values)) +
    geom_histogram(bins = 10) +
    geom_vline(xintercept = original_value, color ='firebrick2', size = 2) +
    ggtitle(title)
}

plot_level <- function(shuffled, original, channel_number, level, title) {
  shuffled_values <- subset(shuffled, channel_number, level)
  original_value <- subset(original, channel_number, level)
  histogram(shuffled_values, original_value, title)
}

plot_channel <- function(shuffled, original, channel_number) {
  same_talker <- plot_level(shuffled, original, channel_number, "S", 
                            paste(channel_number, ": Same Talker", sep = ""))
  different_talker <- plot_level(shuffled, original, channel_number, "T",
                                 paste(channel_number, ": Different Talker", sep = ""))
  meaningful <- plot_level(shuffled, original, channel_number, "M",
                           paste(channel_number, ": Meaningful", sep = ""))
  nonsense <- plot_level(shuffled, original, channel_number, "N",
                         paste(channel_number, ": Nonsense", sep = ""))
  low_constraint <- plot_level(shuffled, original, channel_number, "L",
                               paste(channel_number, ": Low constraint", sep = ""))
  high_constraint <- plot_level(shuffled, original, channel_number, "H",
                                paste(channel_number, ": High constraint", sep = ""))
  
  ggarrange(same_talker, different_talker, 
            meaningful, nonsense,
            low_constraint, high_constraint,
            ncol = 6, nrow = 1)
}

proportion <- function(shuffled_values, original_value) {
  # Changed to median
  if (median(shuffled_values) > original_value) {
    return(sum(shuffled_values < original_value)/length(shuffled_values))
  } else {
    return(sum(shuffled_values > original_value)/length(shuffled_values))
  }
}

is_sig <- function(proportion) {
  ifelse(proportion < 0.05, return(TRUE), return(FALSE))
}

get_proportion <- function(shuffled, original, channel_number, level) {
  shuffled_values <- subset(shuffled, channel_number, level)
  original_value <- subset(original, channel_number, level)
  return(proportion(shuffled_values, original_value))
}

get_channel_proportions <- function(shuffled, original, channel_number) {
  same_talker <- get_proportion(shuffled, original, channel_number, "S")
  different_talker <- get_proportion(shuffled, original, channel_number, "T")
  meaningful <- get_proportion(shuffled, original, channel_number, "M")
  nonsense <- get_proportion(shuffled, original, channel_number, "N")
  low_constraint <- get_proportion(shuffled, original, channel_number, "L")
  high_constraint <- get_proportion(shuffled, original, channel_number, "H")
  return(data.frame("same_talker" = same_talker,
                    "different_talker" = different_talker,
                    "meaningful" = meaningful,
                    "nonsense" = nonsense,
                    "low_constraint" = low_constraint,
                    "high_constraint" = high_constraint))
}

get_all_channel_proportions <- function(shuffled, original) {
  all_channel_proportions <- c()
  for (i in 1:128) {
    channel_proportions <- get_channel_proportions(shuffled, original, as.character(i))
    all_channel_proportions <- rbind(all_channel_proportions, channel_proportions)
  }
  return(all_channel_proportions)
}

plot_graded_table <- function(data) {
  data <- mutate_if(data, is.numeric, function(x) {round(x, digits = 7)}) %>%
    mutate_if(is.numeric, function(x) {ifelse(x > 0.1,
                                              cell_spec(x, NULL),
                                              cell_spec(x, background = spec_color(x,
                                                                                   direction = 1,
                                                                                   begin = 0.65,
                                                                                   end = 1,
                                                                                   option = "B",
                                                                                   scale_from = c(0,0.1))))})
  rownames(data) <- c(1:128)
  kable(data, escape = F, row.names = T) %>%
    kable_styling(bootstrap_options = c("hover", "condensed"), full_width = F)
}

## 2.

get_proportions_overall <- function(shuffled_means, original_means) {
  proportions <- c()
  for (channel in 1:128) {
    variable_name <- paste("mean_", as.character(channel), sep = "")
    proportion <- proportion(shuffled_means[[variable_name]], original_means[[variable_name]])
    proportions <- c(proportions, proportion)
  }
  return(data.frame(proportions))
}

## 3. Which channels distinguish between levels in a condition?

get_levels <- function(condition) {
  levels <- list(talker = c("S", "T"), meaning = c("M", "N"), constraint = c("L", "H"))
  return(levels[[condition]])
}

get_difference <- function(data, channel, condition, shuffle = NULL) {
  levels <- get_levels(condition)
  level_1 <- subset(data, as.character(channel), levels[1], shuffle) 
  level_2 <- subset(data, as.character(channel), levels[2], shuffle) 
  return(level_1 - level_2)
}

get_differences_for_all_shuffles <- function(data, channel, condition) {
  differences <- c()
  n_shuffles <- nrow(data)/6
  for (shuffle in 1:n_shuffles) {
    difference <- get_difference(data, channel, condition, shuffle)
    differences <- c(differences, difference)
  }
  return(differences)
}

plot_level_differences <- function(shuffled, original, channel_number, condition, title) {
  original_value <- get_difference(original, channel_number, condition)
  shuffled_values <- get_differences_for_all_shuffles(shuffled, channel_number, condition)
  histogram(shuffled_values, original_value, title)
}

plot_channel_differences <- function(shuffled, original, channel_number) {
  talker <- plot_level_differences(shuffled, original, channel_number, "talker", 
                                   paste(channel_number, ": Talker", sep = ""))
  meaning <- plot_level_differences(shuffled, original, channel_number, "meaning", 
                                    paste(channel_number, ": Meaning", sep = ""))
  constraint <- plot_level_differences(shuffled, original, channel_number, "constraint", 
                                       paste(channel_number, ": Constraint", sep = ""))
  ggarrange(talker, meaning, constraint, ncol = 3, nrow = 1)
}

get_proportion_differences <- function(shuffled, original, channel_number, condition) {
  original_value <- get_difference(original, channel_number, condition)
  shuffled_values <- get_differences_for_all_shuffles(shuffled, channel_number, condition)
  return(proportion(shuffled_values, original_value))
}

get_channel_proportions_differences <- function(shuffled, original, channel_number) {
  talker <- get_proportion_differences(shuffled, original, channel_number, "talker")
  meaning <- get_proportion_differences(shuffled, original, channel_number,  "meaning")
  constraint <- get_proportion_differences(shuffled, original, channel_number, "constraint")
  return(data.frame("talker" = talker,
                    "meaning" = meaning,
                    "constraint" = constraint))
}

get_all_channel_proportions_differences <- function(shuffled, original) {
  all_channel_proportions_differences <- c()
  for (i in 1:128) {
    channel_proportions <- get_channel_proportions_differences(shuffled, original, as.character(i))
    all_channel_proportions_differences <- rbind(all_channel_proportions_differences, channel_proportions)
  }
  return(all_channel_proportions_differences)
}

## MAPS

get_layout <- function() { 
  fp <- "/Users/letitiaho/src/talker_change_data_processing/3_channel_locations/data/2d_coordinates"
  coordinates <- read.delim(fp, header = FALSE)
  x <- coordinates[[1]]
  y <- -coordinates[[2]]+ 2*mean(coordinates[[2]]) # flip y coords and return to original center
  return(list(x = x, y = y))
}

get_sig_channels <- function(data, variable) {
  sig_channels <- which(data[[variable]] < 0.05)
}

get_ps <- function(data, channels, condition) {
  level <- data[[condition]]
  p_values <- c()
  for (i in 1:128) {
    # Exit early if not in list of significant channels
    if (!(i %in% channels)) {p_values[i] = NaN}
    
    # Recoding values if too small or too large
    else {
      if (level[i] > 0.05) {p_values[i] <- NaN}
      else if (level[i] == 0) {p_values[i] <- 1/210}
      else {p_values[i] <- level[i]}
    }
  }
  return(p_values)
}

## CLUSTERS

get_channel_coordinates <- function() {
  channels_fp <- "/Users/letitiaho/src/talker_change_data_processing/3_channel_locations/data/mni_coordinates.txt"
  channels <- read.delim(channels_fp, header = FALSE) %>%
    filter(grepl('E', V2))
  channel_coordinates <- data.frame(x = channels$V3,
                                    y = channels$V4,
                                    z = channels$V5)
  return(channel_coordinates) }

get_pairwise_distances <- function(channel_coordinates) {
  distances <- as.matrix(dist(channel_coordinates)) # calculate pairwise distances
  return(distances) }

# Neighbors and active channels for each trial are all
# stored as nested lists. Use this function to unpack them
get_list_item <- function(list, channel) {
  unname(list[[channel]])
}

# For each channel identify all its neighbors that are active in a given trial
get_active_neighbors <- function(neighbors, active) {
  active_neighbors <- list()
  for (i in 1:length(active)) {
    # Get array of neighbors of each active channel
    channel <- active[i]
    channel_neighbors <- get_list_item(neighbors, channel)
    
    # Compare active channels to neighbors to identify active neighbors.
    # If there any of a channel's neighbors are active they should
    # be contained in the intersect of the two lists.
    active_neighbors[i] <- list(intersect(active, channel_neighbors))
  }
  return(active_neighbors)
}

# Get all clusters by iterating through the list of active
# neighbors and comparing the clusters pairwise. Combine
# all overlapping clusters, leave non-intersecting
# clusters alone. Apply recursively.
cluster <- function(clusters) {
  for (i in 1:length(clusters)) {
    cluster_a <- clusters[[i]]
    # Loop through every cluster
    for (j in 1:length(clusters)) {
      cluster_b <- clusters[[j]]
      # Compare the two clusters...
      combined <- c(cluster_a, cluster_b)
      # If there are duplicates...
      if (TRUE %in% duplicated(combined) & (j > i)) {
        # Set the first cluster into the merged cluster
        clusters[[i]] <- unique(combined)
        # Set the second cluster to null
        clusters[[j]] <- NA
      }
    }
  }
  # Clean up clusters, remove clusters that are too small
  # prune away empty list positions
  keep <- list()
  for (i in 1:length(clusters)) {
    cluster = clusters[[i]]
    if (length(cluster) > 1) {
      keep <- c(keep, list(cluster))
    }
  }
  clusters <- keep
  
  # Return if all possible clusters are created
  if (!(TRUE %in% duplicated(na.omit(unlist(clusters)))))
    return(clusters)
  
  # Recursively apply function
  return(cluster(clusters))
}

get_largest_cluster <- function(clusters) {
  return(clusters[[which.max(lapply(clusters, function(x) sum(lengths(x))))]])
}

get_neighbors <- function() {
  # Get the x y z coordinates of each channel
  coordinates <- get_channel_coordinates()
  
  # Get their pairwise distances
  distances <- get_pairwise_distances(coordinates)
  
  # Identify the channels that are less than 5 cm away including self
  neighbors <- ifelse(distances < 50, TRUE, FALSE) %>%
    apply(MARGIN = 2, FUN = function(x) which(x))
  return(neighbors)
}

