library('tuneR')
library('rmatio')
library('signal')
library('tseries')

# Read audio file
stim <- readWave('0_set_up_and_raw_data/data/stim/original/churchbells_f.wav')@left

# Read eeg file
eeg <- read.mat(filename = '1_preprocessing/data/304/eeg_data.mat')$eeg_data

maxs <- c()
for (i in 1:dim(eeg)[3]) {
  epoch <- eeg[1, , i]
  epoch <- resample(epoch, 44100, 1000)
  ccfvalues <- ccf(epoch, stim, lag = 141119)
  maxs <- c(maxs, max(abs(ccfvalues$acf)))
}

