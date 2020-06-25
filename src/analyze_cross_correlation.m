function [] = analyze_cross_correlation()
    fprintf(1, 'Computes average cross-correlation between eeg signal and audio stimuli across all subjects, channels and trials for each condition')

    %% Main
    % Get global variables
    [number_of_conditions, number_of_subjects] = get_global_vars();

    % Split four-letter condition code up into individual arrays for each IV
    [split_conditions] = get_split_conditions();

    % Get subject means
    [subject_means] = get_subject_means(number_of_conditions, number_of_subjects);

    % Get summary statistics
    [condition_means] = get_summary_statistics(subject_means, split_conditions);

    % Run a Three-Way ANOVA
    [t] = get_three_way_anova(subject_means, split_conditions);

    %% Helper functions
        %% Load data of a single subject
        function [cross_correlations] = load_single_subject_data(i)
            correlation_data_files = dir('data/**/cross_correlation_data_table.mat');
            cross_correlation_data_table_full_path = fullfile(correlation_data_files(i).folder, 'cross_correlation_data_table.mat');
            cross_correlations = load(cross_correlation_data_table_full_path);
            cross_correlations = cross_correlations.('cross_correlation_data_table');
        end

        %% Get global variables
        function [number_of_conditions, number_of_subjects] = get_global_vars()
            number_of_subjects = size(dir('data/**/cross_correlation_data_table.mat'), 1);
            cross_correlations = load_single_subject_data(1);
            number_of_conditions = length(unique(cross_correlations.condition));
        end

        %% Split four-letter condition code up into individual arrays for each IV
        function [split_conditions] = get_split_conditions()
            % G/S: general (i.e. low) vs specific (i.e. high) constraint sentence stems
            % M/N: meaningful vs nonsense ending word in the context of the rest of the sentence
            % S/T: same vs different talker in the ending word

            % Conditions
            cross_correlations = load_single_subject_data(1);
            conditions = unique(cross_correlations.condition);

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
        function [subject_means] = get_subject_means(number_of_conditions, number_of_subjects)

            % Initialize subject means data table
            subject_means = zeros(number_of_conditions, number_of_subjects); 

            % Interate across subjects
            for i = 1:number_of_subjects

                % Load each file and turn into table for easy manipulation
                cross_correlations = load_single_subject_data(i);
                cross_correlations_expanded = table2array(cross_correlations.convolution);

                % Get channel means within each subject
                trials = size(cross_correlations, 1);
                trial_means = zeros(trials, 1);
                for k = 1:size(cross_correlations, 1)
                    trial_means(k) = mean(cross_correlations_expanded(k, :));
                end

                % Get condition means within each subject
                cross_correlations.trial_means = trial_means;
                group_means = groupsummary(cross_correlations,...
                    'condition',...
                    'mean',...
                    'trial_means');
                group_means.Properties.VariableNames{3} = 'group_means';

                % Write to subject means data table
                subject_means(:, i) = group_means.group_means;
                % maybe something like subject_means((i-1)*11+j) nah
            end
        end

        %% Run a Three-Way ANOVA
        function [t] = get_three_way_anova(subject_means, split_conditions)

            % Preallocate memory
            length = size(subject_means, 1) * size(subject_means, 2);
            constraint = char(zeros(length, 1));
            meaning = char(zeros(length, 1));
            talker = char(zeros(length, 1));
            means = zeros(length, 1);

            % Dumb patch to get data into desired format, interate over conditions
            for i = 1:size(subject_means, 1)

                % Iterate over subjects
                for j = 1:size(subject_means, 2)
                    constraint((i-1)*11+j) = split_conditions.constraint(i);
                    meaning((i-1)*11+j) = split_conditions.meaning(i);
                    talker((i-1)*11+j) = split_conditions.talker(i);
                    means((i-1)*11+j) = subject_means(i, j);
                end
            end

            % Write into table
            % means_wider = table(constraint_wider, meaning_wider, talker_wider, means);

            % Compute Three-Way ANOVA
            t = anovan(means,...
                {constraint, meaning, talker},...
                'model',...
                'interaction',...
                'varnames',...
                {'constraint','meaning','talker'})
        end

        %% Get summary statistics
        function [condition_means] = get_summary_statistics(subject_means, split_conditions)

            % Normalize
            normalized_subject_means = normalize(subject_means);

            % Calculate means and sds
            means = mean(normalized_subject_means, 2);
            sds = std(normalized_subject_means, [], 2);

            % Combine into a data table
            condition_means = [split_conditions, array2table(means), array2table(sds)];
        end
end