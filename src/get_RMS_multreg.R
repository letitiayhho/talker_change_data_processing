get_RMS_multreg <- function(channels) {
  ## DESCRIPTION:
  ##  Compute a multiple regression for each electrode against all three conditions and
  ##  the RMS values for all three superior parietal channels (53, 54, 61)
  ## 
  ## OUTPUT:
  
  
  ## FUNCTIONS:
  get_correlations <- function() { 
    correlations <- read.csv("data/aggregate/cross_correlation_data.csv")
    colnames(correlations) <- c("subject_number", "constraint", "meaning", "talker", paste("E", 1:128, sep = ""))
    return(correlations) }
  
  get_rms <- function() {
    correlations <- read.csv("data/aggregate/RMS_data.csv")
    colnames(correlations) <- c("subject_number", "constraint", "meaning", "talker", paste("E", 1:128, sep = ""))
    return(correlations) }
  
  get_condition_recoding <- function(correlations, condition) {
    # Recoding for one condition, constraint G/S -> 0/1, meaning M/N -> 0/1, talker S/T -> 0/1
    recoded_condition <- c()
    levels <- unique(correlations[[condition]])
    original_condition <- correlations[[condition]]
    recoded_condition[correlations[[condition]] == levels[[1]]] <- 0
    recoded_condition[correlations[[condition]] == levels[[2]]] <- 1
    
    return(recoded_condition)
  }
  
  get_mult_regs <- function(correlations, rms) {
    # Get condition IVs
    constraint <- get_condition_recoding(correlations, "constraint")
    meaning <- get_condition_recoding(correlations, "meaning")
    talker <- get_condition_recoding(correlations, "talker")
    
    # Get RMS IVs
    rms_53 <- rms$E53
    rms_54 <- rms$E54
    rms_61 <- rms$E61
    
    # Compute mult reg for all channels
    coeffs <- list()
    p_values <- list()
    adj_r_sq <- list()
    
    for (i in 1:128) {
      # Compute mult reg
      y <- correlations[[paste("E", i, sep = "")]]
      fit <- lm(y ~ constraint + meaning + talker + rms_53 + rms_54 + rms_61)
      
      # Extract statistics
      coeffs[i] <- fit
      p_values[i] <- list(summary(fit)$coefficients[,"Pr(>|t|)"])
      adj_r_sq[i] <- summary(fit)$adj.r.squared
    }
    
    # Compile into one nested named list
    fits <- list(coeffs = coeffs,
                 p_values = p_values,
                 r_sq = r_sq)
    
    return(fits)
  }
  
  
  ## MAIN:
  correlations <- get_correlations()
  rms <- get_rms()
  fits <- get_mult_regs(correlations, rms)
  
  
  ## SAVE:
  save(fits, file = "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/rms_fits")
}