# get_clusters <- function(method = "cross_correlation") {
  
  ## DESCRIPTION:
  ##  Identify clusters of spatially contiguous channels that show condition-dependent verdicality
  ## 
  ## INPUT:
  ##  level (char) - "G"/"S" for constraint, "M"/"N" for meaning, "S"/"T" for talker 
  ##
  ## OUTPUT:
  
  ## TMP:
  method = "cross_correlation"
  condition = "talker"
  level = "S"
  threshold = 0.02
  hemisphere = "left"
  
  
  ## FUNCTIONS:
  library(dplyr) 
  
  
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
    correlations <- subset(correlations, rownames(correlations) %in% c("S")) %>%
      select(-c(Group.1, subject_number, constraint, meaning, talker))
    colnames(correlations) <- 1:128

    return(correlations) }
  
  get_similarity_scores <- function(condition, level) {
    correlations <- get_correlations(condition, level)
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
      drops <- which(channels$x > 0)
    } else if (hemisphere == "right") {
      drops <- which(channels$x < 0)
    } else if (hemisphere == "both") {
      drops <- 0 }
    
    return(drops)
  }
  
  get_links <- function(edge_weights, drops, threshold) {
    links <- data.frame("from" = integer(), "to" = integer(), "weight" = double())
    for (i in 1:nrow(edge_weights)) {
      for (j in 1:nrow(edge_weights)) {
        if (i <= j) { next }
        else if (i %in% drops | j %in% drops) { next }
        else if (abs(edge_weights[i, j]) > threshold) {
          links[nrow(links)+1,] <- c(i, j, edge_weights[i, j]) }
      }
    }
    return(links)
  }
  
  get_nodes <- function(channels, drops) {
    coordinates <- coordinates[-c(drops),]
    }
  
  get_layout <- function(hemisphere, channels, drops) { 
    coordinates <- select(channels, x, y, z)
    # if (hemisphere == "both") {
    #   # Transform coordinate locations for better plotting
    #   k <- 1+(0.1*((coordinates$x)^2 + (coordinates$y)^2))
    #   coordinates$x <- coordinates$x*k
    #   coordinates$y <- coordinates$y*k
    # } else {
      coordinates <- coordinates[-c(drops),]
    
    # }
    layout <- as.matrix(coordinates) 

    return(layout)
  }

    
    ## SOURCE:
    options(warn=-1)
    setwd("/Applications/eeglab2019/talker-change-data-processing")
    library('igraph')
    library('ndtv')
  
  
    ## MAIN:
    channels <- get_channels()
    distance_scores <- get_distance_scores(channels)
    similarity_scores <- get_similarity_scores(condition, level)
    edge_weights <- get_edge_weights(distance_scores, similarity_scores)

    
    ## PLOT:
    drops <- get_drops(hemisphere)
    links <- get_links(edge_weights, drops, threshold)
    nodes <- get_nodes(channels, drops)
    layout <- get_layout(hemisphere, channels, drops)
    # net <- graph_from_data_frame(d = links, vertices = nodes, directed = F) %>%
      # simplify(., remove.multiple = F, remove.loops = T)
    # plot(net, edge.arrow.size=.4, layout = layout, edge.width = links$weight/2, vertex.label.family = "Helvetica")
    
    
    
    
    # E(net)$width <- E(net)$weight
    
    # net <- network(links,  vertex.attr=nodes, matrix.type="edgelist", 
                    # loops=F, multiple=F, ignore.eval = F)
    # render.d3movie(net, usearrows = F, displaylabels = F, bg="#111111", 
                   # vertex.border="#ffffff", vertex.col =  net %v% "col")
                   # vertex.cex = (net %v% "audience.size")/8, 
                   # edge.lwd = (net %e% "weight")/3, edge.col = '#55555599',
                   # vertex.tooltip = paste("<b>Name:</b>", (net3 %v% 'media') , "<br>",
                   #                        "<b>Type:</b>", (net3 %v% 'type.label')),
                   # edge.tooltip = paste("<b>Edge type:</b>", (net3 %e% 'type'), "<br>", 
                   #                      "<b>Edge weight:</b>", (net3 %e% "weight" ) ),
                   # launchBrowser=F)  
  # }


