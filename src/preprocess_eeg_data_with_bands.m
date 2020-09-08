function [] = preprocess_eeg_data(subject_number, band)
% DESCRIPTION:
%     Takes the preprocessed eeg data and convolves or cross-correlates the 
%     waveforms with the waveform of the auditory stimuli
%
% INPUT:
%     subject_number (char) - input subject numbers as strings, e.g. '302'
%     band (char) - eeg band you want to extract from the signal, options
%     are 'delta' (1-4), 'theta' (4-8), 'alpha' (8-14), 'beta1' (14-20), 
%     'beta2' (20-30), 'gamma1' (30-50), 'gamma2' (50-100 Hz)
%
% OUTPUT:
%     Writes files named eeg_data_<band>.mat

    % Print given args
    fprintf(1, strcat('Preprocessing data for ', subject_number))
    cd(fullfile('data', subject_number))

    %% 1. Open EEGLAB
    fprintf(1, '\n\n1. Opening EEGLAB\n\n\n')
    addpath('/Applications/eeglab2019')
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG.etc.eeglabvers = '2019.1'; % tracks which version of EEGLAB is being used

    % Set error breakpoint
    dbstop if error

    %% 2. Import data
    fprintf(1, '\n\n2. Importing eeg data\n\n\n')
    EEG = pop_fileio('eeg_data.raw', 'dataformat', 'auto')
    EEG = eeg_checkset( EEG ); % check the consistency of the fields of an EEG dataset
    set_name = subject_number % name dataset
    EEG = name_and_save(EEG, set_name);

        % 2.2 Save original epoch order
        epoch_order_original = EEG.event;
        save('epoch_order_original', 'epoch_order_original');

    % 3. Filter
    
        % 3.1 Extract low and high cutoff for filtering
        bands.names = {'delta', 'theta', 'alpha', 'beta1', 'beta2', 'gamma1', 'gamma2'};
        bands.lower_lims = [1, 4, 8, 14, 20, 30, 50];
        bands.upper_lims = [4, 8, 14, 20, 30, 50, 100];
        cutoff = find(strcmp(bands.names, band))
    
    fprintf(1, '\n\n3. Filtering data \n\n\n')
    EEG = pop_eegfiltnew(EEG, 'locutoff',bands.lower_lims(cutoff),'hicutoff',bands.upper_lims(cutoff));
    set_name = strcat(set_name, '_fil')
    EEG = name_and_save(EEG, set_name);

    % 4. Set channel locations
    fprintf(1, '\n\n4. Setting channel locations\n\n\n')
    EEG = pop_chanedit(EEG, 'lookup', 'channel_locations.sfp', 'setref', {'128' ''});

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
        set_name = strcat(set_name, '_rav')
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
        EEG = pop_saveset( EEG, 'filename', set_name);

        % 7.3 Save pruned epoch order
        epoch_order_pruned = EEG.event;
        save('epoch_order_pruned', 'epoch_order_pruned');

    %% 8. Export
    fprintf(1, '\n\n8. Exporting preprocessed eeg data\n\n\n')
    eeg_data = EEG.data;
    save(strcat('eeg_data_', band), 'eeg_data');

    quit

    %% Helper functions
    function [ EEG ] = name_and_save(EEG, set_name)
        EEG.setname = set_name;
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', set_name);
%        EEG = pop_saveset( EEG, 'filename', set_name);
    end
end
