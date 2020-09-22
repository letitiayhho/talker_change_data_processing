function [] = shape_data(git_home, file_name)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition
%
% INPUT:
%   git_home - (char) path to git root directory
%   file_name - (char) 'cross_correlations'

    %% Main
    cd(git_home)
    shape_all(file_name)
        
    %% Call shape data on each statistic
    function shape_all(file_name)
        for i = 1:4
            statistics = {'average', 'abs_average', 'lag', 'maximum'};
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
            if contains(file_name, 'formant') 
                subject_means = grpstats(subject_data, {'condition', 'formant'});
            else
                subject_means = grpstats(subject_data, {'condition'});
            end

            % Split conditions up
            conditions = subject_means.condition;
            split_conditions = get_split_conditions(conditions);

            % Clean up the data table, add labels
            subject_means = removevars(subject_means, {'condition', 'GroupCount'}); 
%             subject_means.Properties.VariableNames = ['formant', string(1:128)];
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
    function [subject_data, subject_number] = load_single_subject_data(file_name, statistic, i)
        methods = {'cross_correlations'};
        if ~ismember(file_name, methods)
            % Throw an error if incorrect method is specified
            error('File name not found')
        end

        % Get name of the data files and their directory
        file_names = strcat(file_name, '.mat');
        data_files = dir(fullfile('data/**/', file_names));
        data_file_full_path = fullfile(data_files(i).folder, file_names);

        % Get subject number
        subject_number = string(extractAfter(data_files(i).folder, 'data/'));

        % Load data
        subject_data = load(data_file_full_path);
        subject_data = subject_data.cross_correlations;

        % Convert into easily accessible form
        if contains(file_name, 'formant')
            subject_data = cell2table([subject_data.formant, subject_data.condition, num2cell(subject_data.(statistic))]);
            subject_data.Properties.VariableNames = ['formant', 'condition', string(1:128)];
        else
            subject_data = cell2table([subject_data.condition, num2cell(subject_data.(statistic))]);
            subject_data.Properties.VariableNames = ['condition', string(1:128)];
        end
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
