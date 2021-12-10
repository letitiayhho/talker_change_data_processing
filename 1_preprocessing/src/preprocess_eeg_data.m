function [] = preprocess_eeg_data(subject_number)
    % Print given args
    fprintf(1, strcat('Preprocessing data for ', subject_number))

    %% 1. Open EEGLAB
    fprintf(1, '\n\n1. Opening EEGLAB\n\n\n')
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    % Set error breakpoint
%     dbstop if error

    %% 2. Import data
    fprintf(1, '\n\n2. Importing eeg data\n\n\n')
    raw_fp = fullfile('0_set_up_and_raw_data/data', subject_number, 'eeg_data.raw')
    EEG = pop_fileio(raw_fp, 'dataformat', 'auto');
    EEG = eeg_checkset( EEG ); % check the consistency of the fields of an EEG dataset

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

    % 4. Set channel locations
    fprintf(1, '\n\n4. Setting channel locations\n\n\n')
    sfp_fp = fullfile('0_set_up_and_raw_data/data', subject_number, 'channel_locations.sfp')
    EEG = pop_chanedit(EEG, 'lookup', sfp_fp, 'setref', {'128' ''});

        % 4.1 Re-reference to Cz
        fprintf(1, '\n\n4.1. Re-referencing data to Cz\n\n\n')
        EEG = pop_reref( EEG, 128,'keepref','on');

        % 4.2 Reject bad channels with clean_artifacts
        fprintf(1, '\n\n4.2. Rejecting bad channels with clean_artifacts\n\n\n')
        originalEEG = EEG; % keep original data for interpolation
        EEG = clean_artifacts(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','on','Distance','Euclidian');

        % 4.3 Interpolate channels
        fprintf(1, '\n\n4.3. Interpolating removed channels\n\n\n')
        EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');

        % 4.4 Re-reference to average
        fprintf(1, '\n\n4.4. Re-referencing data to average\n\n\n')
        EEG = pop_reref( EEG, []);

    % 5. Clean continuous data
    fprintf(1, '\n\n5. Cleaning continuous data\n\n\n')
    EEG = clean_artifacts(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );

    %% 6. Extract epochs
    fprintf(1, '\n\n6. Extracting epochs\n\n\n')
    EEG = pop_epoch( EEG, {  'GMSE'  'GMTE'  'GNSE'  'GNTE'  'SMSE'  'SMTE'  'SNSE'  'SNTE'  }, [-0.1 1.5], 'epochinfo', 'yes');

    %% 7. Decompose data by ICA

        % 7.1 Check ICA rank and run ICA
        fprintf(1, '\n\n7.1 Running ICA ')
        data_rank = rank(double(EEG.data(:,:)'));
        fprintf(1, strcat('with rank:', data_rank, '\n\n\n'))
        EEG = pop_runica(EEG,'extended',1,'interupt','on','pca', data_rank);

        % Reject bad trials (do not remove components, rank will decrease)
        pop_eegplot( EEG, 1, 1, 1);

        % Re-run ICA

        % 7.2 Reject components with ICLabel
        fprintf(1, '\n\n7.2 Reject ICA components with ICLabel\n\n\n')
        EEG = pop_icflag(EEG, [NaN NaN;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1]);
        EEG = pop_iclabel(EEG, 'default');

        % 7.3 Save pruned epoch order
        epoch_order_pruned = EEG.event;
        save('epoch_order_pruned', 'epoch_order_pruned');

    %% 8. Export
    fprintf(1, '\n\n8. Exporting preprocessed eeg data\n\n\n')
    EEG.setname = subject_number;
    
    % Save as .set
    set_fp = fullfile('1_preprocessing/data', subject_number, 'eeg_data_2.set')
    save(set_fp, 'EEG', '-mat');
    
    % Save as .mat
    eeg_data = EEG.data;
    mat_fp = fullfile('1_preprocessing/data', subject_number, 'eeg_data_2.mat')
    save(mat_fp, 'eeg_data'); 

    quit
end
