function [] = shape_data(git_home, file_name)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition
    arguments
        git_home char
        file_name {mustBeMember(file_name, {'cross_correlations'})} = 'cross_correlations'
    end

    %% Main
    cd(git_home)
    statistics = {'abs_average', 'lag', 'maximum'};
    shape_all(file_name, statistics)
        
    %% Call shape data on each statistic
    function shape_all(file_name, statistics)
        for i = 1:length(statistics)
            statistic = statistics{i};
            [data] = shape_data(file_name, statistic);
            writetable(data, strcat('data/aggregate/', file_name, '_', statistic, '.csv'));
        end
    end

    %% Shape data
    function [data] = shape_data(file_name, statistic)
        % Set general stats
        number_of_subjects = 11;

        % Create empty table to write data
        data = table();

        % Iterate over subjects
        for i = 1:number_of_subjects
            [subject_data, subject_number] = load_single_subject_data(file_name, statistic, i);

            % Calculate means for each channel for each condition
            subject_means = grpstats(subject_data, {'condition'});

            % Split conditions up
            conditions = subject_means.condition;
            split_conditions = get_split_conditions(conditions);

            % Clean up the data table, add labels
            subject_means = removevars(subject_means, {'condition', 'GroupCount'}); 
            subject_means.Properties.VariableNames = string(1:128);
            subject_means.Properties.RowNames = {};

            % Add condition codes to data table
            subject_means = [split_conditions, subject_means];

            % Add subject number to data table
            subject_means.subject_number(:) = subject_number;
            subject_means = movevars(subject_means, 'subject_number', 'Before', 'constraint');

            % Combine all subjects into one table
            data = [data; subject_means];
        end
    end

    %% Load data of a single subject
    function [cross_correlations, subject_number] = load_single_subject_data(file_name, statistic, i)

        % Get name of the data files and their directory
        file_names = strcat(file_name, '.mat');
        data_files = dir(fullfile('data/**/', file_names));
        data_file_full_path = fullfile(data_files(i).folder, file_names);

        % Get subject number
        subject_number = string(extractAfter(data_files(i).folder, 'data/'));

        % Load data
        load(data_file_full_path);

        % Convert into easily accessible form
        cross_correlations = cell2table([cross_correlations.condition, num2cell(cross_correlations.(statistic))]);
        cross_correlations.Properties.VariableNames = ['condition', string(1:128)];
    end

    %% Split four-letter condition code up into individual columns
    function [split_conditions] = get_split_conditions(conditions)
            % G/S: general (i.e. low) vs specific (i.e. high) constraint sentence stems
            % M/N: meaningful vs nonsense ending word in the context of the rest of the sentence
            % S/T: same vs different talker in the ending word

        for i = 1:size(conditions, 1)
            condition = char(conditions(i, :));
            constraint(i, :) = condition(1);
            meaning(i, :) = condition(2);
            talker(i, :) = condition(3);
        end

        % Create table of separated IVs
        split_conditions = table(constraint, meaning, talker);
    end

end
