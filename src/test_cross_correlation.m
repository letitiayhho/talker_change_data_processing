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

    %% 2. Convolve over 20 middle epochs and 30 channels
    average = zeros(20, 30); % epochs 100:130, channels 30:50
    maximum = zeros(20, 30);
    lag = zeros(20, 30);

    % Loop over channels
    for i = 1:20
        disp(strcat('Channel #', num2str(i+30)))

        % Loop over epochs
         for j = 1:30
             
             % Extract eeg epoch and interpolate
             epoch = interp(eeg_data(i+30, :, j+60), 44);
             fprintf(1, strcat('eeg signal length:', num2str(size(epoch)), '\n'))
             
             % Load stimuli .wav file for epoch
             word = char(epoch_order_pruned.word(j+60));
             auditory_stimuli = audioread(word);

             % Compute convolution and cross correlation
             [cross_correlations, lags] = xcorr(auditory_stimuli, epoch);
             fprintf(1, strcat('xcorr length:', num2str(size(cross_correlations)), '\n'))
             
             % Take envelope of cross correlations
%              [yupper, ~] = envelope(cross_correlations, 100);
             
             % Write statistics to data arrays
             average(i, j) = mean(abs(cross_correlations));
             [maximum(i, j), I] = max(abs(cross_correlations));
             lag(i, j) = lags(I);
         end
    end

    %% 4. Write data
    % Add relevant info to data tables
    cross_correlation_data_table = table([epoch_order_pruned.type(61:80)],...
        [epoch_order_pruned.epoch(61:80)],...
        [epoch_order_pruned.word(61:80)],...
        [average],...
        [maximum],...
        [lag],...
        'VariableNames', {'condition', 'epoch', 'word', 'average', 'max', 'lag'});

    % Write data
%     fp = fullfile('data', subject_number, 'cross_correlation_data_table_full');
%     fprintf(1, strcat('Writing file to ', fp, '\n'))
%     save(fp, 'cross_correlation_data_table')
    
    %% Quit
%     quit
end
