count_sig_ccfs <- function(subject_number) {
  rs_fpath <- paste('3_cross_correlate/data/', subject_number, '/rs_prewhitened.RData', sep = '')
  n_obs_fpath <- paste('3_cross_correlate/data/', subject_number, '/rs_n_obs.RData', sep = '')
  load(rs_fpath)
  load(n_obs_fpath)

  # Values
  n_epochs = dim(rs)[1]
  n_channels = dim(rs)[2]
  n_lags = dim(rs)[3]
  
  # Count significant cross correlations
  sig_ccfs <- array(0, dim = c(n_channels, n_epochs))
  
  for (epoch in 1:n_epochs) { # epochs x channels x lags
    epoch_rs <- rs[epoch, , ]
    epoch_n_obs <- n_obs[epoch]
    threshold <- 1.96/sqrt(epoch_n_obs)
    
    print("Channel:")
    for (channel in 1:n_channels) {
      cat(paste(channel, ', #'))
      channel_rs <- epoch_rs[channel, ]
      epoch_sig <- max(channel_rs) > threshold # Check if any CCF values > threshold
      sig_ccfs[channel, epoch] <- epoch_sig
    }
  }
  
  fp <- file.path('3_cross_correlate/data', subject_number, 'sig_ccfs.RData')
  cat(paste('\nWriting data to /', fp, '\n'))
  save(sig_ccfs, file = fp)
  
}


GIT_HOME = '/Users/letitiaho/src/talker_change_data_processing'
setwd(GIT_HOME)
source('3_cross_correlate/src/prewhiten.R')

# Read subject numbers from file
subject_numbers <- readLines("0_set_up_and_raw_data/data/subject_numbers.txt")

# Loop over subjects
for (subject_number in subject_numbers) {
  print(subject_number)
  count_sig_ccfs(subject_number)
}
