% function [] = convolve_and_cross_correlate(subject_number)
subject_number = '302';
if 1
% 1. Import data: EEG data and stimuli order files
% 2. Match EEG epochs with words
% 3. Convolve the .wav files with the epochs files
% 4. Write data

    %% 1. Import data
    cd('~/Documents/Work/Research/s_uddin/analysis');

    % Import EEG data
    eeg_dir = 'eeg_data';
    eeg_filename = strcat('preprocessed_', subject_number);
    eeg_data = load(fullfile(eeg_dir, eeg_filename), eeg_filename);
    eeg_data = eeg_data.(eeg_filename);

    % Import original epoch order
    eeg_epochs_original_filename = strcat('epoch_order_original_', subject_number);
    epoch_order_original = load(fullfile(eeg_dir, eeg_epochs_original_filename), eeg_epochs_original_filename);
    epoch_order_original = epoch_order_original.(eeg_epochs_original_filename);

    % Import pruned epoch order
    eeg_epochs_pruned_filename = strcat('epoch_order_pruned_', subject_number);
    epoch_order_pruned = load(fullfile(eeg_dir, eeg_epochs_pruned_filename), eeg_epochs_pruned_filename);
    epoch_order_pruned = epoch_order_pruned.(eeg_epochs_pruned_filename);

    % Import stimuli order 
    stim_order_dir = 'stim_order';
    stim_order_filename = strcat('stim_order_', subject_number, '.txt');
    stim_order = readtable(fullfile(stim_order_dir, stim_order_filename));

    %% 2. Match EEG epochs with words
    % Sort original epoch order by condition
    epoch_order_original = struct2table(epoch_order_original);
    epoch_order_original = sortrows(epoch_order_original, 'type');
    epoch_order_original = epoch_order_original(endsWith(epoch_order_original.type, 'E'),:);

    % Sort pruned epoch order by condition
    epoch_order_pruned = struct2table(epoch_order_pruned);
    epoch_order_pruned = sortrows(epoch_order_pruned, 'type');

    % Match words with remaining epochs
    j = 1;
    for i = 1:height(epoch_order_original)
        if epoch_order_original.urevent(i) == epoch_order_pruned.urevent(j)
            epoch_order_pruned.word(j) = stim_order.ending(j);
            j = j+1;
        end
    end
    
    % Sort pruned epoch order by latency
    epoch_order_pruned = sortrows(epoch_order_pruned, 'latency');

    %% 3. Convolve
    % Initialize data tables
    convolution = zeros(size(eeg_data, 1), size(eeg_data, 3));
    cross_correlation = zeros(size(eeg_data, 1), size(eeg_data, 3));
    
    % Loop over channels
    for i = 1:size(eeg_data, 1)
        disp(strcat('Channel #', num2str(i)))
        
        % Loop over epochs
         for j = 1:size(eeg_data, 3)
             epoch = eeg_data(i, :, j);
             
             % Load stimuli .wav file for epoch
             word = char(epoch_order_pruned.word(j));
             auditory_stimuli = audioread(fullfile('stim', word));

             % Compute convolution and cross correlation
             convolution(j, i) = mean(conv(epoch, auditory_stimuli));
             cross_correlation(j, i) = mean(xcorr(epoch, auditory_stimuli)); % should be #stim x #channels
         end
    end
    
    %% 4. Write data
    % Add relevant info to data tables
    convolution = array2table(convolution);
    convolution_data_table = table([epoch_order_pruned.type],...
        [epoch_order_pruned.epoch],... 
        [epoch_order_pruned.word],...
        [convolution],...
        'VariableNames', {'condition', 'epoch', 'word', 'convolution'});
    
    cross_correlation = array2table(cross_correlation);
    cross_correlation_data_table = table([epoch_order_pruned.type],...
        [epoch_order_pruned.epoch],... 
        [epoch_order_pruned.word],...
        [cross_correlation],...
        'VariableNames', {'condition', 'epoch', 'word', 'convolution'});

    % Write data
    save('convolution_data_table', 'convolution_data_table')
    save('cross_correlation_data_table', 'cross_correlation_data_table')
end
