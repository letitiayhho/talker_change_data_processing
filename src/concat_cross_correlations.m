function [] = concat_cross_correlations(git_home, unique_id, cross_correlations_file_name)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home char
    unique_id char = 'cross_correlations'
    cross_correlations_file_name string = 'cross_correlations'
end

    %% Main
    cd(git_home)
    statistics = {'abs_average', 'maximum', 'lag'};
    shape_all(cross_correlations_file_name, statistics)
        
    %% Call shape data on each statistic and append to file
    function shape_all(cross_correlations_file_name, statistics)
        for i = 1:length(statistics)
            statistic = statistics{i};
            data = shape(cross_correlations_file_name, statistic);
            fileID = strcat('data/aggregate/', unique_id, '_', statistic, '.mat');
            
            % Append if file exists, save if not
            if isfile(fileID)
                previous_data = load(fileID).data;
                data = [previous_data; data];
            end
            fprintf(1, strcat('Writing data to /', fileID, '\n'))
            save(fileID, 'data')
        end
    end

    %% Shape data
    function [data] = shape(cross_correlations_file_name, statistic)
        % Set general stats
        number_of_subjects = 11;

        % Create empty table to write data
        data = table();

        % Iterate over subjects
        for i = 1:number_of_subjects
            [cross_correlations] = load_single_subject_data(cross_correlations_file_name, statistic, i);

            % Calculate means for each channel for each condition
            talker = grpstats(removevars(cross_correlations, {'meaning', 'constraint'}), {'subject_number', 'talker'});
            meaning = grpstats(removevars(cross_correlations, {'talker', 'constraint'}), {'subject_number', 'meaning'});
            constraint = grpstats(removevars(cross_correlations, {'talker', 'meaning'}), {'subject_number', 'constraint'});
            
            % Make all variable names the same to combine them into a table
            talker.Properties.VariableNames = ['subject_number', 'condition', 'count', string(1:128)];
            meaning.Properties.VariableNames = ['subject_number', 'condition', 'count', string(1:128)];
            constraint.Properties.VariableNames = ['subject_number', 'condition', 'count', string(1:128)];

            % Combine all subjects into one table
            data = [data; talker; meaning; constraint];
            data.Properties.RowNames = {};
        end
    end

    %% Load data of a single subject
    function [cross_correlations] = load_single_subject_data(cross_correlations_file_name, statistic, i)

        % Get name of the data files and their directory
        file_names = strcat(cross_correlations_file_name, '.mat');
        data_files = dir(fullfile('data/**/', file_names));
        data_file_full_path = fullfile(data_files(i).folder, file_names);

        % Load data
        load(data_file_full_path);

        % Clean up data and split up conditions
        subject_number = cross_correlations.subject_number;
        conditions = get_split_conditions(cross_correlations.condition);
        stat = cell2table(num2cell(cross_correlations.(statistic)));
        cross_correlations = [table(subject_number), conditions, stat];
    end

end
