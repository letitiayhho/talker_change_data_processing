function [] = test_cross_correlation(git_home, subject_number)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% INPUT:
%     subject_number (char) - input subject numbers as strings, e.g. '302'
%
% OUTPUT:
%     Writes files named <cross_correlation/convolution>_data_table.mat

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

    %% 3. Convolve over 20 middle epochs and 20 channels
    % Initialize data arrays
    average = zeros(20, 30, 3); % epochs 100:130, channels 30:50, features (mean, max, lag)
    max = zeros(20, 30, 3);
    lag = zeros(20, 30, 3);

    % Loop over channels
    for i = 1:20
        disp(strcat('Channel #', num2str(i+30)))

        % Loop over epochs
         for j = 1:30
             
             % Extract eeg epoch and interpolate
             epoch = interp(eeg_data(i+30, :, j+60), 44);
             
             % Load stimuli .wav file for epoch
             word = char(epoch_order_pruned.word(j+60));
             auditory_stimuli = audioread(word);

             % Compute convolution and cross correlation
             [cross_correlations, lags] = xcorr(auditory_stimuli, epoch);
             
             % Write statistics to data arrays % take ABS?
             average(i, j) = mean(cross_correlations);
             [max(i, j), I] = max(cross_correlations);
             lag(i, j) = lags(I);
             
             [cross_correlation(j, i, 1:xc_len), lags(j, i, 1:xc_len)] = xcorr(auditory_stimuli, epoch); % REMOVE
             % MAYBE I DONT NEED TO, JUST SAVE MAX AND Index (and lag)
             % or only really have to save lags once
         end
    end

    %% 4. Write data
    % Add relevant info to data tables
    cross_correlation_data_table = table([epoch_order_pruned.type(61:80)],...
        [epoch_order_pruned.epoch(61:80)],...
        [epoch_order_pruned.word(61:80)],...
        [cross_correlation],...
        [lags],...
        'VariableNames', {'condition', 'epoch', 'word', 'cross_correlation', 'lags'});

    % Write data
    fp = fullfile('data', subject_number, 'cross_correlation_data_table_full_rev');
    fprintf(1, strcat('Writing file to\ ', fp, '\n'))
    save(fp, 'cross_correlation_data_table')
    
    %% Quit
%     quit
end
