# get_nearest_cortical_areas <- function(radius = 5, x, y, z) {
  #' DESCRIPTION:
  #'  Get closest cortical areas to each channel based on its MNI coordinate
  #'
  #' INPUT:
  #'  radius (int) - radius around channel to search for labeled cortical areas
  #'  save_file (char) - name of the file to write labels to (optional, default - NULL)
  #'
  #' OUTPUT:
  #'  (table) - table containing the original mni coordinates, aal.label, aal.distance,
  #'    ba.label, ba.distance of each channel
  
  ## FUNCTIONS:
  get_coordinates <- function() {
    coordinates_fp <- "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates.txt"
    coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
      subset(substr(V2, 1, 1) == "E") %>%
      select(V2, V3, V4, V5)
    colnames(coordinates) <- c("channels", "y", "x", "z")
    return(coordinates) }
  
  get_min_distance <- function() {
    nearest_areas <- read.delim('/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates_areas.txt')
    min_distance <- min(nearest_areas$aal.distance)
    return(min_distance)
  }
  
  get_sphere_coordinates <- function(radius, min_distance, x, y, z) {
    # Get center
    x <- round(x)
    y <- round(y)
    z <- round(z)
    centroid <- c(x, y, z)
    
    # Get first possible point within a cortical area
    centroid_distance_to_origin <- dist(rbind(centroid, c(0, 0, 0)))
    unit_vector <- centroid/centroid_distance_to_origin
    ref <- centroid-(unit_vector*min_distance)
    ref_proxy_distance_to_origin <- sum(abs(ref))
    radius_sq <- radius^2
    
    # Get surrounding coordinates
    sphere_coordinates <- data.frame('x' = x, 'y' = y, 'z' = z)
    for (i in seq(from = x-radius, to = x+radius, by = 2)) {
      for (j in seq(from = y-radius, to = y+radius, by = 2)) {
        for (k in seq(from = z-radius, to = z+radius, by = 2)) {
          new_point <- c(i, j, k)
          
          # Calculate distance to centroid
          proxy_distance_to_centroid <- sum((centroid - new_point)^2)
          proxy_distance_to_origin <- sum(abs(new_point))
          
          # Keep the new point if it is within a certain radius of the
          # centroid and if it is closer than ref to the origin
          if(proxy_distance_to_centroid <= radius_sq & 
             proxy_distance_to_origin <= ref_proxy_distance_to_origin) {
            sphere_coordinates <- rbind(sphere_coordinates, new_point)}
        }
      }
    }
    
    # Get lowest quarter of abs coordinates (quarter closest to origin)
    return(sphere_coordinates)
  }
  
  label_one_point <- function(coordinate) {
    template <- c("aal", "ba")
    label <- lapply(
      template,
      function(.template) {
        # Extract coordinates
        x <- coordinate[1]
        y <- coordinate[2]
        z <- coordinate[3]
        
        # Adds index and distance to result
        result <- mni_to_region_index(x, y, z, distance = T, .template)
        df_region_index_name <- label4mri_metadata[[.template]]$label
        
        # Adds region label to result
        result$label <- as.character(
          df_region_index_name[
            df_region_index_name$Region_index == result$index,
            "Region_name"
            ]
        )
        label <- ifelse(length(result$label) == 0, "NULL", result$label)
        return(label)
      }
    )
    label <- unlist(label)
    return(label)
  }
  
  label_sphere <- function(sphere_coordinates) {
    # labels <- data.frame("aal.label" = c(), "ba.label" = c())
    aal.label <- list()
    ba.label <- list()
    for (i in 1:length(sphere_coordinates)) {
      channel <- sphere_coordinates[[i]]
      channel_labels <- apply(channel, MARGIN = 1, FUN = label_one_point)
      aal.label <- c(aal.label, list(unique(channel_labels[1,])))
      ba.label <- c(ba.label, list(unique(channel_labels[2,])))
      
      # unique_channel_labels <- c(list(unique(channel_labels[1,])), list(unique(channel_labels[2,])))
      # labels <- rbind(labels, unique_channel_labels)

      # unique_channel_labels <- data.frame("aal.label" = list(unique(channel_labels[1,])),
                                    # "ba.label" = list(unique(channel_labels[2,])))
      # labels <- rbind(labels, unique_channel_labels)
    }
    return(labels = list(aal.label = aal.label,
                         ba.label = ba.label))
  }
  
  round <- function(x) as.integer(trunc(x+0.5)) # Avoid round to even
  
  
  ## SOURCE:
  source('/Users/letitiaho/src/label4MRI/R/mni_to_region_index.R')
  source('/Users/letitiaho/src/label4MRI/R/label4mri_metadata.R')
  library(dplyr)
  library(label4MRI)
  
  
  ## TMP:
  radius <- 10 # in mm
  
  
  ## MAIN:
  start_time <- Sys.time()
  coordinates <- get_coordinates()
  # coordinates <- data.frame("x" = 26, "y" = 0, "z" = 0)
  min_distance <- get_min_distance()
  sphere_coordinates <- mapply(get_sphere_coordinates,
                               radius,
                               min_distance,
                               x = coordinates$x[1:2],
                               y = coordinates$y[1:2],
                               z = coordinates$z[1:2],
                               SIMPLIFY = FALSE)
  labs <- label_sphere(sphere_coordinates)
  end_time <- Sys.time()
  end_time - start_time
  
  
  
  ## RETURN:
  # return(sphere_coordinates)
  
  # result <- unlist(r_indexes, recursive = F)
  # names(result) <- paste(
  #   rep(template, each = 1),
  #   rep(c("label"), length(template)),
  #   sep = "."
  # )
  
  
  # result <- t(result)
  # return(result)
# }

