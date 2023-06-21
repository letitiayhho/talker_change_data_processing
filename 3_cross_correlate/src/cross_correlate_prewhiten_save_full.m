function [] = cross_correlate_prewhiten_save_full(git_home, subject_number)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlations.mat
% 

    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('1_preprocessing/data', subject_number)) % add subject data to path
    addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
    addpath(fullfile('3_cross_correlate/data', subject_number))
    eeg_data = load('eeg_data').eeg_data;
    stim_order = load('stim_order').stim_order;

    %% 2. Cross correlate
    rs = zeros(size(eeg_data, 3), size(eeg_data, 1), 1001);

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
             
             % Resample to 1 kHz
             stim = resample(stim, 10, 441);
             
             % Pad the stimuli signal to make it the same length as the eeg
             pad = zeros(length(epoch) - length(stim), 1);
             stim = [stim; pad];
             
             % Prewhiten the eeg signal
             prewhitened_epoch = prewhiten(epoch);

             % Compute convolution and cross correlation 
             [r, ~] = xcorr(stim, prewhitened_epoch, 500, 'normalized');

             % Write statistics to data arrays
             rs(j, i, :) = r;
         end
    end

    %% 3. Split condition codes up
    condition = load('split_conditions.mat').split_conditions;

    %% 4. Write data files
    fp = fullfile('3_cross_correlate/data', subject_number, 'rs_prewhitened.mat');
    fprintf(1, ['\nWriting data to /', fp, '\n'])
    save(fp, 'rs')

end
