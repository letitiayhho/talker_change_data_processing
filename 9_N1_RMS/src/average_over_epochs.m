condition = 'high'

cd('/Users/letitiaho/src/talker_change_data_processing')
subject_numbers = load_subject_numbers('0_set_up_and_raw_data/data/subject_numbers.txt');

for i = 1:length(subject_numbers)
    subject_number = num2str(subject_numbers(i));
    fprintf(1, ['Averaging over epochs for subject ', subject_number, '\n'])
    conditions = load_conditions(subject_number);
    eeg = load_eeg(subject_number);
    eeg = subset_by_condition(eeg, conditions, condition);
    eeg = flatten(eeg);
    savefp = fullfile('./9_N1_RMS/data', subject_number, ['eeg_data_', condition, '.csv']);
    fprintf(1, ['Saving data to ', savefp, '\n'])
    writematrix(eeg, savefp)
end

function [subject_numbers] = load_subject_numbers(fp)
    fileID = fopen(fp,'r');
    subject_numbers = fscanf(fileID, '%f');
end

function [eeg] = load_eeg(subject_number)
    fp = fullfile('./9_N1_RMS/data', subject_number, 'baseline_corrected_eeg_data.mat');
    eeg = load(fp).eeg;
end

function [conditions] = load_conditions(subject_number)
    subject_dir = fullfile('./2_cross_correlate/data',  subject_number);
    filepath = fullfile(subject_dir, 'stim_order.mat');
    conditions = load(filepath).stim_order;
    conditions = cell2mat(conditions.type);
end

function [eeg] = add_subject_number_column(subject_number, eeg)
    subject_number_column(1:size(eeg, 3)) = subject_number;
    eeg = [subject_number_column', eeg];
end

function [eeg] = subset_by_condition(eeg, conditions, condition)
    indexes = get_condition_indexes(conditions, condition);
    eeg = eeg(:, :, indexes);
end

function [indexes] = get_condition_indexes(conditions, condition)
    constraint_codes = string(conditions(:, 1));
    meaning_codes = string(conditions(:, 2));
    talker_codes = string(conditions(:, 3));
    if strcmp(condition, 'same')
        indexes = find(contains(talker_codes, 'S'));
    elseif strcmp(condition, 'different')
        indexes = find(contains(talker_codes, 'T'));
    elseif strcmp(condition, 'meaningful')
        indexes = find(contains(meaning_codes, 'M'));
    elseif strcmp(condition, 'nonsense')
        indexes = find(contains(meaning_codes, 'N'));
    elseif strcmp(condition, 'low')
        indexes = find(contains(constraint_codes, 'G'));
    elseif strcmp(condition, 'high')
        indexes = find(contains(constraint_codes, 'S'));
    end
end

function [eeg] = flatten(eeg)
    eeg = mean(eeg, 3);
end

    
