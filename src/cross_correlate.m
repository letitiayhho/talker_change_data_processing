function [cross_correlations_file_name] = cross_correlate(git_home, subject_number, unique_id, scramble)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlations.mat or
%     cross_correlations_scrambled.mat

arguments
    git_home char
    subject_number char
    unique_id char
    scramble logical = false
end

    tic

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('data', subject_number)) % add subject data to path
    addpath(fullfile('data/stim/original')) % add audio stimuli directory to path
    addpath('src/')
    
    % Import EEG data
    load('eeg_data')

    % Import pruned epoch order
    stim_order = get_stim_order(subject_number, scramble);

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
             auditory_stimuli = audioread(word);

             % Compute convolution and cross correlation
             [cross_correlations, lags] = xcorr(auditory_stimuli, resampled_epoch);
             
             % Write statistics to data arrays
             abs_average(j, i) = mean(abs(cross_correlations));
             [maximum(j, i), I] = max(abs(cross_correlations));
             lag(j, i) = lags(I);
         end
    end

    %% 3. Write data files
    % Add relevant info to data tables
    cross_correlations = table([stim_order.type],...
        [stim_order.epoch],...
        [stim_order.word],...
        [abs_average],...
        [maximum],...
        [lag],...
        'VariableNames', {'condition', 'epoch', 'word', 'abs_average', 'maximum', 'lag'});

    % Write data
    if scramble
        cross_correlations_file_name = strcat(unique_id, '_cross_correlations_scramble');
        fp = fullfile('data', subject_number, cross_correlations_file_name);
    else
        cross_correlations_file_name = strcat(unique_id, '_cross_correlations');
        fp = fullfile('data', subject_number, cross_correlations_file_name);
    end
    fprintf(1, strcat('\nWriting data to /', fp, '\n'))
    save(fp, 'cross_correlations');

    toc
end
