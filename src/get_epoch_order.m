function [epoch_order_pruned] = get_epoch_order(subject_number)
% DESCRIPTION:
%     Get the pruned epoch order and corresponding stim files
%
% INPUT:
%     subject_number (char) - input subject numbers as strings, e.g. '302'
%
% OUTPUT:
%     Writes files named <cross_correlation/convolution>_data_table.mat

    fprintf(1, strcat('Fetching epoch order for subject #', subject_number, '\n'))

    %% 1. Import data
    addpath(fullfile('data', subject_number)) % add subject data to path
    
    % Import EEG data
    eeg_data = load('eeg_data').eeg_data;

    % Import original epoch order
    epoch_order_original = load('epoch_order_original').epoch_order_original;

    % Import pruned epoch order
    epoch_order_pruned = load('epoch_order_pruned').epoch_order_pruned;

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
    j = 1;
    for i = 1:height(epoch_order_original)
        % Match original epochs with corresponding stim 
        epoch_order_original.word(i) = stim_order.ending(i);
        
        % Break at the end of pruned epochs to avoid exceeding array length
        if j > height(epoch_order_pruned)
            break
        end
        
        % Match pruned epochs with corresponding stim
        if epoch_order_original.urevent(i) == epoch_order_pruned.urevent(j)
            epoch_order_pruned.word(j) = stim_order.ending(i);
            j = j+1;
        end
    end

    % Sort pruned epoch order by latency
    epoch_order_pruned = sortrows(epoch_order_pruned, 'latency');
end