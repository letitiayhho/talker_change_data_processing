function [] = average_over_epochs(git_home)
arguments
    git_home char
end
    
cd(git_home)
subject_numbers = load_subject_numbers('./0_set_up_and_raw_data/data/subject_numbers.txt');

for i = 1:length(subject_numbers)
    subject_number = num2str(subject_numbers(i));
    fprintf(1, ['Averaging over epochs for subject ', subject_number, '\n'])
    conditions = load_conditions(subject_number);
    eeg = load_eeg(subject_number);
    all_conditions_eeg = average_over_conditions(eeg, conditions);
    savefp = fullfile('./9_N1_RMS/data', subject_number, 'eeg_data_averaged.csv');
    fprintf(1, ['Saving data to ', savefp, '\n'])
    writetable(all_conditions_eeg, savefp)
end

quit

    function [all_conditions_eeg] = average_over_conditions(eeg, conditions)
        all_conditions_eeg = [];
        for talker = ["S", "T"] % double quotes matters! needs to be string not char
            for meaning = ["M", "N"]
                for constraint = ["L", "H"]
                    one_condition_eeg = subset_by_condition(eeg, conditions, talker, meaning, constraint);
                    one_condition_eeg = array2table(flatten(one_condition_eeg));
                    labels = table(repmat(talker, 1, 128)', repmat(meaning, 1, 128)', repmat(constraint, 1, 128)', (1:128)');
                    labels.Properties.VariableNames(1:4) = {'talker', 'meaning', 'constraint', 'channel'};
                    one_condition_eeg = [labels, one_condition_eeg];
                    all_conditions_eeg = [all_conditions_eeg; one_condition_eeg];
                end
            end
        end
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
        filepath = fullfile(subject_dir, 'split_conditions.mat');
        conditions = load(filepath).split_conditions;
    end

    function [eeg] = add_subject_number_column(subject_number, eeg)
        subject_number_column(1:size(eeg, 3)) = subject_number;
        eeg = [subject_number_column', eeg];
    end

    function [eeg] = subset_by_condition(eeg, conditions, talker, meaning, constraint)
        talker_indexes = 1:size(conditions,1);
        meaning_indexes = 1:size(conditions, 1);
        constraint_indexes = 1:size(conditions, 1);
        
        talker_indexes = find(contains(conditions.talker, talker));
        meaning_indexes = find(contains(conditions.meaning, meaning));
        constraint_indexes = find(contains(conditions.constraint, constraint));
        
        % Intersect of all indexes
        indexes = intersect(intersect(talker_indexes, meaning_indexes), constraint_indexes);
        eeg = eeg(:, :, indexes);
    end

    function [eeg] = flatten(eeg)
        eeg = mean(eeg, 3); % data will be 128*1600
    end

end
