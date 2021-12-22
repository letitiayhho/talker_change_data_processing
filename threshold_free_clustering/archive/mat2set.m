function [] = mat2set()
    %% 
    % Take all the eeg_data.set files and combine them with the eeg_data.m
    % files that I computed my analyses on
    %% 
    
    cd '/Users/letitiaho/src/talker_change_data_processing'
    subjects = ["301", "302", "303", "304", "305", "307", "308", "310", "315", "316", "317"];
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % need this for the first

    for subject_number = subjects
        subject_number

        % Load the .set file
        set_fp = char(fullfile('0_set_up_and_raw_data/data', subject_number, 'eeg_data.set'))
        [EEG] = pop_loadset(set_fp);

        % Load the .mat file
        mat_fp = fullfile('1_preprocessing/data', subject_number, 'eeg_data.mat')
        load(mat_fp);

        % Check they have the same dimensions
        if (size(EEG.data) ~=  size(eeg_data))
            error("Data sets are not not the same size")
        end

        % Replace EEG.data with data used in my analysis
        EEG.data = eeg_data;

        % Update the ALLEEG every time you modify the EEG structur
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);

        % Save the new EEG data struct as .set
        set_fp = fullfile('1_preprocessing/data', subject_number, 'eeg_data.set')
        save(set_fp, 'EEG', '-mat')

        fprintf('Done\n')
    end
end