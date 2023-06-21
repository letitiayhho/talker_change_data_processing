cross_correlate_prewhiten_save_full <- function(subject_number) {
  library(audio)
  library(TSA)
  library(R.matlab)

  cat(paste('Cross correlating data from subject #', subject_number, '\n'))
  
  # 1. Import data
  eeg_data_fpath <- paste('1_preprocessing/data/', subject_number, '/eeg_data.mat', sep = '')
  stim_order_fpath <- paste('3_cross_correlate/data/', subject_number, '/stim_order.csv', sep = '')
  eeg_data <- readMat(eeg_data_fpath)$eeg.data
  stim_order <- read.table(stim_order_fpath, sep = ',', header = TRUE)
  
  # 2. Cross correlate
  rs <- array(0, dim = c(dim(eeg_data)[3], dim(eeg_data)[1], 501))
  n_obs <- array(0, dim = dim(eeg_data)[3])
  maxs <- array(0, dim = c(dim(eeg_data)[3], dim(eeg_data)[1]))
  max_lags <- array(0, dim = c(dim(eeg_data)[3], dim(eeg_data)[1]))
  lags <- array(0, dim = c(dim(eeg_data)[3], dim(eeg_data)[1], 501))

  # Loop over channels
  cat('Channel #')
  for (i in 1:dim(eeg_data)[1]) {
    cat(paste(i, ', #'))
    
    # Loop over epochs
    for (j in 1:dim(eeg_data)[3]) {
      
      # Extract eeg epoch and interpolate
      epoch <- as.numeric(eeg_data[i, , j])
      
      # Load stimuli .wav file for epoch
      word <- as.character(stim_order$word[j])
      word_fpath <- paste("0_set_up_and_raw_data/data/stim/low_pass_400/", word, sep = '')
      stim <- audio::load.wave(word_fpath)
      
      # Resample to 1 kHz
      stim <- signal::resample(stim, 10, 441)
      
      # Prewhiten the eeg signal
      ccf <- prewhiten(stim, epoch, 500) # stim dragged over eeg such that max ccf is expected at positive lags
      n <- ccf$ccf$n.used
      r <- ccf$ccf$acf
      lag <- ccf$ccf$lag
      
      # Save only values of r at positive lag
      r <- r[lag >= 0]
      lag <- lag[lag >= 0]
      
      # Z-score
      std <- 1/sqrt(n)
      avg <- mean(r)
      r <- (r - avg)/std
      
      # Pad r to make them all the same length
      pad <- rep(0, length.out = 501 - length(r))
      r <- c(r, pad)
      lag <- c(lag, pad)
      
      # Find max and max lag
      maximum <- max(r)
      max_lag <- lag[r == maximum][1]
      
      # Add to arrays
      rs[j, i, ] <- r
      n_obs[j] <- n
      maxs[j, i] <- maximum
      max_lags[j, i] <- max_lag
      lags[j, i, ] <- lag
      
      # break
    }
    # break
  }
  
  # Write data files
  save_data(subject_number, rs, 'rs_prewhitened_standardized.RData')
  save_data(subject_number, n_obs, 'n_obs.RData')
  save_data(subject_number, max, 'max.RData')
  save_data(subject_number, max_lags, 'max_lag.RData')
  save_data(subject_number, lags, 'lags.RData')
}


save_data <- function(subject_number, data, fname) {
  fp <- file.path('3_cross_correlate/data', subject_number, fname)
  cat(paste('\nWriting data to /', fp, '\n'))
  save(data, file = fp)
}




GIT_HOME = '/Users/letitiaho/src/talker_change_data_processing'
setwd(GIT_HOME)
source('3_cross_correlate/src/prewhiten.R')

# Read subject numbers from file
subject_numbers <- readLines("0_set_up_and_raw_data/data/subject_numbers.txt")

# Loop over subjects
for (subject_number in subject_numbers) {
  print(subject_number)
  cross_correlate_prewhiten_save_full(subject_number)
}
