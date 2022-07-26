
n = 1600;                    % number of samples
h = n*2-1;                   % number of lags
noise1 = wgn(n, 1, 1);
noise2 = wgn(n, 1, 1);
a = 0.05;

fprintf(1, "Ljung box for white noise against white noise")
signals = [noise1, noise2];
[h,pValue,stat,cValue] = mlbqtest(signals, n-1, [], alpha)
[r, lags] = xcorr(noise1, noise2, 'normalized');
[h, p, Q, c] = ljungBoxTest(r, lags, n, h, a)

fprintf(1, "Ljung box for stim against white noise")
signals = [stim, noise1];
[h,pValue,stat,cValue] = mlbqtest(signals, n-1, [], alpha)
[r, lags] = xcorr(stim, noise1, 'normalized');
[h, p, Q, c] = ljungBoxTest(r, lags, n, h, a)

fprintf(1, "Ljung box for eeg against white noise")
signals = [epoch, noise1];
[h,pValue,stat,cValue] = mlbqtest(signals, n-1, [], alpha)
[r, lags] = xcorr(epoch, noise1, 'normalized');
[h, p, Q, c] = ljungBoxTest(r, lags, n, h, a)

fprintf(1, "Ljung box for eeg against stim")
signals = [epoch, stim];
[h,pValue,stat,cValue] = mlbqtest(signals, n-1, [], alpha)
[r, lags] = xcorr(epoch, stim, 'normalized');
[h, p, Q, c] = ljungBoxTest(r, lags, n, h, a)

%% Try own implementation of ljung box

SUB = '316'
EPOCH = 82
CHAN = 38

% Add paths
cd('~/src/talker_change_data_processing')
addpath('tools/vendor/mlbqtest/')
addpath(fullfile('1_preprocessing/data', SUB)) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
addpath(fullfile('3_cross_correlate/data', SUB))

% Import EEG data
eeg_data = load('eeg_data').eeg_data;
stim_order = load('stim_order').stim_order;
epoch = double(eeg_data(CHAN, :, EPOCH))';

% Load stimuli file
word = char(stim_order.word(EPOCH));
stim = audioread(word);
stim = resample(stim, 10, 441);

% Pad the stimuli signal to make it the same length as the eeg
pad = zeros(length(epoch) - length(stim), 1);
stim = [stim; pad];

%% Ljung-box
signal1 = epoch;
signal2 = stim;
alpha = 0.05;
n = length(signal1)       % number of samples
h = n*2-1               % number of lags

% Compute cross correlation
fprintf(1, "Results from my implementation")
[r, lags] = xcorr(signal1, signal2, 'normalized');
[h, p, Q, c] = ljungBoxTest(r, lags, n, h, alpha)

% The darned matlab implementation
fprintf(1, "Results from mlbqtest()")
signals = [signal1, signal2];
[h, p, Q, c] = mlbqtest(signals, n-1)

% My implementation





%% given demo
% cd('~/src/talker_change_data_processing/tools/vendor/mlbqtest')
% 
% 
% ret = load('ret.dat');  % return of two assets
% % --- use default DOF and ALPHA
% % [h,pValue,stat,cValue] = mlbqtest(rtn,[3,6,10]);
% % --- specifiy DOF
% % [h,pValue,stat,cValue] = mlbqtest(rtn,[3,6,10],[20,24,34]);   
% % --- use default DOF, and specified ALPHA
% alpha = 0.01;
% [h,pValue,stat,cValue] = mlbqtest(ret,[4,8],[],alpha);   % 5% significance level


%% Test on my own data
subject_number = '304';
cd('~/src/talker_change_data_processing')
addpath('tools/vendor/mlbqtest/')
addpath(fullfile('1_preprocessing/data', subject_number)) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
addpath(fullfile('3_cross_correlate/data', subject_number))

% Import EEG data
eeg_data = load('eeg_data').eeg_data;

% Import pruned epoch order
stim_order = load('stim_order').stim_order;

% 2. Cross correlate with random stim
stat_rand = zeros(10, 10);
words_rand = repmat({''}, 10, 10);

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