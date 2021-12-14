function [] = cross_correlate(git_home, subject_number)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlations.mat

arguments
    git_home string
    subject_number char
end

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('1_preprocessing/data', subject_number)) % add subject data to path
    addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
    addpath(fullfile('2_cross_correlate/data', subject_number))

    % Import EEG data
    eeg_data = load('eeg_data').eeg_data;

    % Import pruned epoch order
    stim_order = load('stim_order').stim_order;

    %% 2. Cross correlate
    cross_correlations = zeros(size(eeg_data, 1), 3199, size(eeg_data, 3));

    % Loop over channels
    fprintf(1, 'Channel #')
    for i = 1:size(eeg_data, 1)
        fprintf(1, strcat(num2str(i), ', #'))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)

             % Extract eeg epoch and interpolate
             epoch = double(eeg_data(i, :, j));

             % Load stimuli .wav file for epoch
             word = char(stim_order.word(j));
             stim = audioread(word);
             stim = resample(stim, 10, 441);
             
             % Pad the stimuli signal to make it the same length as the eeg
             pad = zeros(length(epoch) - length(stim), 1);
             stim = [stim; pad];

             % Compute convolution and cross correlation
             cross_correlations(i, :, j) = xcorr(stim, epoch); % all are 3199x1
         end
    end

    %% 3. Split condition codes up
%     condition = load('split_conditions.mat').split_conditions;

    %% 4. Write data files
    
%     function [] = save_xcorr(subject_number, condition, stim_order, data, stat)
%         % Create data frame
%         data_frame = [
%             table(repmat(subject_number, size(stim_order, 1), 1), 'VariableNames', {'subject_number'}),...
%             condition,...
%             table(stim_order.epoch, 'VariableNames', {'epoch'}),...
%             table(stim_order.word, 'VariableNames', {'word'}),...
%             array2table(data)];
%         data_frame.Properties.VariableNames = cellstr(['subject_number',...
%             'constraint', 'meaning', 'talker', 'epoch', 'word', string(1:128)]);
%         
%         % Save
%         fp = fullfile('2_cross_correlate/data', subject_number, [stat, '.mat']);
%         fprintf(1, ['\nWriting data to /', fp, '\n'])
%         save(fp, 'data_frame')
%     end
% 
%     save_xcorr(subject_number, condition, stim_order, maximum, 'maximum')
%     save_xcorr(subject_number, condition, stim_order, lag, 'lag')
%     save_xcorr(subject_number, condition, stim_order, average, 'average')
%     quit
end
