function [] = get_split_conditions(git_home)
%% Split four-letter condition code up into individual columns
% G/S: general (i.e. low) vs specific (i.e. high) constraint sentence stems
% M/N: meaningful vs nonsense ending word in the context of the rest of the sentence
% S/T: same vs different talker in the ending word

cd(git_home)
subject_numbers = load_subject_numbers('./0_set_up_and_raw_data/data/subject_numbers.txt');

for i = 1:length(subject_numbers)
    subject_number = num2str(subject_numbers(i));
    condition_codes = load_condition_codes(subject_number);
    split_conditions = recode_and_split(condition_codes);
    
    filename = fullfile('2_cross_correlate/data', subject_number, 'split_conditions');
    fprintf(1, ['Saving to ', filename, '.m \n'])
    save(filename, 'split_conditions')
end

quit

%% Functions
    function [subject_numbers] = load_subject_numbers(fp)
        fileID = fopen(fp,'r');
        subject_numbers = fscanf(fileID, '%f');
    end

    function [condition_codes] = load_condition_codes(subject_number)
        addpath(fullfile('2_cross_correlate/data', subject_number))
        stim_order = load('stim_order').stim_order;
        condition_codes = char(stim_order.type);
    end

    function [conditions] = recode_and_split(condition_codes)
        constraint = recode_constraint(condition_codes(:, 1));
        meaning = condition_codes(:, 2);
        talker = condition_codes(:, 3);
        conditions = table(constraint, meaning, talker);
    end

    function [constraint] = recode_constraint(constraint)
        % Recode S to H to avoid clash with same talker condition
        for i = 1:length(constraint)
            if constraint(i) == 'S'
                constraint(i) = 'H';
            else
                constraint(i) = 'L';
            end
        end
    end

end