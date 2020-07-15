get_mni_coordinates <- function(coordinates_file_name = "average_channel_locations.sfp", 
                                transforms = c(-1.5, -15, -0.5, 0.05, 0.0188603, -1.6, 10.6, 11.5, 10.3), 
                                save_output = FALSE, 
                                save_file = "mni_coordinates.txt") {
  
  ## DESCRIPTION:
  ##  Get MNI coordinates of the average channel locations using the transformation matrix given by DIPFIT in EEGLAB
  ##
  ## INPUT:
  ##  coordinates_file_name (char) - file name of coordinates you want to transform (optional, 
  ##    default = "average_channel_locations.sfp")
  ##  transforms (double) - matrix containing values for c(shiftx, shifty, shiftz, pitch, roll, yaw,...
  ##    scalex, scaley, scalez) (optional, default = c(-1.5, -15, -0.5, 0.05, 0.0188603, -1.6, 10.6, 11.5, 10.3))
  ##  save_output (logical) - whether to write transformed coordinates to a file (optional, default = FALSE)
  ##  save_file (char) - name of file you want to save new coordinates to, column headings are channum, labels,
  ##    y, x, z (optional, default = "mni_coordinates.txt")
  ##
  ## OUTPUT:
  ##  (double) - 3x128 matrix of the transformed x y z coordinates of each electrode
  
  
  ## SOURCE:
  library(dplyr) 
  library(tools)
  
  
  ## FUNCTIONS:
  get_coordinates <- function(coordinates_file_name) {
    coordinates_fp <- file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate/", coordinates_file_name)
    coordinates <- read.delim(coordinates_fp, header = FALSE, sep = "", dec = ".")
    
    # Format data frame depending on file type
    if (file_ext(coordinates_file_name) == "txt") {
      coordinates = coordinates[-c(1)]
      names(coordinates) <- c("channels", "y", "x", "z")
    } else if (file_ext(coordinates_file_name) == "sfp") {
      names(coordinates) <- c("channels", "y", "x", "z")}

    # Return
    return(coordinates)
  }
  
  transform_coordinates <- function(coordinates, transforms) {
    
    # Shift
    shift <- function(coordinates, t) {
      coordinates$x <- coordinates$x + t$shiftx
      coordinates$y <- coordinates$y + t$shifty
      coordinates$z <- coordinates$z + t$shiftz
      
      # Return
      return(coordinates)
    }
    
    # Rotate
    rotate <- function(coordinates, t) {
      rotated_coordinates <- coordinates[c("x", "y", "z")]
      
      # Calculate rotation matrix
      rotate_x <- matrix(c(1, 0, 0, 0, cos(t$pitchx), sin(t$pitchx), 0, -sin(t$pitchx), cos(t$pitchx)), nrow = 3, ncol = 3)
      rotate_y <- matrix(c(cos(t$rolly), 0, -sin(t$rolly), 0, 1, 0, sin(t$rolly), 0, cos(t$rolly)), nrow = 3, ncol = 3)
      rotate_z <- matrix(c(cos(t$yawz), sin(t$yawz), 0, -sin(t$yawz), cos(t$yawz), 0, 0, 0, 1), nrow = 3, ncol = 3)
      R <- rotate_z %*% rotate_y %*% rotate_x
      
      # Check rotation
      pitch = atan2(R[3,2], R[3,3])
      roll = atan2(-R[3,1], sqrt(R[3,2]^2+R[3,3]^2))
      yaw = atan2(R[2, 1], R[1, 1])
      if (abs(pitch - t$pitchx) + abs(roll - t$rolly) + abs(yaw - t$yawz) > 0.001) {stop("The rotation matrix may be incorrect")}
      
      # Rotate coordinates
      rotated_coordinates <- apply(rotated_coordinates, 1, function(x) {R %*% as.matrix(x)})
      coordinates$x <- rotated_coordinates[1,]
      coordinates$y <- rotated_coordinates[2,]
      coordinates$z <- rotated_coordinates[3,]

      # Return
      return(coordinates)
      }
     
    # Scale
    scale <- function(coordinates, t) {
      coordinates$x <- coordinates$x * -t$scalex
      coordinates$y <- coordinates$y * -t$scaley
      coordinates$z <- coordinates$z * t$scalez
      
      # Return
      return(coordinates)
    }
    
    # Rename out transformation parameters
    t <- as.list(transforms)
    names(t) <- c("shiftx", "shifty", "shiftz", "pitchx", "rolly", "yawz", "scalex", "scaley", "scalez")
    
    # Transform
    coordinates <- rotate(coordinates, t)
    coordinates <- scale(coordinates, t)
    coordinates <- shift(coordinates, t)
  }
  
  
  ## MAIN:
  coordinates <- get_coordinates(coordinates_file_name)
  coordinates <- transform_coordinates(coordinates, transforms)
  
  
  ## SAVE:
  if (save_output == TRUE) {
    ## SAVE to read into eeglab, x-coordinates flipped:
    save_file_fp <- file.path("/Applications/eeglab2019/talker-change-data-processing/data/aggregate", "eeglab_mni_coordinates.txt")
    write.table(coordinates, file = save_file_fp, append = FALSE, sep = "\t", col.names = FALSE, quote = FALSE)
    
    ## SAVE actual mni coordinates, x-coordinates not flipped:
    coordinates_formatted <- coordinates[c("channels", "x", "y", "z")]
    coordinates_formatted$x <- coordinates_formatted$x * -1
    write.table(format(coordinates_formatted, digits = 2), file = "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/actual_mni_coordinates.txt", append = FALSE, sep = "\t", col.names = TRUE, quote = FALSE)
  }
  
  # Return
  return(coordinates)
}