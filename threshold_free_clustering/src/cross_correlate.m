function cross_correlate()
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% OUTPUT:
%     Writes files named cross_correlations.mat

    cd '/Users/letitiaho/src/talker_change_data_processing'
    subjects = ["301", "302", "303", "304", "305", "307", "308", "310", "315", "316", "317"];

    for subject = subjects
        fprintf(1, strcat("Cross correlating for subject #", subject, "\n"))
        
        %% 1. Import data
        load(fullfile('1_preprocessing/data', subject, 'eeg_data.mat'), 'eeg_data') % add subject data to path
        addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
        load(fullfile('2_cross_correlate/data', subject, 'stim_order.mat'), 'stim_order')

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

        cross_correlations_fp = fullfile('threshold_free_clustering/data', subject, 'cross_correlations.mat');
        fprintf(1, strcat('\nSaving to ', cross_correlations_fp, '\n'))
        save(cross_correlations_fp, 'cross_correlations')
    end

end
