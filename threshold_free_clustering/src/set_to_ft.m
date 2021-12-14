function [] = set_to_ft()
    %% 
    % Take all the eeg_data.set files with the correct data, turns them 
    % into fieldtrip formatted data and saves all structs into a cell
    % array written to eeg_data_ft.mat
    %% 
    
    cd '/Users/letitiaho/src/talker_change_data_processing'
    subjects = ["301", "302", "303", "304", "305", "307", "308", "310", "315", "316", "317"];
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % init eeglab
    
    allsubjS = [];
    allsubjT = [];
    allsubjM = [];
    allsubjN = [];
    allsubjL = [];
    allsubjH = [];

    for subject_number = subjects
        fprintf(1, strcat("Converting from .set to fieldtrip format for subject #", subject_number, "\n"))

        % Load the .set file
        set_fp = char(fullfile('1_preprocessing/data', subject_number, 'eeg_data.set'));
        [EEG] = pop_loadset(set_fp);
        
        % Convert to ft data format
        ft = eeglab2fieldtrip(EEG, 'raw');
        
        % Add split conditions to tf.trialinfo
        ft = add_split_conditions(ft, subject_number);
        
        % Split into different datasets by condition
        [ft_S, ft_T, ft_M, ft_N, ft_L, ft_H] = split_ft_by_condition(ft);
        
        % Add to cell array
        allsubjS = [allsubjS, {ft_S}];
        allsubjT = [allsubjT, {ft_T}];
        allsubjM = [allsubjM, {ft_M}];
        allsubjN = [allsubjN, {ft_N}];
        allsubjL = [allsubjL, {ft_L}];
        allsubjH = [allsubjH, {ft_H}];
    end
    
    % Save data
    ft_fp = char(fullfile('threshold_free_clustering/data/eeg_data_ft.mat'));
    fprintf(1, strcat("Saving to: ", ft_fp, "\n"))
    save(ft_fp, 'allsubjS', 'allsubjT', 'allsubjM', 'allsubjN', 'allsubjL', 'allsubjH');
    fprintf('Done\n')

end