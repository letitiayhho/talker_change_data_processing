% function [] = convolve_and_cross_correlate(subject_number)
subject_number = '302';

if 1
    %% 1. Import data
    addpath('./analysis')
    addpath(fullfile('./preprocessing', subject_number))
    addpath('./preprocessing/stim')

    % Import EEG data
    eeg_data = load('preprocessed_eeg_data');
    eeg_data = eeg_data.('preprocessed_eeg_data');

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
    convolution = zeros(size(eeg_data, 3), size(eeg_data, 1));
    cross_correlation = zeros(size(eeg_data, 3), size(eeg_data, 1));
    
    % Loop over channels
    for i = 1:size(eeg_data, 1)
        disp(strcat('Channel #', num2str(i)))
        
        % Loop over epochs
         for j = 1:size(eeg_data, 3)
             epoch = eeg_data(i, :, j);
             
             % Load stimuli .wav file for epoch
             word = char(epoch_order_pruned.word(j));
             auditory_stimuli = audioread(word);

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
