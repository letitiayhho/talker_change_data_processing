% function [] = cross_correlate(git_home, subject_number)
% % DESCRIPTION:
% %     Takes the preprocessed eeg data and convolves or cross-correlates the
% %     waveforms with the waveform of the auditory stimuli
% %
% % OUTPUT:
% %     Writes files named cross_correlations.mat
%
% arguments
%     git_home string
%     subject_number char
% end
%
%     fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

%% Params
SUB = '304';
n = 1600;                    % number of samples
h = n*2-1;                   % number of lags

%% 1. Import data
cd('~/src/talker_change_data_processing')
addpath('tools/vendor/mlbqtest/')
addpath(fullfile('1_preprocessing/data', SUB)) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
addpath(fullfile('3_cross_correlate/data', SUB))

% Import EEG data
eeg_data = load('eeg_data').eeg_data;

% Import pruned epoch order
stim_order = load('stim_order').stim_order;

%% 2. Cross correlate with random stim
hs_rand = zeros(10, 10);
ps_rand = zeros(10, 10);
Qs_rand = zeros(10, 10);
words_rand = repmat({''}, 10, 10);

% Loop over channels
fprintf(1, 'Channel #')
for i = 1:10
    %     for i = 1:size(eeg_data, 1)
    fprintf(1, strcat(num2str(i), ', #'))
    
    % Loop over epochs
    for j = 1:10
%     for j = 1:size(eeg_data, 3)
        
        % Extract eeg epoch
        epoch = double(eeg_data(i, :, j))';
        
        % Load stimuli .wav file for epoch
        word_num = randi(size(eeg_data, 3), 1);
        word = char(stim_order.word(word_num));
        words_rand(j, i) = {word};
        stim = audioread(word);
        stim = resample(stim, 10, 441);
        
        % Pad the stimuli signal to make it the same length as the eeg
        pad = zeros(length(epoch) - length(stim), 1);
        stim = [stim; pad];
        
        signals = [epoch, stim];
        time_points = size(epoch, 1);
        lags = time_points-1;
        
        % Compute convolution and cross correlation
        [r, lags] = xcorr(epoch, stim, 'normalized');
        [h, p, Q, c] = ljungBoxTest(r, lags, n, h, alpha);
%         [hValue, pValue, testStat, cValue] = mlbqtest(signals, lags);
        
        % Write statistics to data arrays
        hs_rand(j, i) = h;
        ps_rand(j, i) = p;
        Qs_rand(j, i) = Q;
    end
    
end

%% 2. Cross correlate
hs = zeros(10, 10);
ps = zeros(10, 10);
Qs = zeros(10, 10);
words = repmat({''}, 10, 10);

% Loop over channels
fprintf(1, 'Channel #')
for i = 1:10
    %     for i = 1:size(eeg_data, 1)
    fprintf(1, strcat(num2str(i), ', #'))
    
    % Loop over epochs
    for j = 1:10
%     for j = 1:size(eeg_data, 3)
        
        % Extract eeg epoch
        epoch = double(eeg_data(i, :, j))';
        
        % Load stimuli .wav file for epoch
        word = char(stim_order.word(j));
        words(j, i) = {word};
        stim = audioread(word);
        stim = resample(stim, 10, 441);
        
        % Pad the stimuli signal to make it the same length as the eeg
        pad = zeros(length(epoch) - length(stim), 1);
        stim = [stim; pad];
        
        signals = [epoch, stim];
        time_points = size(epoch, 1);
        lags = time_points-1;
        
        % Compute convolution and cross correlation
        [r, lags] = xcorr(epoch, stim, 'normalized');
        [h, p, Q, c] = ljungBoxTest(r, lags, n, h, alpha);
%         [hValue, pValue, testStat, cValue] = mlbqtest(signals, lags);
        
        % Write statistics to data arrays
        hs(j, i) = h;
        ps(j, i) = p;
        Qs(j, i) = Q;
    end
    
end

function [h, p, Q, c] = ljungBoxTest(r, lags, n, h, alpha)
    if isrow(lags)
        lags = lags';
    end
    Q = n * (n - 2) * sum(r .* r ./ (n - lags));
    p = chi2cdf(Q, h,'upper');
    c = chi2inv(1 - alpha, h);
    h = Q > c;
end

