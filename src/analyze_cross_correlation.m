
%% Should be able to replace the get_subject_means function


%% Main
% Get list of all cross correlation result data tables
correlation_data_files = dir('data/**/cross_correlation_data_table.mat');

% Get global variables
[trials, channels, conditions] = get_global_vars(correlation_data_files);

% Split four-letter condition code up into individual arrays for each IV
[constraint, meaning, talker] = get_split_conditions(conditions);

% Get subject means
[subject_means] = get_subject_means(correlation_data_files, trials);

% Get summary statistics
[condition_means] = get_summary_statistics(subject_means, constraint, meaning, talker)

% Run a Three-Way ANOVA
[t] = get_three_way_anova(subject_means, constraint, meaning, talker)

    %% Get global variables
    function [trials, channels, conditions] = get_global_vars(correlation_data_files)
    
        % Load one data table
        cross_correlation_data_table_full_path = fullfile(correlation_data_files(1).folder, 'cross_correlation_data_table.mat');
        cross_correlation_data_table = load(cross_correlation_data_table_full_path);
        cross_correlation_data_table = cross_correlation_data_table.('cross_correlation_data_table');

        % Assign commonly used variables
        trials = size(cross_correlation_data_table, 1);
        channels = size(cross_correlation_data_table.convolution, 2);
        conditions = unique(cross_correlation_data_table.condition);
    end

    %% Split four-letter condition code up into individual arrays for each IV
    function [constraint, meaning, talker] = get_split_conditions(conditions)
        % G/S: general (i.e. low) vs specific (i.e. high) constraint sentence stems
        % M/N: meaningful vs nonsense ending word in the context of the rest of the sentence
        % S/T: same vs different talker in the ending word
        
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
    end

    %% Get subject means
    function [subject_means] = get_subject_means(correlation_data_files, trials)

        % Initialize subject means data table
        subject_means = zeros(8, size(correlation_data_files, 1)); 

        for i = 1:size(correlation_data_files, 1)

            % Load each file and turn into table for easy manipulation
            cross_correlation_data_table_full_path = fullfile(correlation_data_files(i).folder, 'cross_correlation_data_table.mat');
            cross_correlation_data_table = load(cross_correlation_data_table_full_path);
            cross_correlation_data_table = cross_correlation_data_table.('cross_correlation_data_table');

            % Get channel means within each subject
            cross_correlations = table2array(cross_correlation_data_table.convolution);
            trial_means = zeros(trials, 1);
            for k = 1:size(cross_correlations, 1)
                trial_means(k) = mean(cross_correlations(k, :));
            end

            % Get condition means within each subject
            cross_correlation_data_table.trial_mean = trial_means;
            group_means = groupsummary(cross_correlation_data_table,...
                'condition',...
                'mean',...
                'trial_mean');
            group_means.Properties.VariableNames{3} = 'group_means';

            % Write to subject means data table
            subject_means(:, i) = group_means.group_means;
        end
    end

    %% Get summary statistics
    function [condition_means] = get_summary_statistics(subject_means, constraint, meaning, talker)

        % Normalize
        normalized_subject_means = normalize(subject_means);

        % Calculate means and sds
        means = mean(normalized_subject_means, 2);
        sds = std(normalized_subject_means, [], 2);
        
        % Combine into a data table
        condition_means = table(constraint, meaning, talker, means, sds);
    end

    %% Run a Three-Way ANOVA
    function [t] = get_three_way_anova(subject_means, constraint, meaning, talker)
    
        % Preallocate memory
        length = size(subject_means, 1) * size(subject_means, 2);
        constraint_wider = char(zeros(length, 1));
        meaning_wider = char(zeros(length, 1));
        talker_wider = char(zeros(length, 1));
        means = zeros(length, 1);
        
        % Dumb patch to get data into desired format, interate over conditions
        for i = 1:size(subject_means, 1)
            
            % Iterate over subjectsz
            for j = 1:size(subject_means, 2)
                constraint_wider((i-1)*11+j) = constraint(i);
                meaning_wider((i-1)*11+j) = meaning(i);
                talker_wider((i-1)*11+j) = talker(i);
                means((i-1)*11+j) = subject_means(i, j);
            end
        end
        
        % Write into table
        % means_wider = table(constraint_wider, meaning_wider, talker_wider, means);
        
        % Compute Three-Way ANOVA
        t = anovan(means,...
            {constraint_wider, meaning_wider, talker_wider},...
            'model',...
            'interaction',...
            'varnames',...
            {'constraint','meaning','talker'})
    end
    