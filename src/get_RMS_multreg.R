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
    
    # Create variables for storing stats
    coeffs <- data.frame(intercept = double(),
                         constraint = double(),
                         meaning = double(),
                         talker = double(),
                         rms_53 = double(),
                         rms_54 = double(),
                         rms_61 = double())
    p <- data.frame(p_intercept = double(),
                    p_constraint = double(),
                    p_meaning = double(),
                    p_talker = double(),
                    p_rms_53 = double(),
                    p_rms_54 = double(),
                    p_rms_61 = double())
    adj_rsq <- matrix(0, 128)
    f <- matrix(0, 128)
    p_f <- matrix(0, 128)
    
    # Compute mult reg for all channels
    for (i in 1:128) {
      # Get DV
      y <- correlations[[paste("E", i, sep = "")]]
      
      # Compute mult reg
      fit <- lm(y ~ constraint + meaning + talker + rms_53 + rms_54 + rms_61)
      
      # Extract statistics
      coeffs[i,] <- unname(fit$coefficients)
      p[i,] <- unname(summary(fit)$coefficients[,"Pr(>|t|)"])
      adj_rsq[i,] <- summary(fit)$adj.r.squared
      f[i,] <- unname(glance(fit)$statistic)
      p_f[i,] <- unname(glance(fit)$p.value)
    }
    
    # Bind into one data frame
    fits <- cbind(coeffs, p, adj_rsq, f, p_f)
    
    return(fits)
  }

  
  ## SOURCE:
  library(broom)
  setwd("/Applications/eeglab2019/talker-change-data-processing/")
  
  
  ## MAIN:
  correlations <- get_correlations()
  rms <- get_rms()
  fits <- get_mult_regs(correlations, rms)
  
  
  ## SAVE:
  write.csv(fits, "/Applications/eeglab2019/talker-change-data-processing/data/aggregate/RMS_fits.csv")
}