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
  threshold = 6
  hemisphere = "none"
  
  
  ## FUNCTIONS:
  library(dplyr) 
  
  
  get_coordinates <- function() {
    # Load and clean up data
    coordinates_fp <- file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate/average_channel_locations.sfp")
    coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
      .[startsWith(as.character(.$V1), "E"), ] %>%
      .[c("V2", "V3", "V4")]
    colnames(coordinates) <- c("X", "Y", "Z")
    rownames(coordinates) <- NULL
    
    return(coordinates) }
  
  
  get_distance_scores <- function(coordinates) {
    distances <- as.matrix(dist(coordinates)) # calculate pairwise distances
    distance_scores <- 1/distances %>% # apply inverse
      normalize() # normalize?
    rownames(distance_scores) <- 1:128
    colnames(distance_scores) <- 1:128

    return(distance_scores) }
  
  normalize <- function(x) {return((x - min(x)) / (max(x) - min(x)))}
  
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
    similarity_scores <- sapply(correlations, function(x) {sapply(correlations, function(y) {x^3+y^3})})
    
    return(similarity_scores) }
  
  
  get_edge_weights <- function(distance_scores, similarity_scores, threshold) {
    edge_weights <- distance_scores * similarity_scores
    edge_weights <- edge_weights*1e+05 # (scale?)
    edge_weights[edge_weights == -Inf | edge_weights == Inf] <- 0
    # edge_weights[,25] <- 0
    # edge_weights[25,] <- 0
    
    return(edge_weights) }
  
  get_links <- function(edge_weights, drops) {
    links <- data.frame("from" = integer(), "to" = integer(), "weight" = double())
    for (i in 1:nrow(edge_weights)) {
      for (j in 1:nrow(edge_weights)) {
        if (i <= j) { next
        } else if (i %in% drops | j %in% drops) {next 
        } else if (abs(edge_weights[i, j]) > threshold) {
          links[nrow(links)+1,] <- c(i, j, edge_weights[i, j]) }
      }
    }
    return(links)
  }
  
  get_nodes <- function() {
    nodes_fp <- "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates_areas.txt"
    nodes <- read.delim(nodes_fp, header = TRUE) %>%
      filter(x < 0) %>% # FILTER RIGHT HEMISPHERE
      select(channels, aal.label, ba.label) %>%
      rename(id = channels)
    nodes$id <- substr(nodes$id, 2, 5)
    nodes <- nodes[-c(1:3, 132), ]
    return(nodes)
  }
  
  get_drops <- function(hemisphere, coordinates) {
    if (hemisphere == "left") {
      drops <- which(coordinates$X > 0)
    } else if (hemisphere == "right") {
      drops <- which(coordinates$X < 0)
    } else if (hemisphere == "none") {
      drops <- 0
    }
  }
  
  get_layout <- function(drops) { # INTEGRATE DROPS
    layout <- get_coordinates() %>%
      filter(X < 0) %>% # FILTER RIGHT HEMISPHERE
      select(X, Z)
    # z <- abs(layout$X)^1.5 + abs(layout$Y)^1.5
    # layout$X <- layout$X/layout$Z
    # layout$Y <- layout$Y/layout$Z
    layout <- as.matrix(layout)
    
    return(layout)
  }

    
    ## SOURCE:
    options(warn=-1)
    setwd("/Applications/eeglab2019/talker-change-data-processing")
    library('igraph')
    library('ndtv')
  
  
    ## MAIN:
    coordinates <- get_coordinates()
    drops <- get_drops(hemisphere, coordinates)
    distance_scores <- get_distance_scores(coordinates)
    similarity_scores <- get_similarity_scores(condition, level)
    edge_weights <- get_edge_weights(distance_scores, similarity_scores, threshold)

    
    ## PLOT:
    links <- get_links(edge_weights, drops)
    nodes <- get_nodes()
    layout <- get_layout()
    net <- graph_from_data_frame(d = links, vertices = nodes, directed = F) %>%
      simplify(., remove.multiple = F, remove.loops = T)
    plot(net, edge.arrow.size=.4, layout = layout, edge.width = links$weight/2, vertex.label.family = "Helvetica")
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


