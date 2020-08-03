function [] = convolve_and_cross_correlate_formants(subject_number)
    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd('/Applications/eeglab2019/talker-change-data-processing')
    addpath(fullfile('data', subject_number)) % add subject data to path
    addpath(fullfile('data/stim/formants')) % add audio stimuli directory to path
    
    % Import EEG data
    eeg_data = load('eeg_data');
    eeg_data = eeg_data.('eeg_data');

    % Import original epoch order
    epoch_order_original = load('epoch_order_original');
    epoch_order_original = epoch_order_original.('epoch_order_original');

    % Import pruned epoch order
    epoch_order_pruned = load('epoch_order_pruned');
    epoch_order_pruned = epoch_order_pruned.('epoch_order_pruned');

    % Import stimuli order
    stim_order = readtable('stim_order.txt');

    %% 2. Match EEG epochs with words
    % Sort original epoch order by condition
    epoch_order_original = struct2table(epoch_order_original);
    epoch_order_original = sortrows(epoch_order_original, 'type');
    epoch_order_original = epoch_order_original(endsWith(epoch_order_original.type, 'E'),:);

    % Sort pruned epoch order by condition
    epoch_order_pruned = struct2table(epoch_order_pruned);
    epoch_order_pruned = sortrows(epoch_order_pruned, 'type');

    % Match pruned epochs with corresponding epochs
    k = 1;
    for j = 1:height(epoch_order_original)
        % Match original epochs with corresponding stim 
        epoch_order_original.word(j) = stim_order.ending(j);
        
        % Break at the end of pruned epochs to avoid exceeding array length
        if k > height(epoch_order_pruned)
            break
        end
        
        % Match pruned epochs with corresponding stim
        if epoch_order_original.urevent(j) == epoch_order_pruned.urevent(k)
            epoch_order_pruned.word(k) = stim_order.ending(j);
            k = k+1;
        end
    end

    % Sort pruned epoch order by latency
    epoch_order_pruned = sortrows(epoch_order_pruned, 'latency');
    
    %% 3. Convolve
    formants = {'f0', 'f1', 'f2', 'f3'};
    % Initialize data tables (epochs * channels * formants)
    cross_correlation = zeros(size(eeg_data, 3), size(eeg_data, 1), size(formants, 2));
    
    % Loop over formants
    for i = 1:length(formants)
        formant = formants(i);
        fprintf(1, ['Correlating eeg data with audio files filtered for ', char(formant), '\n'])
    
        % Loop over channels
        for j = 1:size(eeg_data, 1)
            fprintf(1, ['Channel #', num2str(j), '\n'])

            % Loop over epochs
             for k = 1:size(eeg_data, 3)
                 epoch = eeg_data(j, :, k);

                 % Load stimuli .wav file for epoch
                 word = strcat(erase(char(epoch_order_pruned.word(k)), ".wav"), "_", formant, ".wav");
                 auditory_stimuli = audioread(word);

                 % Compute convolution and cross correlation
                 cross_correlation(k, j, i) = i+j+k;
                 cross_correlation(k, j, i) = mean(xcorr(epoch, auditory_stimuli)); % should be #stim x #channels

             end
        end
    end

    %% 4. Write data
    % Add relevant info to data tables
    f0_cross_correlation_data_table = save_corr(cross_correlation, epoch_order_pruned, 'f0', formants);
    f1_cross_correlation_data_table = save_corr(cross_correlation, epoch_order_pruned, 'f1', formants);
    f2_cross_correlation_data_table = save_corr(cross_correlation, epoch_order_pruned, 'f2', formants);
    f3_cross_correlation_data_table = save_corr(cross_correlation, epoch_order_pruned, 'f3', formants);
    
    % Write data
    cross_correlation_data_table = [f0_cross_correlation_data_table;
        f0_cross_correlation_data_table; 
        f0_cross_correlation_data_table; 
        f0_cross_correlation_data_table];
    fp = fullfile('data', subject_number, 'formants_cross_correlation_data_table');
    fprintf(1, strcat('Writing file to ', fp))
    save(fp, 'cross_correlation_data_table');
    
    function [cross_correlation_data_table] = save_corr(cross_correlation, epoch_order_pruned, formant, formants)
        % Index into correlations of specified formant
        formant_table = find(contains(formants, formant));
        cross_correlation = array2table(cross_correlation(:, :, formant_table));
        
        % Create array for formants
        formant_array(1:length(cross_correlation)) = formant;
        
        % Add information to data table
        cross_correlation_data_table = table(formant_array,...
            [epoch_order_pruned.type],...
            [epoch_order_pruned.epoch],...
            [epoch_order_pruned.word],...
            [cross_correlation],...
            'VariableNames', {'formant', 'condition', 'epoch', 'word', 'cross_correlation'});
    end

%     [y, Fs] = audioread('bruh.mp3')
%     sound(y,Fs)

    %% Quit
    quit
end
