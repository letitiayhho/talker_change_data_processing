function [] = compute_coherence_full(git_home, subject_number)
    %% Set up
    cd(git_home)
    addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
    addpath(fullfile('1_preprocessing/data/', subject_number)) % add subject stim order to path
    addpath(fullfile('3_cross_correlate/data', subject_number)) % add subject data to path
    addpath('6_coherence/data') % add path to stim_pitches
    addpath('tools/vendor/chronux') % add chronux scripts
  
    % Import EEG data
    eeg_data = load('eeg_data').eeg_data;

    % Import pruned epoch order
%     stim_order = load('stim_order').stim_order;

    %% 2. Coherence
    n_trials = size(eeg_data, 3);
    n_chans = size(eeg_data, 1);
    n_freqs = 1025;
    coher = zeros(n_trials, n_chans, n_freqs);

    % Loop over channels
    fprintf(1, 'Channel #')
    for chan = 1:n_chans
        fprintf(1, strcat(num2str(chan), ', #'))

        % Loop over epochs
        for trial = 1:n_trials

            % Extract eeg epoch and interpolate
            eeg = double(eeg_data(chan, :, trial));

            % Load stimuli .wav file for epoch
            word = char(stim_order.word(trial));
            stim = audioread(word);
            stim = resample(stim, 10, 441);
            pad = zeros(length(eeg) - length(stim), 1);
            stim = [stim; pad];

            % Get coherence
            params = struct('Fs', 1000, 'tapers', [10, 10]);
            [C,~,~,~,~,~] = coherencyc(stim, eeg, params);
            
            coher(trial, chan, :) = C;
        end
    end
    
    coher = reshape(coher, [n_trials * n_chans, n_freqs]);
    condition = load('split_conditions.mat').split_conditions;
    condition = repmat(condition, [n_chans, 1]); 
    
    data_frame = [
        table(repmat(subject_number, [n_trials * n_chans, 1]), 'VariableNames', {'subject_number'}),...
        table(repelem((1:128), n_trials).', 'VariableNames', {'channel'}),...
        condition,...
%         table(repmat(stim_order.epoch, [n_chans, 1]), 'VariableNames', {'epoch'}),...
%         table(repmat(stim_order.word, [n_chans, 1]), 'VariableNames', {'word'}),...
        array2table(coher)];
%     data_frame.Properties.VariableNames = cellstr(['subject_number', 'channel',...
%         'constraint', 'meaning', 'talker', 'epoch', 'word', string(1:1025)]);
    data_frame.Properties.VariableNames = cellstr(['subject_number', 'channel',...
        'constraint', 'meaning', 'talker', string(1:1025)]);
    
   % Average by condition
   data_frame = grpstats(data_frame, ["subject_number", "channel", "constraint", "meaning", "talker"], 'mean');

    fp = fullfile('6_coherence/data', subject_number, 'coherence.mat');
    fprintf(1, ['\nWriting data to /', fp, '\n'])
    save(fp, 'data_frame')
end