# get_clusters <- function(method = "cross_correlation") {

## DESCRIPTION:
##  Identify clusters of spatially contiguous channels that show condition-dependent verdicality
## 
## INPUT:
##  level (char) - "G"/"S" for constraint, "M"/"N" for meaning, "S"/"T" for talker 
##
## OUTPUT:


## TMP:
abs = TRUE
method = "cross_correlation"
condition = "talker"
level = "S"
threshold = 0.15
hemisphere = "both"


## FUNCTIONS:
get_channels <- function() {
  channels_fp <- "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates_areas.txt"
  channels <- read.delim(channels_fp, header = TRUE) %>%
    rename(id = channels)
  channels$id <- substr(channels$id, 2, 5)
  channels <- channels[-c(1:3, 132), ]
  rownames(channels) <- NULL
  
  return(channels) }

get_distance_scores <- function(channels) {
  coordinates <- select(channels, x, y, z)
  distances <- as.matrix(dist(coordinates)) # calculate pairwise distances
  distance_scores <- 1/distances # apply inverse
  distance_scores[distance_scores == Inf] <- 0
  distance_scores <- normalize(distance_scores)
  
  return(distance_scores) }

normalize <- function(x) {return(x / (max(x) - min(x)))}

get_correlations <- function(condition, level) {
  correlations_fp <- paste("data/aggregate/", method, "_data.csv", sep = "")
  correlations <- read.csv(correlations_fp) %>%
    aggregate(., by = list(.[[condition]]), FUN = "mean")
  rownames(correlations) <- correlations$Group.1
  correlations <- subset(correlations, rownames(correlations) %in% c(level)) %>%
    select(-c(Group.1, subject_number, constraint, meaning, talker))
  colnames(correlations) <- 1:128
  
  return(correlations) }

get_similarity_scores <- function(correlations) {
  # IF NEGATIVE CORRELATIONS ARE NOT MEANINGFUL
  # similarity_scores <- sapply(correlations, function(x) {sapply(correlations, function(y) {x^1.5+y^1.5})}) %>%
  similarity_scores <- sapply(correlations, function(x) {sapply(correlations, function(y) {x^3+y^3})}) %>%
    normalize()
  colnames(similarity_scores) <- 1:128
  rownames(similarity_scores) <- NULL
  
  return(similarity_scores) }

get_edge_weights <- function(distance_scores, similarity_scores) {
  edge_weights <- distance_scores * similarity_scores
  edge_weights <- normalize(edge_weights)
  # edge_weights[,25] <- 0
  # edge_weights[25,] <- 0
  
  return(edge_weights) }

get_drops <- function(hemisphere) {
  channels_fp <- "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates_areas.txt"
  channels <- read.delim(channels_fp, header = TRUE) %>%
    rename(id = channels)
  channels$id <- substr(channels$id, 2, 5)
  channels <- channels[-c(1:3, 132), ]
  
  if (hemisphere == "left") {
    drops <- which(channels$x > -50)
  } else if (hemisphere == "right") {
    drops <- which(channels$x < 10)
  } else if (hemisphere == "both") {
    drops <- 129 }
  
  return(drops)
}

get_links <- function(edge_weights, drops, threshold, abs) {
  links <- data.frame("from" = integer(), "to" = integer(), "weight" = double())
  for (i in 1:nrow(edge_weights)) {
    for (j in 1:nrow(edge_weights)) {
      if (i <= j) { next }
      else if (i %in% drops | j %in% drops) { next }
      else if (abs == TRUE) {
        if (abs(edge_weights[i, j]) > threshold) {
          links[nrow(links)+1,] <- c(i, j, edge_weights[i, j])
        }
      } else if (edge_weights[i, j] > threshold) {
        links[nrow(links)+1,] <- c(i, j, edge_weights[i, j])
      }
    }
  }
  return(links)
}

get_nodes <- function(channels, drops) {
  nodes <- channels[-c(drops),]
  
  return(nodes)
}

get_layout <- function(hemisphere, drops) { 
  coordinates <- read.delim("data/aggregate/electrode_points", header = FALSE)
  colnames(coordinates) <- c("x", "y")
  layout <- as.matrix(coordinates) 
  
  return(layout)
}

get_sizes <- function(correlations, abs) {
  if (abs == TRUE) {
    sizes <- t(abs(correlations))*900
  } else if (abs == FALSE) {
    sizes <- t(correlations)*900
    sizes[sizes < 0] <- 0
  }
  
  return(sizes)
}

get_colors <- function(channels) {
  colors <- c()
  areas <- c("Frontal", "Supp", "Postcentral", "Precentral", "Temporal",
                      "SupraMarginal", "Parietal", "Cerebelum", "Angular", 
                      "Precuneus", "Occipital", "Lingual")
  area_color <- c("gray50", "gold", "gold4", "green4", "purple", "green3",
                      "goldenrod1", "coral", "purple4", "lightgoldenrod1",
                      "red3", "gray35")
  for (i in 1:nrow(channels)) {
    if (strsplit(channels$aal.label, "_")[[i]][1] == "Temporal" &
        strsplit(channels$aal.label, "_")[[i]][2] == "Pole") {
      color[i] <- "medium"
    }
    color <- area_color[which(areas == strsplit(channels$aal.label, "_")[[i]][1])]
    colors[i] <- color
  }
  return(colors)
}


## SOURCE:
options(warn=-1)
setwd("/Applications/eeglab2019/talker-change-data-processing")
library('dplyr') 
library('igraph')
library('ndtv')


## MAIN:
channels <- get_channels()
correlations <- get_correlations(condition, level)
distance_scores <- get_distance_scores(channels)
similarity_scores <- get_similarity_scores(correlations)
edge_weights <- get_edge_weights(distance_scores, similarity_scores)


## PLOT:
drops <- get_drops(hemisphere)
links <- get_links(edge_weights, drops, threshold, abs)
nodes <- get_nodes(channels, drops)
layout <- get_layout()
sizes <- get_sizes(correlations, abs)
colors <- get_colors(channels)

# Histogram
title <- paste("cross correlation values of electrodes in ", condition, "_", level, sep = "")
hist(as.matrix(correlations), main = title, xlim = c(-0.1, 0.1))

# Map
net <- graph_from_data_frame(d = links, vertices = nodes, directed = F) %>%
  simplify(., remove.multiple = F, remove.loops = T)
plot(net, 
     edge.arrow.size = .4,
     vertex.color = colors,
     # vertex.color = rgb(0, 0.128, 0.255, alpha =.5),
     vertex.frame.color = rgb(0, 0, 0, alpha = 0),
     vertex.size = sizes,
     alpha = 0.5,
     layout = layout,
     vertex.size = 10,
     edge.width = links$weight*30, 
     vertex.label.family = "Helvetica"
)

# }


