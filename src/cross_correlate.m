function [] = cross_correlate(git_home, subject_number)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% INPUT:
%     git_home (char) - path to git root directory
%     subject_number (char) - input subject numbers as strings, e.g. '302'
%
% OUTPUT:
%     Writes files named cross_correlation_data_table.mat

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('data', subject_number)) % add subject data to path
    addpath(fullfile('data/stim')) % add audio stimuli directory to path
    addpath('src/')
    
    % Import EEG data
    eeg_data = load('eeg_data').eeg_data;

    % Import pruned epoch order
    epoch_order_pruned = get_epoch_order(subject_number);

    %% 2. Cross correlate
    average = zeros(size(eeg_data, 3), size(eeg_data, 1));
    abs_average = zeros(size(eeg_data, 3), size(eeg_data, 1));
    maximum = zeros(size(eeg_data, 3), size(eeg_data, 1));
    lag = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    for i = 1:size(eeg_data, 1)
        disp(strcat('Channel #', num2str(i)))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)
             
             % Extract eeg epoch and interpolate
             epoch = interp(eeg_data(i, :, j), 44);
             
             % Load stimuli .wav file for epoch
             word = char(epoch_order_pruned.word(j));
             auditory_stimuli = audioread(word);

             % Compute convolution and cross correlation
             [cross_correlations, lags] = xcorr(auditory_stimuli, epoch);
             
             % Write statistics to data arrays
             average(j, i) = mean(cross_correlations);
             abs_average(j, i) = mean(abs(cross_correlations));
             [maximum(j, i), I] = max(abs(cross_correlations));
             lag(j, i) = lags(I);
         end
    end

    %% 3. Write data files
    % Add relevant info to data tables
    cross_correlations = table([epoch_order_pruned.type],...
        [epoch_order_pruned.epoch],...
        [epoch_order_pruned.word],...
        [average],...
        [abs_average],...
        [maximum],...
        [lag],...
        'VariableNames', {'condition', 'epoch', 'word', 'average', 'abs_average', 'maximum', 'lag'});

    % Write data
    fp = fullfile('data', subject_number, 'cross_correlations');
    fprintf(1, strcat('Writing file to ', fp, '\n'))
    save(fp, 'cross_correlations');

    %% Quit
    quit
end
