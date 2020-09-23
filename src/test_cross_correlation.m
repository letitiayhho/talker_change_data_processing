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
    load('eeg_data');

    % Get order of stimuli files
    epoch_order_pruned = get_epoch_order(subject_number);

    %% 2. Convolve over 30 middle epochs and 20 channels
%     average = zeros(30, 20); % epochs 100:129, channels 30:49
%     maximum = zeros(30, 20);
%     lag = zeros(30, 20);
    cross_correlations = zeros(30, 20, 141119);

    % Loop over channels
    for i = 1:20
        disp(strcat('Channel #', num2str(i+30)))

        % Loop over epochs
         for j = 1:30
             
             % Extract eeg epoch and resample to 44.1 kHz
             epoch = double(eeg_data(i+29, :, j+99));
             resampled_epoch = resample(epoch, 44100, 1000);
             
             % Load stimuli .wav file for epoch
             word = char(epoch_order_pruned.word(j+100));
             auditory_stimuli = audioread(word);

             % Compute convolution and cross correlation
             cross_correlations(j, i, :) = xcorr(auditory_stimuli, epoch); % 70,560*2-1 length
             
             % Write statistics to data arrays
%              [cross_correlations, lags] = xcorr(auditory_stimuli, epoch);
%              average(j, i) = mean(abs(cross_correlations));
%              [maximum(j, i), I] = max(abs(cross_correlations));
%              lag(j, i) = lags(I);
         end
    end

    %% 4. Write data
    % Add relevant info to data tables
    cross_correlation_data_table = table([epoch_order_pruned.type(61:80)],...
        [epoch_order_pruned.epoch(61:80)],...
        [epoch_order_pruned.word(61:80)],...
        [cross_correlations],...
        'VariableNames', {'condition', 'epoch', 'word', 'cross_correlations'});
%         [average],...
%         [maximum],...
%         [lag],...
%         'VariableNames', {'condition', 'epoch', 'word', 'average', 'max', 'lag'});

    % Write data
    fp = fullfile('data', subject_number, 'cross_correlation_data_table_full');
    fprintf(1, strcat('Writing file to ', fp, '\n'))
    save(fp, 'cross_correlation_data_table')
    
    %% Quit
%     quit
end
