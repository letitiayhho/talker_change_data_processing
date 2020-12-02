function [] = shape_data(git_home, unique_id, cross_correlations_file_name)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home string
    unique_id string
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
            [subject_number, conditions, cross_correlations] = load_single_subject_data(cross_correlations_file_name, statistic, i);

            % Split conditions up
            split_conditions = get_split_conditions(conditions);

            % Add condition codes to data table
            cross_correlations = [split_conditions, cross_correlations];

            % Add subject number to data table
            cross_correlations.subject(:) = subject_number;
            cross_correlations = movevars(cross_correlations, 'subject', 'Before', 'constraint');
            
            % Calculate means for each channel for each condition
            talker = grpstats(removevars(cross_correlations, {'meaning', 'constraint'}), {'subject', 'talker'});
            meaning = grpstats(removevars(cross_correlations, {'talker', 'constraint'}), {'subject', 'meaning'});
            constraint = grpstats(removevars(cross_correlations, {'talker', 'meaning'}), {'subject', 'constraint'});
            
            % Clean up the data table, add labels
            talker = removevars(talker, {'GroupCount'}); 
            meaning = removevars(meaning, {'GroupCount'});
            constraint = removevars(constraint, {'GroupCount'}); 
            
            % Change variable names
            talker.Properties.VariableNames = ['subject', 'condition', string(1:128)];
            talker.Properties.RowNames = {};
            meaning.Properties.VariableNames = ['subject', 'condition', string(1:128)];
            meaning.Properties.RowNames = {};
            constraint.Properties.VariableNames = ['subject', 'condition', string(1:128)];
            constraint.Properties.RowNames = {};

            % Combine all subjects into one tabled
            data = [data; talker; meaning; constraint];
        end
    end

    %% Load data of a single subject
    function [subject_number, conditions, cross_correlations] = load_single_subject_data(cross_correlations_file_name, statistic, i)

        % Get name of the data files and their directory
        file_names = strcat(cross_correlations_file_name, '.mat');
        data_files = dir(fullfile('data/**/', file_names));
        data_file_full_path = fullfile(data_files(i).folder, file_names);

        % Load data
        load(data_file_full_path);

        % Bind to variables for returning
        subject_number = string(extractAfter(data_files(i).folder, 'data/'));
        conditions = cross_correlations.condition;
        cross_correlations = cell2table(num2cell(cross_correlations.(statistic)));
    end

end
