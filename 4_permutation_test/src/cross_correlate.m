function [cross_correlations_file_name] = cross_correlate(git_home, subject_number, unique_id, shuffle)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlations.mat or
%     cross_correlations_shuffled.mat

arguments
    git_home string
    subject_number char
    unique_id char = ""
    shuffle logical = false
end

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('1_preprocessing/data', subject_number)) % add subject data to path
    addpath(fullfile('0_set_up_and_raw_data/data/stim/original')) % add audio stimuli directory to path
    addpath(fullfile('2_cross_correlate/data', subject_number))

    % Import EEG data
    load('eeg_data')

    % Import pruned epoch order
    load('stim_order')

    %% 2. Cross correlate
    abs_average = zeros(size(eeg_data, 3), size(eeg_data, 1));
    maximum = zeros(size(eeg_data, 3), size(eeg_data, 1));
    lag = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    fprintf(1, 'Channel #')
    for i = 1:size(eeg_data, 1)
        fprintf(1, strcat(num2str(i), ', #'))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)

             % Extract eeg epoch and interpolate
             epoch = double(eeg_data(i, :, j));
             epoch = resample(epoch, 44100, 1000);

             % Load stimuli .wav file for epoch
             word = char(stim_order.word(j));
             stim = audioread(word);
             
             % Pad the stimuli signal to make it the same length as the eeg
             pad = zeros(length(epoch) - length(stim), 1);
             stim = [stim; pad];

             % Compute convolution and cross correlation
             [cross_correlations, lags] = xcorr(stim, epoch, 'normalize');

             % Write statistics to data arrays
             abs_average(j, i) = mean(abs(cross_correlations));
             [maximum(j, i), I] = max(cross_correlations);
             lag(j, i) = lags(I);
         end
    end

    %% 3. Split condition codes up
    condition = load('split_conditions').split_conditions;

    %% 4. Write data files
    function [] = save_xcorr(shuffle, unique_id, subject_number, condition, stim_order, data, stat)
        data_frame = [
            table(repmat(subject_number, size(stim_order, 1), 1), 'VariableNames', {'subject_number'}),...
            condition,...
            table(stim_order.epoch, 'VariableNames', {'epoch'}),...
            table(stim_order.word, 'VariableNames', {'word'}),...
            array2table(data)];
        data_frame.Properties.VariableNames = cellstr(['subject_number',...
            'constraint', 'meaning', 'talker', 'epoch', 'word', string(1:128)]);
        
        % Create filename
        if shuffle
            fp = [unique_id, '_', stat, '_shuffle'];
        else
            fp = fullfile('2_cross_correlate/data', subject_number, [stat, 'test']);
        end
        
        fprintf(1, ['\nWriting data to /', fp, '\n'])
        save(fp, data_frame)
    end

    save_xcorr(shuffle, unique_id, subject_number, condition, stim_order, maximum, 'maximum')
    save_xcorr(shuffle, unique_id, subject_number, condition, stim_order, lag, 'lag')
    save_xcorr(shuffle, unique_id, subject_number, condition, stim_order, abs_average, 'abs_average')
    
%     % Create data frames
%     data_frame = [
%         table(repmat(subject_number, size(stim_order, 1), 1), 'VariableNames', {'subject_number'}),...
%         condition,...
%         table(stim_order.epoch, 'VariableNames', {'epoch'}),...
%         table(stim_order.word, 'VariableNames', {'word'})];
%     data_frame_varnames = cellstr(['subject_number',...
%         'constraint', 'meaning', 'talker', 'epoch', 'word', string(1:128)]);
%     maximum = [data_frame, array2table(maximum)];
%     maximum.Properties.VariableNames = data_frame_varnames;
%     lag = [data_frame, array2table(lag)];
%     lag.Properties.VariableNames = data_frame_varnames;
%     abs_average = [data_frame, array2table(abs_average)];
%     abs_average.Properties.VariableNames = data_frame_varnames;
%     
%     % Write data
%     if shuffle
%         max_fp = strcat(unique_id, '_max_shuffle');
%         lag_fp = strcat(unique_id, '_lag_shuffle');
%     else
%         max_fp = strcat('maximum_test');
%         lag_fp = strcat('lag_test');
%         abs_fp = strcat('abs_average');
%     end
%     max_fp = fullfile('2_cross_correlate/data', subject_number, max_fp);
%     lag_fp = fullfile('2_cross_correlate/data', subject_number, lag_fp);
%     abs_fp = fullfile('2_cross_correlate/data', subject_number, abs_fp);
%     fprintf(1, strcat('\nWriting data to /', max_fp, 'and', lag_fp, '\n'))
%     save(max_fp, 'maximum');
%     save(lag_fp, 'lag');
%     save(abs_fp, 'abs_average');
end
