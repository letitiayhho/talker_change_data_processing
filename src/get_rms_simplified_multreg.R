get_rms_multreg <- function(condition = stop("condition required, options are \"talker\", \"constraint\", \"meaning\""),
                            rms_method = "average") {
  ## DESCRIPTION:
  ##  Compute a multiple regression for each electrode against all three conditions and
  ##  the rms values for all three superior parietal channels (53, 54, 61)
  ##
  ## INPUT: 
  ##  condition (char) - "talker", "constraint", or "meaning"
  ##  rms_method (char) - "average" or individual electrodes "53", "54" or "61"
  ##
  ## OUTPUT:
  ##  saves statistics from the fit into a .csv file

  
  ## FUNCTIONS:
  get_correlations <- function() { 
    correlations <- read.csv("data/aggregate/cross_correlation_data.csv")
    colnames(correlations) <- c("subject_number", "constraint", "meaning", "talker", paste("E", 1:128, sep = ""))
    return(correlations) }
  
  get_rms <- function() {
    rms <- read.csv("data/aggregate/rms/rms_data.csv")
    colnames(rms) <- c("subject_number", "constraint", "meaning", "talker", paste("rms_E", 1:128, sep = ""))
    return(rms) }
  
  get_region_correlations <- function(correlations, temporal_region, condition) {
    # Create a separate data frame for each temporal region
    if (temporal_region == "anterior") {
      channels = c("E38", "E39")
    } else if (temporal_region == "middle") {
      channels = c("E40", "E44", "E45", "E46")
    } else if (temporal_region == "posterior") {
      channels = c("E50", "E51", "E57")
    }
    region_correlations <- select(correlations, subject_number, constraint, meaning, talker, channels) %>%
      mutate(dummy_condition = get_condition_recoding(correlations, condition)) %>%
      pivot_longer(cols = all_of(channels), names_to = "channel", values_to = "correlations")
    
    return(region_correlations)
  }
  
  get_condition_recoding <- function(correlations, condition) {
    # Recoding for one condition, constraint G/S -> 0/1, meaning M/N -> 0/1, talker S/T -> 0/1
    recoded_condition <- c()
    levels <- unique(correlations[[condition]])
    original_condition <- correlations[[condition]]
    recoded_condition[correlations[[condition]] == levels[[1]]] <- 0
    recoded_condition[correlations[[condition]] == levels[[2]]] <- 1
    
    return(recoded_condition)
  }
  
  get_superior_parietal_rms <- function(rms, rms_method) {
    if (rms_method == "average") {
      # Get average RMS values for superior parietal electrodes
      rms <- select(rms, c("rms_E53", "rms_E54", "rms_E61"))
      superior_parietal_rms <- rowMeans(rms)
    } else if (rms_method == "53") {
      # Get RMS values for channel 53
      superior_parietal_rms <- select(rms, "rms_E53") 
      superior_parietal_rms <- as.numeric(superior_parietal_rms$rms_E53)
    } else if (rms_method == "54") {
      # Get RMS values for channel 54
      superior_parietal_rms <- select(rms, "rms_E54") 
      superior_parietal_rms <- as.numeric(superior_parietal_rms$rms_E54)
    } else if (rms_method == "61") {
      # Get RMS values for channel 61
      superior_parietal_rms <- select(rms, "rms_E61") 
      superior_parietal_rms <- as.numeric(superior_parietal_rms$rms_E61)
    }
    
    return(superior_parietal_rms)
  }
  
  get_region_data_frame <- function(temporal_region, rms, rms_method, correlations, condition) {
    region_correlations <- get_region_correlations(correlations, temporal_region, condition)
    superior_parietal_rms <- get_superior_parietal_rms(rms, rms_method)
    print(superior_parietal_rms)
    region_data_frame <- cbind(region_correlations, superior_parietal_rms)
    
    return(region_data_frame)
  }
  
  get_simplified_mult_reg <- function(temporal_region, region_data_frame, rms_method) {
    # Create variables for storing stats
    coeffs <- data.frame(intercept = double(),
                         condition = double(),
                         rms = double())
    p <- data.frame(p_intercept = double(),
                    p_condition = double(),
                    p_rms = double())
    
    # Get IVs
    dummy_condition <- region_data_frame$dummy_condition
    
    # Get RMS IV
    rms <- region_data_frame$superior_parietal_rms
    
    # Get DV
    correlations <- region_data_frame$correlations
    
    # Get mult reg
    fit <- lm(correlations ~ dummy_condition + rms)
    
    # Extract statistics
    rms_method <- rms_method
    temporal_region <- temporal_region
    coeffs[1,] <- unname(fit$coefficients)
    p[1,] <- unname(summary(fit)$coefficients[,"Pr(>|t|)"])
    adj_rsq <- summary(fit)$adj.r.squared
    f <- unname(glance(fit)$statistic)
    p_f <- unname(glance(fit)$p.value)
    
    # Bind into one data frame
    fit <- cbind(rms_method, temporal_region, coeffs, p, adj_rsq, f, p_f)
    
    return(fit)
  }
  
  
  ## SOURCE:
  setwd("/Applications/eeglab2019/talker-change-data-processing")
  library(dplyr)
  library(tidyr)
  library(broom)
  
  
  ## MAIN:
  correlations <- get_correlations()
  rms <- get_rms()
  anterior_data_frame <- get_region_data_frame("anterior", rms, rms_method, correlations, condition)
  middle_data_frame <- get_region_data_frame("middle", rms, rms_method, correlations, condition)
  posterior_data_frame <- get_region_data_frame("posterior", rms, rms_method, correlations, condition)
  fit_anterior <- get_simplified_mult_reg("anterior", anterior_data_frame, rms_method)
  fit_middle <- get_simplified_mult_reg("middle", middle_data_frame, rms_method)
  fit_posterior <- get_simplified_mult_reg("posterior", posterior_data_frame, rms_method)
  fits <- rbind(fit_anterior, fit_middle, fit_posterior)
  
  
  ## SAVE:
  save_fp <- paste("/Applications/eeglab2019/talker-change-data-processing/data/aggregate/rms/",
                   condition, "_rms_", rms_method, "_fits.csv", sep = "")
  write.csv(fits, save_fp)
}