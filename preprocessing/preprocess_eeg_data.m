function [] = preprocess_eeg_data(subject_number, eeg_data_file_name, channel_location_file_name)
    % Print given args
    subject_number
    eeg_data_file_name
    channel_location_file_name
    
    % Set error breakpoint
    dbstop if error
    
    %% 1. Open EEGLAB
    fprintf(1, '\n\n1. Opening EEGLAB\n\n\n')
    cd('/Applications/eeglab2019')
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG.etc.eeglabvers = '2019.1'; % this tracks which version of EEGLAB is being used, you may ignore it
    cd(fullfile('/Applications/eeglab2019/uddin_preprocessing/preprocessing', subject_number))
    
    %% 2. Import data
    fprintf(1, '\n\n2. Importing eeg data\n\n\n')
    EEG = pop_fileio(fullfile('/Applications/eeglab2019/uddin_preprocessing/preprocessing/raw_eeg_data', eeg_data_file_name), 'dataformat','auto'); % read data
    EEG = eeg_checkset( EEG ); % check the consistency of the fields of an EEG dataset
    set_name = subject_number % name dataset
    EEG = name_and_save(EEG, set_name);
        
        % 2.1 Save original epoch order
        epoch_order_original = EEG.event;
        save('epoch_order_original', 'epoch_order_original');
        
    % 3. Filter
    fprintf(1, '\n\n3. Filtering data from 0.3-400 Hz, notch filtering at 60 Hz\n\n\n')
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.3,'hicutoff',400);
    EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1);
    EEG = pop_eegfiltnew(EEG, 'locutoff',119,'hicutoff',121,'revfilt',1);
    EEG = pop_eegfiltnew(EEG, 'locutoff',179,'hicutoff',181,'revfilt',1);
    EEG = pop_eegfiltnew(EEG, 'locutoff',239,'hicutoff',241,'revfilt',1);
    set_name = strcat(set_name, '_fil')
    EEG = name_and_save(EEG, set_name);
    
    % 4. Set channel locations
    fprintf(1, '\n\n4. Setting channel locations\n\n\n')
    EEG=pop_chanedit(EEG, 'lookup', fullfile('/Applications/eeglab2019/uddin_preprocessing/preprocessing/raw_eeg_data', channel_location_file_name),'setref',{'128' ''});
    
        % 4.1 Re-reference to Cz
        fprintf(1, '\n\n4.1. Re-referencing data to Cz\n\n\n')
        EEG = pop_reref( EEG, 128,'keepref','on');
        set_name = strcat(set_name, '_rcz')
        EEG.setname = set_name;
    
        % 4.2 Reject bad channels with clean_artifacts
        fprintf(1, '\n\n4.2. Rejecting bad channels with clean_artifacts\n\n\n')
        originalEEG = EEG; % keep original data for interpolation
        EEG = clean_artifacts(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','on','Distance','Euclidian');
        set_name = strcat(set_name, '_chn')
        EEG.setname = set_name;

        % 4.3 Interpolate channels
        fprintf(1, '\n\n4.3. Interpolating removed channels\n\n\n')
        EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
        set_name = strcat(set_name, '_int')
        EEG.setname = set_name;
        
        % 4.4 Re-reference to average
        fprintf(1, '\n\n4.4. Re-referencing data to average\n\n\n')
        EEG = pop_reref( EEG, []);
        set_name = strcat(set_name, 'rav')
        EEG = name_and_save(EEG, set_name);
   
    % 5. Clean continuous data
    fprintf(1, '\n\n5. Cleaning continuous data\n\n\n')
    EEG = clean_artifacts(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
    set_name = strcat(set_name, '_cln')
    EEG = name_and_save(EEG, set_name);
    
    %% 6. Extract epochs
    fprintf(1, '\n\n6. Extracting epochs\n\n\n')
    EEG = pop_epoch( EEG, {  'GMSE'  'GMTE'  'GNSE'  'GNTE'  'SMSE'  'SMTE'  'SNSE'  'SNTE'  }, [0  1.5], 'epochinfo', 'yes');
    set_name = strcat(set_name, '_epo')
    EEG = name_and_save(EEG, set_name);
    
    %% 7. Decompose data by ICA
    
        % 7.1 Check ICA rank and run ICA
        fprintf(1, '\n\n7.1 Running ICA ')
        data_rank = rank(double(EEG.data(:,:)'));
        fprintf(1, strcat('with rank:', data_rank, '\n\n\n'))
        EEG = pop_runica(EEG,'extended',1,'interupt','on','pca', data_rank);
        set_name = strcat(set_name, '_ica')
        EEG.setname = set_name;
        
        % Reject bad trials (do not remove components, rank will decrease)
        pop_eegplot( EEG, 1, 1, 1);
        
        
        % Re-run ICA
    
        % 7.2 Reject components with ICLabel
        fprintf(1, '\n\n7.2 Reject ICA components with ICLabel\n\n\n')
        EEG = pop_icflag(EEG, [NaN NaN;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1]);
        EEG = pop_iclabel(EEG, 'default');
        set_name = strcat(set_name, '_pru')
        EEG = name_and_save(EEG, set_name);

        % 7.3 Save pruned epoch order
        epoch_order_pruned = EEG.event;
        save('epoch_order_pruned', 'epoch_order_pruned');
        
    %% 8. Export
    fprintf(1, '\n\n8. Exporting preprocessed eeg data\n\n\n')
    preprocessed_eeg_data = EEG.data;
    save('preprocessed_eeg_data', 'preprocessed_eeg_data');
    
    return
    
    %% Helper functions
    function [ EEG ] = name_and_save(EEG, set_name)
        EEG.setname = set_name;
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name);
        EEG = pop_saveset( EEG, 'filename', set_name);
    end
end
