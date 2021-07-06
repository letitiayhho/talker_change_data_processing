cd("/Users/letitiaho/src/talker_change_data_processing")
addpath(fullfile('1_preprocessing/data/304')) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/original')) % add audio stimuli directory to path
addpath('tools')

% Load eeg data
load('eeg_data')

cross_correlations = [];
abs_average = [];
maximum = [];
lags = [];

for i = 120:121
    % Select epoch and resample
    epoch = double(eeg_data(40, :, i));
    epoch = resample(epoch, 44100, 1000);
    
    % Load audio file
    stim = audioread('churchbells_f.wav');
%     stim = resample(stim, 10, 441);
    pad = zeros(length(epoch) - length(stim), 1);
    stim = [stim; pad];
    
    % Cross correlation
    [cross_correlation, lag] = xcorr(epoch, stim, 'normalize');
    cross_correlations = [cross_correlations; cross_correlation];
    abs_average = [abs_average, mean(abs(cross_correlation))];
    [m, I] = max(abs(cross_correlation));
    maximum = [maximum, m];
    lags = [lag(I)];
end