cd("/Users/letitiaho/src/talker_change_data_processing")
addpath(fullfile('1_preprocessing/data/304')) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/original')) % add audio stimuli directory to path
addpath('tools')

% Load audio file
stim = audioread('churchbells_f.wav');
pad = zeros(length(epoch) - length(stim), 1);
stim = [stim; pad];

% Load eeg data
load('eeg_data')
maxs = [];
for i = 1:size(eeg_data, 3)
    epoch = double(eeg_data(1, :, i));
    epoch = resample(epoch, 44100, 1000);

    % Cross correlation
    cross_correlations = xcorr(epoch, stim, 'normalize');
    maxs = [maxs, max(abs(cross_correlations))];
end