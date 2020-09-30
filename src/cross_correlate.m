function [] = cross_correlate(git_home, subject_number, resample)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlation_data_table.mat

arguments
    git_home char
    subject_number char
    resample logical = false
end

    tic

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('data', subject_number)) % add subject data to path
    addpath(fullfile('data/stim')) % add audio stimuli directory to path
    addpath('src/')
    
    % Import EEG data
    load('eeg_data')

    % Import pruned epoch order
    stim_order = get_stim_order(subject_number, resample);

    %% 2. Cross correlate
    abs_average = zeros(size(eeg_data, 3), size(eeg_data, 1));
    maximum = zeros(size(eeg_data, 3), size(eeg_data, 1));
    lag = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    for i = 1:size(eeg_data, 1)
        disp(strcat('Channel #', num2str(i)))

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
    fp = fullfile('data', subject_number, 'cross_correlations'); 
        % probably remove this and just return the var and append to file
        % from main
    fprintf(1, strcat('Writing file to ', fp, '\n'))
    save(fp, 'cross_correlations');

    toc

    %% Quit
    quit
end
