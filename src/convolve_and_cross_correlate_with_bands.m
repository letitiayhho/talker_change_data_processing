function [] = convolve_and_cross_correlate_with_bands(git_home, subject_number)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% INPUT:
%     subject_number (char) - input subject numbers as strings, e.g. '302'
%
% OUTPUT:
%     Writes files named <cross_correlation/convolution>_band_data_table.mat

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('data', subject_number)) % add subject data to path
    addpath('data/stim/') % add audio stimuli directory to path

    % Import EEG data
    eeg_data = load('eeg_data').('eeg_data');

    % Import original epoch order
    epoch_order_original = load('epoch_order_original').('epoch_order_original');

    % Import pruned epoch order
    epoch_order_pruned = load('epoch_order_pruned').('epoch_order_pruned');

    % Import stimuli order
    stim_order = readtable('stim_order.txt');

    %% 2. Match EEG epochs with words
    % Sort original epoch order by condition
    epoch_order_original = struct2table(epoch_order_original);
    epoch_order_original = sortrows(epoch_order_original, 'type');
    epoch_order_original = epoch_order_original(endsWith(epoch_order_original.type, 'E'),:);

    % Sort pruned epoch order by condition
    epoch_order_pruned = struct2table(epoch_order_pruned);
    epoch_order_pruned = sortrows(epoch_order_pruned, 'type');

    % Match pruned epochs with corresponding epochs
    k = 1;
    for j = 1:height(epoch_order_original)
        % Match original epochs with corresponding stim 
        epoch_order_original.word(j) = stim_order.ending(j);
        
        % Break at the end of pruned epochs to avoid exceeding array length
        if k > height(epoch_order_pruned)
            break
        end
        
        % Match pruned epochs with corresponding stim
        if epoch_order_original.urevent(j) == epoch_order_pruned.urevent(k)
            epoch_order_pruned.word(k) = stim_order.ending(j);
            k = k+1;
        end
    end

    % Sort pruned epoch order by latency
    epoch_order_pruned = sortrows(epoch_order_pruned, 'latency');
 
    %% 3. Compute cross-correlations
    
    % Create struct of frequency bands
    bands.names = {'delta', 'theta'};
    bands.lower_lims = [1, 4];
    bands.upper_lims = [4, 8];
    % CHANGE BACK
%     bands.names = {'delta', 'theta', 'alpha', 'beta1', 'beta2', 'gamma1', 'gamma2'};
%     bands.lower_lims = [1, 4, 8, 14, 20, 30, 50];
%     bands.upper_lims = [4, 8, 14, 20, 30, 50, 100];

    % Init data matrix and values
    cross_correlation = []; 
    num_bands = length(bands.names);
    num_channels = size(eeg_data, 1);
    num_epochs = size(eeg_data, 3);

    % Loop over frequency bands
    for i = 1:num_bands

        % Create filter around frequency band
        band = char(bands.names(i));
        fprintf(1, ['Correlating audio with eeg signals filtered around ', band, ' band \n'])

        % Init data matrix
        band_table = zeros(num_epochs, num_channels);

        % Loop over channels
        for j = 1:num_channels
            fprintf(1, ['Channel #', num2str(j), '\n'])

            % Loop over epochs
             for k = 1:num_epochs

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
        verbose_band_table = table(band_label,...
            [epoch_order_pruned.type],...
            [epoch_order_pruned.epoch],...
            [epoch_order_pruned.word],...
            [band_table],...
            'VariableNames', {'band', 'condition', 'epoch', 'word', 'cross_correlation'});
        cross_correlation = [cross_correlation; verbose_band_table];
    end

    %% 4. Write data
    % REMOVE
%     cross_correlation_band_data_table = format_data(cross_correlation, epoch_order_pruned, bands);
    fp = fullfile('data', subject_number, 'cross_correlation_band_data_table_condensed_2');
    fprintf(1, strcat('Writing file to ', fp, '\n'))
    save(fp, 'cross_correlation');
    
    % REMOVE
%     % Format data into a table with columns for conditions
%     function [data_table] = format_data(data, epoch_order_pruned, bands) 
%                                         % Probably shouldn't be looping over 
%                                         % everything again copy lower part 
%                                         % after band_table to the end
%                                         % of the last loop, I think
%                                         % BEFORE all of that, check that it
%                                         % works as is
%         data_table = [];
%         for i = 1:length(bands.names)
%             % Get correlations for each frequency band
%             band_table = array2table(data(:, :, i));
% 
%             % Create array for frequency band
%             band_label(1:size(epoch_order_pruned, 1), 1) = bands.names(i);
% 
%             % Add information to data table
%             band_data = table(band_label,...
%                 [epoch_order_pruned.type],...
%                 [epoch_order_pruned.epoch],...
%                 [epoch_order_pruned.word],...
%                 [band_table],...
%                 'VariableNames', {'band', 'condition', 'epoch', 'word', 'cross_correlation'});
%             
%             % Row bind to data table
%             data_table = [data_table; band_data];
%         end
%     end

    %% Quit
    quit
end
