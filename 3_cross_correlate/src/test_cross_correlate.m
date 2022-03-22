cd("/Users/letitiaho/src/talker_change_data_processing")
addpath(fullfile('1_preprocessing/data/304')) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
addpath('tools')

% Load eeg data
load('eeg_data')

% cross_correlations = [];
% abs_average = [];
% maximum = [];
% lags = [];

epoch_num = 120;
% for epoch_num = 120:121
% Select epoch and resample
epoch = double(eeg_data(40, :, epoch_num));
%     epoch = resample(epoch, 44100, 1000);

% Load audio file
stim = audioread('churchbells_f.wav');
stim = resample(stim, 10, 441);
pad = zeros(length(epoch) - length(stim), 1);
stim = [stim; pad];

% Cross correlation
[cross_correlation, lag] = xcorr(epoch, stim);
% cross_correlations = [cross_correlations; cross_correlation];
% abs_average = [abs_average, mean(abs(cross_correlation))];
% [m, I] = max(abs(cross_correlation));
% maximum = [maximum, m];
% lags = [lag(I)];
% end

time_points = -100:1499;
figure
plot(time_points, epoch)
xlim([-100, 1500])
ylim([-20, 20])
% figure
% plot(stim)
% xlim([-100, 1500])
% ylim([-1, 1])
% figure
% plot(cross_correlation)
% xlim([0, 3200])
% cross_correlation = cross_correlation/max(cross_correlation);
% audiowrite('sample_cross_correlation.wav', cross_correlation, 1000)