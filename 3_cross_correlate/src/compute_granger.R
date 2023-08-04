compute_granger <- function(subject_number, window = 0) {
  library(audio)
  library(TSA)
  library(R.matlab)
  library(lmtest)
  
  cat(paste('Computing granger causality for subject #', subject_number, '\n'))
  
  # 1. Import data
  eeg_data_fpath <- paste('1_preprocessing/data/', subject_number, '/eeg_data.mat', sep = '')
  stim_order_fpath <- paste('3_cross_correlate/data/', subject_number, '/stim_order.csv', sep = '')
  eeg_data <- readMat(eeg_data_fpath)$eeg.data
  stim_order <- read.table(stim_order_fpath, sep = ',', header = TRUE)
  
  # 2. Cross correlate
  dfs <- array(0, dim = c(dim(eeg_data)[3], dim(eeg_data)[1]))
  Fs <- array(0, dim = c(dim(eeg_data)[3], dim(eeg_data)[1]))
  Ps <- array(0, dim = c(dim(eeg_data)[3], dim(eeg_data)[1]))
  
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
      
      # Load max lag
      maxlag_fpath <- paste('3_cross_correlate/data/', subject_number, '/max_lag.RData', sep = '')
      load(maxlag_fpath)
      maxlag <- data
      epoch_maxlag <- maxlag[j, i]
      
      # Compute granger in a +/- 10 ms window around maxlag
      if (epoch_maxlag > window) {
        lower_bounds <- epoch_maxlag - window
        upper_bounds <- epoch_maxlag + window
      } else {
        lower_bounds <- 0
        upper_bounds <- epoch_maxlag + window
      }
      epoch <- epoch[lower_bounds:length(epoch)]
      
      # Compute granger causality
      tryCatch(granger <- grangertest(stim, epoch, order = upper_bounds), error = function(c) {
        granger$Df <- NA
        granger$F <- NA
        granger$`Pr(>F)` <- NA
      })

      # Save output
      dfs[j, i] <- granger$Df[2]
      Fs[j, i] <- granger$F[2]
      Ps[j, i] <- granger$`Pr(>F)`[2]
      
    }
    # break
  }
  
  # Write data files
  fp <- file.path('3_cross_correlate/data', subject_number, 'granger-dfs.RDS')
  cat(paste('\nWriting data to /', fp, '\n'))
  save(dfs, file = fp)

  fp <- file.path('3_cross_correlate/data', subject_number, 'granger-F.RDS')
  cat(paste('\nWriting data to /', fp, '\n'))
  save(Fs, file = fp)
  
  fp <- file.path('3_cross_correlate/data', subject_number, 'granger-P.RDS')
  cat(paste('\nWriting data to /', fp, '\n'))
  save(Ps, file = fp)
}







GIT_HOME = '/Users/letitiaho/src/talker_change_data_processing'
setwd(GIT_HOME)
source('3_cross_correlate/src/prewhiten.R')

# Read subject numbers from file
subject_numbers <- readLines("0_set_up_and_raw_data/data/subject_numbers.txt")

# Loop over subjects
for (subject_number in subject_numbers) {
  print(subject_number)
  compute_granger(subject_number, window = 10)
}
