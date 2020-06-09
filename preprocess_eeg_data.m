function [] = preprocess_eeg_data(subject_number, eeg_data_file_name, channel_location_file_name)
    %% 1. Open EEGLAB
    cd('/Applications/eeglab2019')
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG.etc.eeglabvers = '2019.1'; % this tracks which version of EEGLAB is being used, you may ignore it
    
    %% 2. Import data
    fprintf(1, 'Importing eeg data\n')
    quit()
    EEG = pop_fileio(fullfile('/Applications/eeglab2019/uddin_preprocessing/raw_data', eeg_data_file_name), 'dataformat','auto'); % read data
    set_name = subject_number; % name dataset
    EEG.setname = set_name; 
    EEG = eeg_checkset(EEG);
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); % copy it to ALLEEG
        
        % 2.1 Save original epoch order
        epoch_order_original = EEG.event;
        save('epoch_order_original');
        
    %% 3. Filter
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.3,'hicutoff',400);
    EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1);
    EEG = pop_eegfiltnew(EEG, 'locutoff',119,'hicutoff',121,'revfilt',1);
    EEG = pop_eegfiltnew(EEG, 'locutoff',179,'hicutoff',181,'revfilt',1);
    EEG = pop_eegfiltnew(EEG, 'locutoff',239,'hicutoff',241,'revfilt',1);
    set_name = strcat(set_name, '_fil');
    EEG.setname = set_name;
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name); % copy changes to ALLEEG        
    
    %% 4. Set channel locations
    EEG=pop_chanedit(EEG, 'lookup', fullfile('/Applications/eeglab2019/uddin_preprocessing/raw_data', channel_location_file_name),'setref',{'128' ''});
    EEG = eeg_checkset( EEG );
    
        % 4.1 Re-reference to Cz
        EEG = pop_reref( EEG, 128,'keepref','on');
        set_name = strcat(set_name, '_rcz');
        EEG.setname = set_name;
    
        % 4.2 Reject bad channels with clean
        originalEEG = EEG; % keep original data for interpolation
        EEG = clean_artifacts(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','on','Distance','Euclidian');
        set_name = strcat(set_name, '_chn');
        EEG.setname = set_name;

        % 4.3 Interpolate channels
        EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
        set_name = strcat(set_name, '_int');
        EEG.setname = set_name;
        
        % 4.4 Re-reference to average
        EEG = pop_reref( EEG, []);
        set_name = strcat(set_name, 'rav');
        EEG.setname = set_name;
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name);
        
   
    %% 5. Clean continuous data
    EEG = clean_artifacts(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
    set_name = strcat(set_name, '_cln');
    EEG.setname = set_name;
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name);
    
    %% 6. Extract epochs
    EEG = pop_epoch( EEG, {  'GMSE'  'GMTE'  'GNSE'  'GNTE'  'SMSE'  'SMTE'  'SNSE'  'SNTE'  }, [0  1.5], 'epochinfo', 'yes');
    set_name = strcat(set_name, '_epo');
    EEG.setname = set_name;
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name);
    
    %% 7. Decompose data by ICA
    
        % 7.1 Check ICA rank and run ICA
        data_rank = rank(double(EEG.data'));
        % EEG = pop_runica(EEG, 'icatype', 'runica',
        % 'extended',1,'interrupt','on'); % Original ICA call
        EEG = pop_runica(EEG,'extended',1,'interupt','on','pca', data_rank);
        set_name = strcat(set_name, '_ica');
        EEG.setname = set_name;
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name);
    
        % 7.2 Reject components
        EEG = pop_icflag(EEG, [NaN NaN;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1]);
        EEG = pop_iclabel(EEG, 'default');
        set_name = strcat(set_name, '_pru');
        EEG.setname = set_name;
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name);
        EEG = pop_saveset( EEG, 'savemode','resave');

        % 7.3 Save pruned epoch order
        epoch_order_pruned = EEG.event;
        save('epoch_order_pruned');
        
    %% 8. Export
    preprocessed_eeg_data = EEG.data;
    save('preprocessed_eeg_data');
end