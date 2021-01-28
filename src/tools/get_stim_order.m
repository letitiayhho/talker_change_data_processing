function [stim_order] = get_stim_order(subject_number, unique_id, shuffle)
% DESCRIPTION:
%     Get the stimuli file names 

arguments
    subject_number char
    unique_id string = ''
    shuffle logical = false
end

    fprintf(1, strcat('Fetching stim order for subject #', subject_number, '\n'))

    %% 1. Import data
    addpath(fullfile('data', subject_number)) % add subject data to path
    load('eeg_data');
    load('epoch_order_original');
    load('epoch_order_pruned');
    stim_order_original = readtable('stim_order.txt');

    %% 2. Match EEG epochs with words
    % Sort original epochs by condition as stim_order.txt is sorted
    % by condition
    epoch_order_original = struct2table(epoch_order_original);
    epoch_order_original = sortrows(epoch_order_original, 'type');
    epoch_order_original = epoch_order_original(endsWith(epoch_order_original.type, 'E'),:);

    % Sort pruned epochs by condition
    epoch_order_pruned = struct2table(epoch_order_pruned);
    epoch_order_pruned = sortrows(epoch_order_pruned, 'type');

    % Match pruned epochs with corresponding epochs
    j = 1;
    for i = 1:height(epoch_order_original)
        % Match original epochs with corresponding stim 
        epoch_order_original.word(i) = stim_order_original.ending(i);
        
        % Break at the end of pruned epochs to avoid exceeding array length
        if j > height(epoch_order_pruned)
            break
        end
        
        % Match pruned epochs with corresponding stim
        if epoch_order_original.urevent(i) == epoch_order_pruned.urevent(j)
            epoch_order_pruned.word(j) = stim_order_original.ending(i);
            j = j+1;
        end
    end
    epoch_order_pruned = sortrows(epoch_order_pruned, 'latency');

    %% 3. Scramble if specified
    if shuffle
        s = RandStream('dsfmt19937', 'Seed', str2double(unique_id));
        stim_order = epoch_order_pruned(randperm(s, size(epoch_order_pruned, 1)), :);
        stim_order
    else
        stim_order = epoch_order_pruned;
    end
end
