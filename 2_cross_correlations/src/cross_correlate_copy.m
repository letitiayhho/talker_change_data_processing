git_home = "/Users/letitiaho/src/talker_change_data_processing"

%% 1. Import data
cd(git_home)
addpath(fullfile('1_preprocessing/data/304')) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/original')) % add audio stimuli directory to path
addpath('tools')

% Load audio file
stim = audioread('churchbells_f.wav');
pad = zeros(length(epoch) - length(stim), 1);
stim = [stim; pad];

% Load eeg data
load('eeg_data')
epoch = double(eeg_data(1, :, 1));
epoch = resample(epoch, 44100, 1000).';

% Xcorr
cross_correlations = xcorr(epoch, stim);
max(abs(cross_correlations))

% % Import pruned epoch order
% stim_order = get_stim_order(subject_number, unique_id, shuffle);
% 
% %% 2. Cross correlate
% maximum = zeros(size(eeg_data, 3), size(eeg_data, 1));
% first = zeros(size(eeg_data, 3), size(eeg_data, 1));
% 
% % Loop over channels
% fprintf(1, 'Channel #')
% for i = 1:size(eeg_data, 1)
%     fprintf(1, strcat(num2str(i), ', #'))
% 
%     % Loop over epochs
%      for j = 1:size(eeg_data, 3)
% 
%          % Extract eeg epoch and interpolate
%          epoch = double(eeg_data(i, :, j));
%          resampled_epoch = resample(epoch, 44100, 1000);
% 
%          % Load stimuli .wav file for epoch
%          word = char(stim_order.word(j));
%          auditory_stimuli = audioread(word);
% 
%          % Compute convolution and cross correlation
%          cross_correlations = xcorr(auditory_stimuli, resampled_epoch);
% 
%          % Write statistics to data arrays
%          maximum(j, i) = max(abs(cross_correlations));
%          first(j, i) = cross_correlations(1);
%      end
% end
% 
% %% 3. Split condition codes up
% condition = get_split_conditions(stim_order.type);
% 
% %% 4. Write data files
% % Add relevant info to data tables
% cross_correlations = [table(repmat(subject_number, size(stim_order, 1), 1), 'VariableNames', {'subject_number'}),...
%     condition,...
%     table(stim_order.epoch, 'VariableNames', {'epoch'}),...
%     table(stim_order.word, 'VariableNames', {'word'}),...
%     array2table(maximum)];