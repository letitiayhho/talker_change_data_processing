function [] = cross_correlate_with_formants(git_home, subject_number)
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
    load('eeg_data')

    % Import pruned epoch order
    epoch_order_pruned = get_epoch_order(subject_number);
    
    %% 2. Cross correlate with formants
    average = zeros(size(eeg_data, 3), size(eeg_data, 1));
    abs_average = zeros(size(eeg_data, 3), size(eeg_data, 1));
    maximum = zeros(size(eeg_data, 3), size(eeg_data, 1));
    lag = zeros(size(eeg_data, 3), size(eeg_data, 1));
    formants = {'f0', 'f1_f2', 'f3'};

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
                 
                 % Extract eeg epoch and interpolate
                 epoch = interp(eeg_data(j, :, k), 44);
                 
                 % Load stimuli .wav file for epoch
                 word = strcat(erase(char(epoch_order_pruned.word(k)), ".wav"), "_", formant, ".wav");
                 auditory_stimuli = audioread(word);
                 
                 % Compute convolution and cross correlation
                 [cross_correlations, lags] = xcorr(auditory_stimuli, epoch);
                 
                 % Write statistics to data arrays
                 average(k, j) = mean(cross_correlations);
                 abs_average(k, j) = mean(abs(cross_correlations));
                 [maximum(k, j), I] = max(abs(cross_correlations));
                 lag(k, j) = lags(I);
                 
             end
        end
        
        formant_array(1:size(epoch_order_pruned, 1), 1) = formants(i);
        cross_correlations = table(formant_array,...
            [epoch_order_pruned.type],...
            [epoch_order_pruned.epoch],...
            [epoch_order_pruned.word],...
            [average],...
            [abs_average],...
            [maximum],...
            [lag],...
            'VariableNames', {'condition', 'epoch', 'word', 'average', 'abs_average', 'maximum', 'lag'});
        
        % Write data
        fp = fullfile('data', subject_number, 'cross_correlations_formant');
        fprintf(1, strcat('Writing file to ', fp, '\n'))
        save(fp, 'cross_correlations', '-append');
    end

    %% Quit
    quit
end
