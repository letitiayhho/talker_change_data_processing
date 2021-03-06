function[rms_data] = get_rms_for_each_subject(subject_number)
% DESCRIPTION:
%     Computes RMS, a measure of overall power, for each trial
%
% OUTPUT:
%     Writes rms.mat for each subject
arguments
    subject_number char
end

    fprintf(1, strcat('Computing RMS from subject #', subject_number, '\n'))

    %% 1. Import data
    addpath(fullfile('data/1_preprocessing', subject_number)) % add subject data to path
    load('eeg_data');
    
    %% 2. Epoch order
    stim_order = get_stim_order(subject_number);

    %% 3. Compute RMS
    % Initialize data table
    epoch_rms = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    for i = 1:size(eeg_data, 1)
        fprintf(1, strcat(num2str(i), ', #'))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)
             
             % Compute RMS
             epoch = eeg_data(i, :, j);
             epoch_rms(j, i) = rms(epoch);
         end
    end

    %% 3. Split condition codes up
    condition = get_split_conditions(stim_order.type);
    
    %% 4. Write data    
    rms_data = [table(repmat(subject_number, size(epoch_rms, 1), 1), 'VariableNames', {'subject_number'}),...
        condition,...
        table(stim_order.epoch, 'VariableNames', {'epoch'}),...
        table(stim_order.word, 'VariableNames', {'word'}),...
        array2table(epoch_rms)];
    save(fullfile('data/5_rms/tmp', subject_number, 'rms'), 'rms_data')
end