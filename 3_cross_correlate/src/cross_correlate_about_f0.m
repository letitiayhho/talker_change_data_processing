function [] = cross_correlate_about_f0(git_home, subject_number, band)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlations.mat

arguments
    git_home string
    subject_number char
    band char {mustBeMember(method,{'f0','below_f0','above_f0'})}
end

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('1_preprocessing/data', subject_number)) % add subject data to path
    addpath(fullfile('3_cross_correlate/data/stim/', band)) % add audio stimuli directory to path
    addpath(fullfile('3_cross_correlate/data', subject_number))

    % Import EEG data
    eeg_data = load('eeg_data').eeg_data;

    % Import pruned epoch order
    stim_order = load('stim_order').stim_order;

    %% 2. Cross correlate
    average = zeros(size(eeg_data, 3), size(eeg_data, 1));

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
             
             % Pad the stimuli signal to make it the same length as the eeg
             pad = zeros(length(epoch) - length(stim), 1);
             stim = [stim; pad];

             % Compute convolution and cross correlation
             [cross_correlations, ~] = xcorr(stim, epoch, 'normalized');

             % Write statistics to data arrays
             average(j, i) = mean(cross_correlations);
         end
    end

    %% 3. Split condition codes up
    condition = load('split_conditions.mat').split_conditions;

    %% 4. Save data frame
    % Create data frame
    data_frame = [
        table(repmat(subject_number, size(stim_order, 1), 1), 'VariableNames', {'subject_number'}),...
        condition,...
        table(stim_order.epoch, 'VariableNames', {'epoch'}),...
        table(stim_order.word, 'VariableNames', {'word'}),...
        array2table(data)];
    data_frame.Properties.VariableNames = cellstr(['subject_number',...
        'constraint', 'meaning', 'talker', 'epoch', 'word', string(1:128)]);

    % Save
    fp = fullfile('3_cross_correlate/data', subject_number, ['average_', band, '.mat']);
    fprintf(1, ['\nWriting data to /', fp, '\n'])
    save(fp, 'data_frame')

    quit
end
