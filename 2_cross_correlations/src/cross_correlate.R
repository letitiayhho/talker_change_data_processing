library('tuneR')
library('rmatio')
library('signal')
library('tseries')

#setwd('src/talker_change_data_processing/')

# Read audio file
stim <- readWave('0_set_up_and_raw_data/data/stim/original/churchbells_f.wav')@left

# Read eeg file
eeg <- read.mat(filename = '1_preprocessing/data/304/eeg_data.mat')$eeg_data
epoch <- eeg[1, , 2]
epoch <- resample(epoch, 44100, 1000)
ccfvalues <- ccf(epoch, stim, lag = length(epoch))
max(abs(ccfvalues$acf))

