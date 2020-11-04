function[] = shape_shuffles(statistic)
%% Shape_shuffles.m
% DESCRIPTION:
%     Takes resampled cross correlation averages or maximums and
%     concatenates them all into a .csv file
%
% OUTPUT:
%     Writes files shuffed_<statistic>.csv and <statistic>.csv

%% Main
% get file names
resampled_files = get_file_names('data/aggregate/shuffles/', statistic);
original_files = get_file_names('data/aggregate/', statistic);

% average across original data
original_averages = average_across_conditions(original_files);

% average across all resampled data and combine into one table
resampled_averages = get_resampled_averages(resampled_files);

% write to spreadsheet
writetable(original_averages, strcat('data/aggregate/', statistic, '.csv'))
writetable(resampled_averages, strcat('data/aggregate/shuffled_', statistic, '.csv'))

%% Functions
% function to get all resampled data file_names
    function [full_file_names] = get_file_names(path, statistic)
        dir_details = what(path);
        all_mat_files = dir_details.mat;
        file_names = all_mat_files(contains(all_mat_files, statistic));
        full_file_names = strcat(path, file_names);
    end

% function to load data
    function [resampled_averages] = get_resampled_averages(file_names)
        resampled_averages = [];
        for i = 1:length(file_names)
            averages = average_across_conditions(file_names(i));
            resample_number = repmat(i, 6, 1);
            averages.Properties.RowNames = string(resample_number) + averages.Properties.RowNames;
            averages = addvars(averages, resample_number, 'Before', 'condition', 'NewVariableNames', 'resample');
            resampled_averages = [resampled_averages; averages];
        end
    end

% function to average across subjects by condition
    function [averages] = average_across_conditions(file_name)
        data = load(file_name{:}).data;
        remove_subjects = removevars(data, 'subject');
        averages = grpstats(remove_subjects, 'condition');
    end
end
