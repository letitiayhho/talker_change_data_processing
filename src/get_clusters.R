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
  threshold = 0.20
  hemisphere = "all"
  
  
  ## FUNCTIONS:
  library(dplyr) 
  
  
  get_coordinates <- function() {
    # Load and clean up data
    coordinates_fp <- "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates.txt"
    coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
      .[startsWith(as.character(.$V2), "E"), ] %>%
      select(V3, V4, V5)
    colnames(coordinates) <- c("y", "x", "z")
    rownames(coordinates) <- 1:128
    
    # coordinates_fp <- file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate/average_channel_locations.sfp")
    # coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
    #   .[startsWith(as.character(.$V1), "E"), ] %>%
    #   .[c("V2", "V3", "V4")]
    # colnames(coordinates) <- c("x", "y", "z")
    # rownames(coordinates) <- 1:128
    # 
    return(coordinates) }
  
  
  get_distance_scores <- function(coordinates) {
    distances <- as.matrix(dist(coordinates)) # calculate pairwise distances
    distance_scores <- 1/distances # apply inverse
    distance_scores[distance_scores == Inf] <- 0
    distance_scores <- normalize(distance_scores)
    rownames(distance_scores) <- 1:128
    colnames(distance_scores) <- 1:128

    return(distance_scores) }
  
  normalize <- function(x) {return(x / (max(x) - min(x)))}
  
  get_correlations <- function(condition, level) {
    # Load data, average over subjects and tidy up
    correlations_fp <- paste("data/aggregate/", method, "_data.csv", sep = "")
    correlations <- read.csv(correlations_fp) %>%
      aggregate(., by = list(.[[condition]]), FUN = "mean")
    rownames(correlations) <- correlations$Group.1
    correlations <- subset(correlations, rownames(correlations) %in% c("S"), select = -c(Group.1, subject_number, constraint, meaning, talker))
      
    return(correlations) }
  
  
  get_similarity_scores <- function(condition, level) {
    correlations <- get_correlations(condition, level)
    similarity_scores <- sapply(correlations, function(x) {sapply(correlations, function(y) {x^3+y^3})}) %>%
      normalize()
    rownames(similarity_scores) <- 1:128
    colnames(similarity_scores) <- 1:128
    
    return(similarity_scores) }
  
  
  get_edge_weights <- function(distance_scores, similarity_scores, threshold) {
    edge_weights <- distance_scores * similarity_scores
    edge_weights <- normalize(edge_weights)
    # edge_weights[,25] <- 0
    # edge_weights[25,] <- 0
    
    return(edge_weights) }
  
  get_links <- function(edge_weights, drops) {
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
  
  get_drops <- function(hemisphere, coordinates) {
    if (hemisphere == "left") {
      drops <- which(coordinates$x > 0)
    } else if (hemisphere == "right") {
      drops <- which(coordinates$x < 0)
    } else if (hemisphere == "none") {
      drops <- 0 }
  }
  
  get_nodes <- function(hemisphere) {
    nodes_fp <- "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates_areas.txt"
    nodes <- read.delim(nodes_fp, header = TRUE) 
    
    # Filter out nodes from other hemisphere if specified
    if (hemisphere == "left") {
      nodes <- filter(nodes, x < 0)
    } else if (hemisphere == "right") {
      nodes <- filter(nodes, x > 0)
    } else if (hemisphere == "none") {
      next }
    
    # Clean up
    # nodes <- select(nodes, channels, aal.label, ba.label) %>%
    #   rename(id = channels)
    # nodes$id <- substr(nodes$id, 2, 5)
    nodes <- nodes[-c(1:3, 132), ]
    
    
    return(nodes)
  }
  
  get_layout <- function(hemisphere) { # INTEGRATE DROPS
    layout <- get_coordinates()
    if (hemisphere == "left") {
      layout <- filter(layout, x < 0) %>% select(x, z)
    } else if (hemisphere == "right") {
      layout <- filter(layout, x > 0) %>% select(x, z)
    } else if (hemisphere == "all") {}
      # z <- abs(layout$X)^1.5 + abs(layout$Y)^1.5
      # layout$X <- layout$X/layout$Z
      # layout$Y <- layout$Y/layout$Z
      # layout <- as.matrix(layout) }

    # layout <- get_coordinates() %>%
      # filter(x < 0) %>% # FILTER RIGHT HEMISPHERE
      # select(x, z)
    # z <- abs(layout$X)^1.5 + abs(layout$Y)^1.5
    # layout$X <- layout$X/layout$Z
    # layout$Y <- layout$Y/layout$Z
    # layout <- as.matrix(layout)
    
    return(layout)
  }

    
    ## SOURCE:
    options(warn=-1)
    setwd("/Applications/eeglab2019/talker-change-data-processing")
    library('igraph')
    library('ndtv')
  
  
    ## MAIN:
    coordinates <- get_coordinates()
    distance_scores <- get_distance_scores(coordinates)
    similarity_scores <- get_similarity_scores(condition, level)
    edge_weights <- get_edge_weights(distance_scores, similarity_scores, threshold)

    
    ## PLOT:
    drops <- get_drops(hemisphere, coordinates)
    links <- get_links(edge_weights, drops)
    nodes <- get_nodes(hemisphere)
    layout <- get_layout(hemisphere)
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


