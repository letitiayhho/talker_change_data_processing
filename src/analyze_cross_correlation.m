function [] = analyze_cross_correlation()
% Computes average cross-correlation between eeg signal and audio 
% stimuli across all subjects, channels and trials for each condition

    %% Main
    % Get global variables
    [number_of_conditions, number_of_subjects] = get_global_vars();

    % Split four-letter condition code up into individual arrays for each IV
    [split_conditions] = get_split_conditions();

    % Get subject means
    [subject_means] = get_subject_means(split_conditions, number_of_conditions, number_of_subjects);

    % Get summary statistics
    [condition_means] = get_summary_statistics(subject_means);

    % Run a Three-Way ANOVA
    [t] = get_three_way_anova(subject_means)

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
            number_of_conditions = size(unique(cross_correlations.condition), 1);
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
        function [subject_means] = get_subject_means(split_conditions, number_of_conditions, number_of_subjects)
            
            % Preallocate memory
            length = number_of_conditions * number_of_subjects;
            constraint = char(zeros(length, 1));
            meaning = char(zeros(length, 1));
            talker = char(zeros(length, 1));
            means = zeros(length, 1);

            % Interate across subjects
            for i = 1:number_of_subjects
                
                % Iterate across conditions
                for j = 1:number_of_conditions

                    % Load each subject's data and turn into table for easy manipulation
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

                    % Write values to iv arrays
                    constraint((j-1)*11+i) = split_conditions.constraint(j);
                    meaning((j-1)*11+i) = split_conditions.meaning(j);
                    talker((j-1)*11+i) = split_conditions.talker(j);
                    means((j-1)*11+i) = group_means.group_means(j);
                end
            end
            
            % Create data table
            subject_means = table(constraint, meaning, talker, means);
        end

        %% Get summary statistics
        function [condition_means] = get_summary_statistics(subject_means)
            % Compute average for each condition
            condition_means = grpstats(subject_means,...
                {'constraint', 'meaning', 'talker'},...
                {'mean', 'std'},...
                'DataVars', 'means');
        end
        
        %% Run a Three-Way ANOVA
        function [t] = get_three_way_anova(subject_means)  
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
end