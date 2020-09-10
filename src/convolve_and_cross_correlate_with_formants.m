function [] = convolve_and_cross_correlate_with_formants(git_home, subject_number)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% INPUT:
%     git_home (char) - path to git root directory
%     subject_number (char) - input subject numbers as strings, e.g. '302'
%
% OUTPUT:
%     Writes files named cross_correlation_formant_data_table.mat

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
    
    %% 3. Compute cross correlations and convolutions for formants
    formants = {'f0', 'f1_f2', 'f3'};
    
    % Initialize matrix for data
    cross_correlation = []; 

    % Loop over formants
    for i = 1:length(formants)
        formant = formants(i);
        fprintf(1, ['Correlating eeg data with audio files filtered for ', char(formant), '\n'])

        % Loop over channels
        for j = 1:size(eeg_data, 1)
            fprintf(1, ['Channel #', num2str(j), '\n'])

            % Loop over epochs
             for k = 1:size(eeg_data, 3)
                 epoch = eeg_data(j, :, k);

                 % Load stimuli .wav file for epoch
                 word = strcat(erase(char(epoch_order_pruned.word(k)), ".wav"), "_", formant, ".wav");
                 auditory_stimuli = audioread(word);

                 % Compute convolution and cross correlation
                 cross_correlation(k, j, i) = mean(xcorr(epoch, auditory_stimuli)); % should be #stim * #channels * #formants

             end
        end
        
        formant_array(1:size(epoch_order_pruned, 1), 1) = formants(i);
        formant_data = table(formant_array,...
                [epoch_order_pruned.type],...
                [epoch_order_pruned.epoch],...
                [epoch_order_pruned.word],...
                [formant_table],...
                'VariableNames', {'formant', 'condition', 'epoch', 'word', 'cross_correlation'});
        cross_correlation = [cross_correlation; formant_data];
    end

    %% 4. Write data
    fp = fullfile('data', subject_number, 'cross_correlation_formant_data_table');
    fprintf(1, strcat('Writing file to ', fp, '\n'))
    save(fp, 'cross_correlation');

    %% Quit
    quit
end
