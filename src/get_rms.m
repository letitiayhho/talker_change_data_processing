function[] = get_rms(git_home, subject_number)
    fprintf(1, strcat('Analyzing data from subject #', subject_number, '\n'))

    %% 1. Import data
    cd(git_home)
    addpath(fullfile('data', subject_number)) % add subject data to path
    
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

    %% 3. Compute RMS
    % Initialize data table
    epoch_rms = zeros(size(eeg_data, 3), size(eeg_data, 1));

    % Loop over channels
    for i = 1:size(eeg_data, 1)
        disp(strcat('Channel #', num2str(i)))

        % Loop over epochs
         for j = 1:size(eeg_data, 3)
             
             % Compute RMS
             epoch = eeg_data(i, :, j);
             epoch_rms(j, i) = rms(epoch);
         end
    end

    %% 4. Write data
    epoch_rms = array2table(epoch_rms);
    rms_data_table = table([epoch_order_pruned.type],...
        [epoch_order_pruned.epoch],...
        [epoch_order_pruned.word],...
        [epoch_rms],...
        'VariableNames', {'condition', 'epoch', 'word', 'rms'});
    
    % Write data
    save(fullfile('data', subject_number, 'rms'), 'rms_data_table')
    
    %% Quit
    quit
end