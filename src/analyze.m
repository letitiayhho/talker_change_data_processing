function [] = analyze(method, area)
% DESCRIPTION:
%   Computes average cross-correlation between eeg signal and audio 
%   stimuli across all subjects, channels and trials for each condition
%
% INPUT:
%   method - (char) 'cross_correlation' or 'convolution'
%   channels - (double) array containing the channels you wish you analyze
%           [34; 38] for anterior temporal channels
%           [40; 44; 45; 46] for central temporal channels
%           [:] for all channels

    %% Main
    % Get channels
    [channels] = get_channels(area)
    
    % Split four-letter condition code up into individual arrays for each IV
    [split_conditions] = get_split_conditions(method);

    % Get subject means
    [subject_means, two_way_subject_means] = get_subject_means(method, split_conditions, channels);

    % Get summary statistics
    [condition_means] = get_summary_statistics(subject_means);

    % Run a Three-Way ANOVA
%     [t] = get_three_way_anova(subject_means)
    
    % Run Friedman's non-parametric test
%     [p] = get_friedmans(two_way_subject_means)

    % Run a permutation test
%     [p] = get_permutation_test(subject_means)

%% Helper functions
    %% Get channels
    function [channels] = get_channels(area)
        if strcmp(area, 'anterior temporal')
            channels = [34, 38];
        elseif strcmp(area, 'central temporal')
            channels = [40, 44, 45, 46];
        elseif strcmp(area, 'premotor')
            channels = [29];
        elseif strcmp(area, 'all')
            channels = [1:128];

        % Throw an error if the chosen area is not an ROI
        else
            error('Invalid cortical area, valid options are ''anterior temporal'', ''central temporal'', ''premotor'', and ''all''')
        end
    end

    %% Load data of a single subject
    function [data] = load_single_subject_data(method, i)
        if strcmp(method, 'cross_correlation') || strcmp(method, 'convolution')
            file_names = strcat(method, '_data_table.mat');
            data_files = dir(fullfile('data/**/', file_names));
            data_table_full_path = fullfile(data_files(i).folder, file_names);
            data = load(data_table_full_path);
            data = data.(strcat(method, '_data_table'));
        else
            error('Invalid method, valid methods are ''convolution'' and ''cross_correlation''')
        end
    end

    %% Split four-letter condition code up into individual arrays for each IV
    function [split_conditions] = get_split_conditions(method)
            % G/S: general (i.e. low) vs specific (i.e. high) constraint sentence stems
            % M/N: meaningful vs nonsense ending word in the context of the rest of the sentence
            % S/T: same vs different talker in the ending word

        % Conditions
        data = load_single_subject_data(method, 1);
        conditions = unique(data.condition);

        % Preallocate memory for iv arrays
        constraint = char(zeros(8, 1));
        meaning = char(zeros(8, 1));
        talker = char(zeros(8, 1));

        for i = 1:size(conditions, 1)
            condition = char(conditions(i, :));
            constraint(i, :) = condition(1);
            meaning(i, :) = condition(2);
            talker(i, :) = condition(3);
        end

        % Create table of separated IVs
        split_conditions = table(constraint, meaning, talker);
    end

    %% Get subject means
    function [subject_means, two_way_subject_means] = get_subject_means(method, split_conditions, channels)
        number_of_subjects = 11;
        number_of_conditions = 8;

        % Preallocate memory
        length = number_of_conditions * number_of_subjects;
        constraint = char(zeros(length, 1));
        meaning = char(zeros(length, 1));
        talker = char(zeros(length, 1));
        means = zeros(length, 1);
        two_way_subject_means = zeros(number_of_subjects, number_of_conditions);

        % Iterate across subjects
        for i = 1:number_of_subjects

            % Iterate across conditions
            for j = 1:number_of_conditions

                % Load each subject's data and turn into table for easy manipulation
                data = load_single_subject_data(method, i);
                data_expanded = table2array(data.convolution);

                % Get means for each channel
                trials = size(data, 1);
                trial_means = zeros(trials, 1);
                data_subset = data_expanded(:, channels);

                for trial = 1:trials
                    trial_means(trial) = mean(data_subset(trial, :));
                end

                % Get means for each condition
                data.trial_means = trial_means;
                group_means = groupsummary(data,...
                    'condition',...
                    'mean',...
                    'trial_means');
                group_means.Properties.VariableNames{3} = 'group_means';

                % Write values to iv arrays for ANOVA
                constraint((j-1)*11+i) = split_conditions.constraint(j);
                meaning((j-1)*11+i) = split_conditions.meaning(j);
                talker((j-1)*11+i) = split_conditions.talker(j);
                means((j-1)*11+i) = group_means.group_means(j);

                % Write two-way table for Friedman's non-parametric test
                two_way_subject_means(i, :) = group_means.group_means;
            end
        end

        % Combine iv arrays into data table for ANOVA
        subject_means = table(constraint, meaning, talker, means);

    end

    %% Get summary statistics
    function [condition_means] = get_summary_statistics(subject_means)
        condition_means = grpstats(subject_means,...
            {'constraint', 'meaning', 'talker'},...
            {'mean', 'std'},...
            'DataVars', 'means');
    end

    %% Run a Three-Way ANOVA
    function [t] = get_three_way_anova(subject_means) 
        % Extract columns from data table into separate arrays for ANOVA
        means = subject_means.means;
        constraint = subject_means.constraint;
        meaning = subject_means.meaning;
        talker = subject_means.talker;

        % Compute Three-Way ANOVA
        t = anovan(means,...
            {constraint meaning talker},...
            'model',...
            'interaction',...
            'varnames',...
            {'constraint','meaning','talker'});
    end

      %% Run Friedman's non-parametric test
%         function [p] = get_friedmans(two_way_subject_means)
%             number_of_subjects = size(two_way_subject_means, 1);
%             p = friedman(two_way_subject_means, 1);
%         end
end