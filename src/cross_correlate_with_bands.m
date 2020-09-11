function [] = convolve_and_cross_correlate_with_bands(git_home, subject_number)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% INPUT:
%     git_home (char) - path to git root directory
%     subject_number (char) - input subject numbers as strings, e.g. '302'
%
% OUTPUT:
%     Writes files named cross_correlation_band_data_table.mat

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
 
    %% 3. Compute cross-correlations
    
    % Create struct of frequency bands
    bands.names = {'delta', 'theta', 'alpha', 'beta1', 'beta2', 'gamma1', 'gamma2'};
    bands.lower_lims = [1, 4, 8, 14, 20, 30, 50];
    bands.upper_lims = [4, 8, 14, 20, 30, 50, 100];

    % Initialize matrix for data
    cross_correlation = []; 

    % Loop over frequency bands
    for i = length(bands.names)

        % Create filter around frequency band
        band = char(bands.names(i));
        fprintf(1, ['Correlating audio with eeg signals filtered around ', band, ' band \n'])
        
        % Init data matrix
        band_table = zeros(num_epochs, num_channels);

        % Loop over channels
        for j = 1:size(eeg_data, 1)
            fprintf(1, ['Channel #', num2str(j), '\n'])

            % Loop over epochs
             for k = 1:size(eeg_data, 3)

                 % Extract epoch from subject data
                 epoch = eeg_data(j, :, k);

                 % Filter epoch
                 filtered_epoch = bandpass(epoch, [bands.lower_lims(i),...
                     bands.upper_lims(i)], 1000);

                 % Load stimuli .wav file for epoch
                 word = char(epoch_order_pruned.word(k));
                 auditory_stimuli = audioread(word);

                 % Compute convolution and cross correlation
                 band_table(k, j) = mean(xcorr(filtered_epoch, auditory_stimuli)); 

             end
        end
        
        % Combine into a data frame
        band_label(1:size(epoch_order_pruned, 1), 1) = bands.names(i);
        band_data = table(band_label,...
            [epoch_order_pruned.type],...
            [epoch_order_pruned.epoch],...
            [epoch_order_pruned.word],...
            [band_table],...
            'VariableNames', {'band', 'condition', 'epoch', 'word', 'cross_correlation'});
        cross_correlation = [cross_correlation; band_data];
    end

    %% 4. Write data
    fp = fullfile('data', subject_number, 'cross_correlation_band_data_table');
    fprintf(1, strcat('Writing file to ', fp, '\n'))
    save(fp, 'cross_correlation');

    %% Quit
    quit
end
