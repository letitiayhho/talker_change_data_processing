%% 1. Import data
subject_number = '304';
cd('~/src/talker_change_data_processing')
addpath('tools/vendor/xcorrpvalue')
addpath(fullfile('1_preprocessing/data', subject_number)) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
addpath(fullfile('3_cross_correlate/data', subject_number))

% Import EEG data
eeg_data = load('eeg_data').eeg_data;

% Import pruned epoch order
stim_order = load('stim_order').stim_order;

%% 2. Cross correlate
p_permuting1 = zeros(10, 10);
p_permuting2 = zeros(10, 10);

% Loop over channels
fprintf(1, 'Channel #')
for i = 1:10
    fprintf(1, strcat(num2str(i), ', #'))
    
    % Loop over epochs
    for j = 1:10
        
        % Extract eeg epoch
        epoch = double(eeg_data(i, :, j))';
        
        % Load stimuli .wav file for epoch
        word = char(stim_order.word(j));
        stim = audioread(word);
        stim = resample(stim, 10, 441);
        
        % Pad the stimuli signal to make it the same length as the eeg
        pad = zeros(length(epoch) - length(stim), 1);
        stim = [stim; pad];
        
        % Compute cross correlation
        xcorrs = xcorr(stim, epoch);
        maxi = max(xcorrs);
        
        % Compute convolution and cross correlation
        [p1, p2] = xcorrpvalueautocorrcontrolled(stim, epoch, maxi);
        
        % Write statistics to data arrays
        p_permuting1(j, i) = p1;
        p_permuting2(j, i) = p2;
    end
end

%% 3. Cross correlate with random stim
p_permuting1_rand = zeros(10, 10);
p_permuting2_rand = zeros(10, 10);

% Loop over channels
fprintf(1, 'Channel #')
for i = 1:10
    fprintf(1, strcat(num2str(i), ', #'))
    
    % Loop over epochs
    for j = 1:10
        
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
        
        % Compute cross correlation
        xcorrs = xcorr(stim, epoch);
        maxi = max(xcorrs);
        
        % Compute convolution and cross correlation
        [p1, p2] = xcorrpvalueautocorrcontrolled(stim, epoch, maxi);
        
        % Write statistics to data arrays
        p_permuting1_rand(j, i) = p1;
        p_permuting2_rand(j, i) = p2;
    end
end

%% 4. Plots
p_permuting1 = p_permuting1(:);
p_permuting2 = p_permuting2(:);
p_permuting1_rand = p_permuting1_rand(:);
p_permuting2_rand = p_permuting2_rand(:);

close all
figure
subplot(2, 2, 1); hist(p_permuting1, 40); xlim([0, 1])
subplot(2, 2, 3); hist(p_permuting1_rand, 40); xlim([0, 1])
subplot(2, 2, 2); hist(p_permuting2, 40); xlim([0, 1])
subplot(2, 2, 4); hist(p_permuting2_rand, 40); xlim([0, 1])