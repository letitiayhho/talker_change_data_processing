function[] = get_rms(git_home, subject_number)
arguments
    git_home string = '/Users/letitiaho/src/talker_change_data_processing'
    subject_number char
end

    fprintf(1, strcat('Computing RMS from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('data', subject_number)) % add subject data to path
    
    % Import EEG data
    load('eeg_data');
    
    % Import pruned epoch order
    stim_order = get_stim_order(subject_number);

    %% 3. Compute RMS
    % Initialize data table
    epoch_rms = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    for i = 1:size(eeg_data, 1)
        disp(strcat('Channel #', num2str(i)))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)
             
             % Compute RMS
             epoch = eeg_data(i, :, j);
             epoch_rms(j, i) = rms(epoch);
         end
    end

    %% 4. Write data
    epoch_rms = array2table(epoch_rms);
    rms_data_table = table([stim_order.type],...
        [stim_order.epoch],...
        [stim_order.word],...
        [epoch_rms],...
        'VariableNames', {'condition', 'epoch', 'word', 'rms'});
    
    % Write data
    save(fullfile('data', subject_number, 'rms'), 'rms_data_table')
    
    %% Quit
    quit
end