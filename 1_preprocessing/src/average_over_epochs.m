cd('/Users/letitiaho/src/talker_change_data_processing')
fileID = fopen('0_set_up_and_raw_data/data/subject_numbers.txt','r');
subject_numbers = fscanf(fileID, '%f');

% all_eeg = [];
for i = 1:length(subject_numbers)
    subject_number = num2str(subject_numbers(i));
    fprintf(1, ['Averaging over epochs for subject ', subject_number, '\n'])
    eeg = load_eeg(subject_number);
    conditions = load_conditions(subject_number);
    eeg = flatten(eeg);
%     eeg = add_subject_number_column(subject_number, eeg);
%     all_eeg = [all_eeg; eeg];
    writematrix(eeg, fullfile('./1_preprocessing/data', subject_number, 'eeg_data.csv'))
end


function [eeg] = load_eeg(subject_number)
    subject_dir = fullfile('./1_preprocessing/data',  subject_number);
    filepath = fullfile(subject_dir, 'eeg_data.mat');
    eeg = load(filepath).eeg_data;
end

function [conditions] = load_conditions(subject_number)
    subject_dir = fullfile('./2_cross_correlate/data',  subject_number);
    filepath = fullfile(subject_dir, 'stim_order.mat');
    conditions = load(filepath).stim_order;
end

function [eeg] = add_subject_number_column(subject_number, eeg)
    subject_number_column(1:size(eeg, 3)) = subject_number;
    eeg = [subject_number_column', eeg];
end

function [eeg] = flatten(eeg)
    eeg = mean(eeg, 3);
end

    
