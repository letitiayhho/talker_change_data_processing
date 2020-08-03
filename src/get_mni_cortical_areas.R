get_mni_cortical_areas <- function(radius = 5, save_file = NULL) {
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
  
  
  ## SOURCE:
  library(dplyr)
  library(label4MRI)
  source('~/src/label4MRI/R/mni_to_radius_region_names.R')

  
  ## MAIN:
  coordinates <- get_coordinates()
  # labels <- mapply(mni_to_radius_region_names, x = coordinates$x, y = coordinates$y, z = coordinates$z)
  sphere_mnicoordiantes <- mapply(mni_to_radius_region_names, x = coordinates$x, y = coordinates$y, z = coordinates$z)

  
  ## SAVE:
  # labeled_coordinates <- cbind(coordinates, labels)
  # if (!is.null(save_file)) {
  #   save_file_fp = file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate/", save_file)
  #   write.table(format(coordinates, digits = 2), file = save_file_fp, append = FALSE, sep = "\t", col.names = TRUE, quote = FALSE)
  # }
  
  
  return(sphere_mnicoordiantes)
}