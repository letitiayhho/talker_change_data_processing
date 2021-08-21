function [] = compute_coherence(subject_number)
    %% Set up
    cd("/Users/letitiaho/src/talker_change_data_processing")
    addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
    addpath(fullfile('1_preprocessing/data/304')) % add subject data to path
    addpath(fullfile('2_cross_correlate/data', subject_number))
    addpath(fullfile('7_coherence/data/'))
    addpath('tools')

    % Import json file for pitch ranges
    fname = 'stim_pitches.json';
    fid = fopen(fname);
    str = fread(fid, [1 Inf], '*char');
    fclose(fid);
    stim_pitches = jsondecode(str);

    % Import EEG data
    eeg_data = load('eeg_data').eeg_data;

    % Import pruned epoch order
    stim_order = load('stim_order').stim_order;

    %% 2. Coherence
    average_max = zeros(size(eeg_data, 3), size(eeg_data, 1));
    average = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    fprintf(1, 'Channel #')
    for i = 1:size(eeg_data, 1)
        fprintf(1, strcat(num2str(i), ', #'))

        % Loop over epochs
        for j = 1:size(eeg_data, 3)

            % Extract eeg epoch and interpolate
            eeg = double(eeg_data(i, :, j));

            % Load stimuli .wav file for epoch
            word = char(stim_order.word(j));
            stim = audioread(word);
            stim = resample(stim, 10, 441);
            pad = zeros(length(eeg) - length(stim), 1);
            stim = [stim; pad];

            % Get F0 for each syllable
            word = replace(word, '.', '_');
            syllable_F0s = stim_pitches.(word);

            % Get coherence
            params = struct('Fs', 1000, 'tapers', [10, 10]);
            [coherence,~,~,~,~,freq] = coherencyc(stim, eeg, params);

            % Get max coherence surrounding each F0
            max_coherence_each_syllable = zeros(1, length(syllable_F0s));
            avg_coherence_each_syllable = zeros(1, length(syllable_F0s));

            for k = 1:length(syllable_F0s)
                % Set F0 range
                F0_min = syllable_F0s(k) - 5;
                F0_max = syllable_F0s(k) + 5;

                % Find indexes for frequency values within range
                indexes = find(freq > F0_min & freq < F0_max);

                % subset the coherence values matching the range
                coherence_within_range = coherence(indexes);

                % compute the max
                max_coherence_each_syllable = [max_coherence_each_syllable, max(coherence_within_range)];
                avg_coherence_each_syllable = [avg_coherence_each_syllable, mean(coherence_within_range)];
            end
        end

        % Compute the average of both max
        max_trial_coherence = mean(max_coherence_each_syllable);
        avg_trial_coherence = mean(avg_coherence_each_syllable);

        % Write statistics to data arrays
        average_max(j, i) = max_trial_coherence;
        average(j, i) = avg_trial_coherence;
    end

    %% 3. Split condition codes up
    condition = load('split_conditions.mat').split_conditions;

    %% 4. Write data files
    save_xcorr(subject_number, condition, stim_order, average_max, 'average_max')
    save_xcorr(subject_number, condition, stim_order, average, 'average')
    quit

        function [] = save_xcorr(subject_number, condition, stim_order, data, stat)
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
            fp = fullfile('7_coherence/data', subject_number, [stat, '.mat']);
            fprintf(1, ['\nWriting data to /', fp, '\n'])
            save(fp, 'data_frame')
        end
end