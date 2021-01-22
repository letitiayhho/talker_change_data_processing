function[] = shape_rms(git_home)
%% Shape_rms
% DESCRIPTION:
%     Takes rms values for each subject and concat into one file
%
% OUTPUT:
%     Writes files shuffed_<statistic>.csv and <statistic>.csv

arguments
    git_home string = '/Users/letitiaho/src/talker_change_data_processing'
end

%% Main
% get file names

file_struct = dir(fullfile('data/*/rms.mat'));

% average across original data

% average across all shuffled data and combine into one table

% write to spreadsheet
% writetable(original_averages, strcat('data/aggregate/rms.csv'))

%% Functions
    function [combined] = combine_rms(file_struct)
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, 'rms.mat');
            load(path)
            
%             subject_number = string(extractAfter(data_files(i).folder, 'data/'));
%             cross_correlations.subject(:) = subject_number;
        end
% 
% % function to get all shuffled data file_names
%     function [full_file_names] = get_file_names(path, statistic)
%         file_struct = dir(fullfile('data/*/rms'));
%     end
% 
% % function to load data
%     function [shuffled_averages] = get_shuffled_averages(file_names)
%         shuffled_averages = [];
%         for i = 1:length(file_names)
%             averages = average_across_conditions(file_names(i));
%             shuffle_number = repmat(i, 6, 1);
%             averages.Properties.RowNames = string(shuffle_number) + averages.Properties.RowNames;
%             averages = addvars(averages, shuffle_number, 'Before', 'condition', 'NewVariableNames', 'shuffle_number');
%             shuffled_averages = [shuffled_averages; averages];
%         end
%     end
% 
% % function to average across subjects by condition
%     function [averages] = average_across_conditions(file_name)
%         data = load(file_name{:}).data;
%         remove_subjects = removevars(data, 'subject');
%         averages = grpstats(remove_subjects, 'condition');
%     end

    quit
end
