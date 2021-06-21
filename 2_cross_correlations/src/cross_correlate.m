function [cross_correlations_file_name] = cross_correlate(git_home, subject_number, unique_id, shuffle)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlations.mat or
%     cross_correlations_shuffled.mat

arguments
    git_home string
    subject_number char
    unique_id char = ""
    shuffle logical = false
end

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('1_preprocessing/data', subject_number)) % add subject data to path
    addpath(fullfile('0_set_up_and_raw_data/data/stim/original')) % add audio stimuli directory to path
    addpath('tools')

    % Import EEG data
    load('eeg_data')

    % Import pruned epoch order
    stim_order = get_stim_order(subject_number, unique_id, shuffle);

    %% 2. Cross correlate
    abs_average = zeros(size(eeg_data, 3), size(eeg_data, 1));
    maximum = zeros(size(eeg_data, 3), size(eeg_data, 1));
    lag = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    fprintf(1, 'Channel #')
    for i = 1:size(eeg_data, 1)
        fprintf(1, strcat(num2str(i), ', #'))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)

             % Extract eeg epoch and interpolate
             epoch = double(eeg_data(i, :, j));
             resampled_epoch = resample(epoch, 44100, 1000);

             % Load stimuli .wav file for epoch
             word = char(stim_order.word(j));
             stim = audioread(word);
             
             % Pad the stimuli signal to make it the same length as the eeg
             pad = zeros(length(resampled_epoch) - length(stim), 1);
             stim = [stim; pad];

             % Compute convolution and cross correlation
             [cross_correlations, lags] = xcorr(stim, resampled_epoch, 'normalize');

             % Write statistics to data arrays
             abs_average(j, i) = mean(abs(cross_correlations));
             [maximum(j, i), I] = max(abs(cross_correlations));
             lag(j, i) = lags(I);
         end
    end

    %% 3. Split condition codes up
    condition = get_split_conditions(stim_order.type);

    %% 4. Write data files
    % Add relevant info to data tables
    cross_correlations = [table(repmat(subject_number, size(stim_order, 1), 1), 'VariableNames', {'subject_number'}),...
        condition,...
        table(stim_order.epoch, 'VariableNames', {'epoch'}),...
        table(stim_order.word, 'VariableNames', {'word'}),...
        array2table(maximum),...
        array2table(lag)];

    % Write data
    if shuffle
        cross_correlations_file_name = strcat(unique_id, '_cross_correlations_shuffle');
    else
        cross_correlations_file_name = 'cross_correlations';
    end
    fp = fullfile('2_cross_correlations/data', subject_number, cross_correlations_file_name);
    fprintf(1, strcat('\nWriting data to /', fp, '\n'))
    save(fp, 'cross_correlations');
end
