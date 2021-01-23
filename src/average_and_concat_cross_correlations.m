function [] = average_and_concat_cross_correlations(git_home, unique_id)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home char
end

    %% Main
    cd(git_home)
    file_struct = dir(fullfile('data/*/cross_correlations.mat'));
    statistics = {'maximum', 'lag'};
    shape_all(file_struct, statistics)
        
    %% Call shape data on each statistic and append to file
    function shape_all(file_struct, statistics)
        for i = 1:length(statistics)
            statistic = statistics{i};
            data = shape(file_struct, statistic);
            fileID = strcat('data/aggregate/cross_correlations_', statistic, '.mat');
            
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
    function [data] = shape(file_struct, statistic)
        % Set general stats
        number_of_subjects = 11;

        % Create empty table to write data
        data = table();

        % Iterate over subjects
        for i = 1:number_of_subjects
            path = fullfile(file_struct(i).folder, 'rms.mat');
            [cross_correlations] = load_single_subject_data(path, statistic);

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
    function [cross_correlations] = load_single_subject_data(path, statistic)
        
        % Load data
        load(path);

        % Clean up data and split up conditions
        subject_number = cross_correlations.subject_number;
        conditions = get_split_conditions(cross_correlations.condition);
        stat = cell2table(num2cell(cross_correlations.(statistic)));
        cross_correlations = [table(subject_number), conditions, stat];
    end

end
