get_mni_cortical_areas <- function(save_file = "mni_coordinates_areas_2.txt") {
  get_coordinates <- function() {
    coordinates_fp <- "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/mni_coordinates.txt"
    coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".") %>%
      select(V2, V3, V4, V5)
    colnames(coordinates) <- c("channels", "y", "x", "z")
    return(coordinates) }
  
  # Load in packages and data
  library(label4MRI)
  source('/Applications/eeglab2019/talker-change-data-processing/src/get_mni_coordinates.R', echo=TRUE)

  # Load coordinates
  coordinates <- get_coordinates()
  
  # Get labels
  labels <- t(mapply(FUN = mni_to_region_name, x = coordinates$x, y = coordinates$y, z = coordinates$z))
  
  # Save
  coordinates = cbind(coordinates, labels)
  save_file_fp = file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate/", save_file)
  write.table(format(coordinates, digits = 2), file = save_file_fp, append = FALSE, sep = "\t", col.names = TRUE, quote = FALSE)
  }