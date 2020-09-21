function [] = convolve_and_cross_correlate(git_home, subject_number)
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

    %% 3. Convolve
    % Initialize data tables
    cross_correlation = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    for i = 1:size(eeg_data, 1)
        disp(strcat('Channel #', num2str(i)))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)
             epoch = eeg_data(i, :, j);

             % Load stimuli .wav file for epoch
             word = char(epoch_order_pruned.word(j));
             auditory_stimuli = audioread(word);

             % Compute convolution and cross correlation
             cross_correlation(j, i) = mean(xcorr(epoch, auditory_stimuli)); % should be #stim x #channels

         end
    end

    %% 4. Write data
    % Add relevant info to data tables
    cross_correlation_data_table = table([epoch_order_pruned.type],...
        [epoch_order_pruned.epoch],...
        [epoch_order_pruned.word],...
        [cross_correlation],...
        'VariableNames', {'condition', 'epoch', 'word', 'cross_correlation'});

    % Write data
    fp = fullfile('data', subject_number, 'cross_correlation_data_table');
    fprintf(1, strcat('Writing file to ', fp, '\n'))
    save(fp, 'cross_correlation');

    %% Quit
    quit
end
