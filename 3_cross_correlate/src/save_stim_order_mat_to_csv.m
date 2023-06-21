% DESCRIPTION:
%     convert stim_order.mat to stim_order.csv

cd('/Users/letitiaho/src/talker_change_data_processing')
subject_numbers = readtable("0_set_up_and_raw_data/data/subject_numbers.txt", 'ReadVariableNames', false).Var1;

for i = 1:numel(subject_numbers)
    subject_number = subject_numbers(i)
    stim_order_mat_path = strcat("3_cross_correlate/data/", num2str(subject_numbers(i)), "/stim_order.mat")
    stim_order_csv_path = strcat("3_cross_correlate/data/", num2str(subject_numbers(i)), "/stim_order.csv")

    stim_order_table = load(stim_order_mat_path).stim_order;
    writetable(stim_order_table, stim_order_csv_path);  
end

