get_nearest_cortical_areas <- function(radius = 10) {
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
    coordinates_fp <- "/Users/letitiaho/src/talker-change-data-processing/3_channel_locations/data/mni_coordinates.txt"
    coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
      subset(substr(V2, 1, 1) == "E") %>%
      select(V2, V3, V4, V5)
    colnames(coordinates) <- c("channels", "y", "x", "z")
    return(coordinates) }

  get_min_distance <- function() {
    nearest_areas <- read.delim("/Users/letitiaho/src/talker-change-data-processing/3_channel_locations/data/mni_coordinates_areas.txt")
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

        # Exclude results more than 4 cm away from reference point, 5 cm away from centroid
        label <- ifelse(length(result$label) == 0 | result$distance > 40, "NULL", result$label)
        return(label)
      }
    )
    label <- unlist(label)
    return(label)
  }

  label_sphere <- function(sphere_coordinates) {
    aal.label <- list()
    ba.label <- list()
    for (i in 1:length(sphere_coordinates)) {
      channel <- sphere_coordinates[[i]]
      channel_labels <- apply(channel, MARGIN = 1, FUN = label_one_point)
      aal.label <- c(aal.label, list(unique(channel_labels[1,])))
      ba.label <- c(ba.label, list(unique(channel_labels[2,])))
    }
    return(labels = list(aal.label = aal.label,
                         ba.label = ba.label))
  }

  round <- function(x) as.integer(trunc(x+0.5)) # Avoid round to even


  ## SOURCE:
  setwd('/Users/letitiaho/src/talker-change-data-processing')
  source('/Users/letitiaho/src/label4MRI/R/mni_to_region_index.R')
  source('/Users/letitiaho/src/label4MRI/R/label4mri_metadata.R')
  library(dplyr)
  library(label4MRI)


  ## MAIN:
  coordinates <- get_coordinates()
  min_distance <- get_min_distance()
  sphere_coordinates <- mapply(get_sphere_coordinates,
                               radius,
                               min_distance,
                               x = coordinates$x,
                               y = coordinates$y,
                               z = coordinates$z,
                               SIMPLIFY = FALSE)
  labels <- label_sphere(sphere_coordinates)


  ## SAVE:
  aal <- labels[["aal.label"]]
  ba <- labels[["ba.label"]]
  save(aal, file = '3_channel_locations/data/mni_coordinates_areas_aal.RData')
  save(ba, file = '3_channel_locations/data/mni_coordinates_areas_ba.RData')

}

