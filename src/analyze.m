% DESCRIPTION:
%   Computes average cross-correlation between eeg signal and audio 
%   stimuli across all subjects, channels and trials for each condition
%
% INPUT:
%   method - (char) 'cross_correlation' or 'convolution'
%   area - (char) 'anterior temporal', 'central temporal', 'premotor' or
%   'all'

method = 'cross_correlation';
area = 'central temporal';

%% Main
% Get the channels corresponding to the specified cortical area
[channels] = get_channels(area);

% Shape data for further analysis
[data] = shape_data(method);

% Get means for specified channels
[summary_statistics] = get_summary_statistics(data, channels);

% Pairwise t-test between the levels of each condition 
[pairwise_h, pairwise_p, pairwise_t] = all_pairwise_t_tests(data);

% Get clusters based on pairwise t-test results
[constraint_clusters] = get_clusters(pairwise_h, 'constraint');
[meaning_clusters] = get_clusters(pairwise_h, 'meaning');
[talker_clusters] = get_clusters(pairwise_h, 'talker');

% Get cluster-level statistics
[constraint_cluster_stats, constraint_cluster_max] = get_cluster_stats(pairwise_t, constraint_clusters, 'constraint');
[meaning_cluster_stats, meaning_cluster_max] = get_cluster_stats(pairwise_t, meaning_clusters, 'meaning');
[talker_cluster_stats, talker_cluster_max] = get_cluster_stats(pairwise_t, talker_clusters, 'talker');

% Conduct permutation test

% Three-Way ANOVA, mostly compare with check previous script
[t] = get_three_way_anova(data, channels) 

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

%% Shape data
function [data] = shape_data(method)
    % Set general stats
    number_of_subjects = 11;

    % Create empty table to write data
    data = table();

    % Iterate over subjects
    for i = 1:number_of_subjects
        [subject_data, subject_number] = load_single_subject_data(method, i);

        % Normalize data
%         normalized_subject_data = table2array(removevars(subject_data, {'condition'}));
%         normalized_subject_data = normalize(normalized_subject_data);
%         subject_data = [subject_data.condition, array2table(normalized_subject_data)];
%         subject_data.Properties.VariableNames = ['condition', string(1:128)];

        % Calculate means for each channel for each condition
        subject_means = grpstats(subject_data, 'condition');

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

%% Summary statistics
function [summary_statistics] = get_summary_statistics(data, channels)
    % Get means for all channels
    data = removevars(data, {'subject_number'});
    channel_means = grpstats(data, {'constraint', 'meaning', 'talker'});
    
    % Extract means for specified channels
    summary_statistics = table();
    for i = 1:length(channels)
        channel = strcat('mean_', string(channels(i)));
        summary_statistics = [summary_statistics, channel_means(:, channel)];
    end
end

%% Run a Three-Way ANOVA
function [t] = get_three_way_anova(data, channels) 
    % Average over channels in the specified area 
    channel_data = zeros(88, length(channels));
    for i = 1:length(channels)
        channel_data(:, i) = data.(string(channels(i)));
    end
    means = mean(channel_data, 2);
    
    % Extract columns from data table into separate arrays for ANOVA
    constraint = data.constraint;
    meaning = data.meaning;
    talker = data.talker;

    % Compute Three-Way ANOVA
    t = anovan(means,...
        {constraint meaning talker},...
        'model',...
        'interaction',...
        'varnames',...
        {'constraint','meaning','talker'});
end

%% Conduct all pairwise t-tests
function [pairwise_h, pairwise_p, pairwise_t] = all_pairwise_t_tests(data)
    
    % Preallocate memory
    pairwise_h = zeros(3, 128);
    pairwise_p = zeros(3, 128);
    pairwise_t = zeros(3, 128);
    
    % Run pairwise t-tests
    conditions = {'constraint'; 'meaning'; 'talker'};
    for i = 1:128
        for j = 1:3
            condition = conditions(j);
            [h, p, ~, stats] = one_t_test(data, i, condition);
            pairwise_h(j, i) = h;
            pairwise_p(j, i) = p;
            pairwise_t(j, i) = stats.tstat;
        end
    end
    
    % Add condition labels as row names
    pairwise_h = array2table(pairwise_h, 'RowNames', conditions, 'VariableNames', string(1:128));
    pairwise_p = array2table(pairwise_p, 'RowNames', conditions, 'VariableNames', string(1:128));
    pairwise_t = array2table(pairwise_t, 'RowNames', conditions, 'VariableNames', string(1:128));
end

%% Get clusters
function [clusters] = get_clusters(pairwise_h, condition);
    % Get values and initialize state machine
    values = table2array(pairwise_h(condition, :));
    clusters = [];
    cluster = [];
    state = 'B';
    
    % Baby state machine
    for i = 1:size(values, 2)
        current_value = values(i);
        if current_value == 1
            state = 'A';
            cluster = [cluster, i];
        elseif current_value == 0 && strcmp(state, 'B')
            state = 'B';
            if length(cluster) > 1
                cluster = {cluster};
                clusters = [clusters, cluster];
                cluster = [];
            else
                cluster = [];
            end
        elseif current_value == 0 && strcmp(state, 'A')
            state = 'B';
        end
    end
end

%% Get cluster stats
function [cluster_stats, cluster_max] = get_cluster_stats(pairwise_t, clusters, condition)
    % Get t-values
    t_values = table2array(pairwise_t(condition, :));
    
    % Get sum of the t-values within every cluster
    cluster_stats = [];
    for i = 1:size(clusters, 2)
        cluster = cell2mat(clusters(1, i));
        cluster_stat = mean(t_values(:, cluster));
        cluster_stats = [cluster_stats, cluster_stat];
    end
    
    % Get maximum value
    cluster_max = max(cluster_stats);
end

%% Other helper functions

    %% Load data of a single subject
    function [subject_data, subject_number] = load_single_subject_data(method, i)
        if ~strcmp(method, 'cross_correlation') && ~strcmp(method, 'convolution')
            % Throw an error if incorrect method is specified
            error('Invalid method, valid methods are ''convolution'' and ''cross_correlation''')
        end
        
        % Get name of the data files and their directory
        file_names = strcat(method, '_data_table.mat');
        data_files = dir(fullfile('data/**/', file_names));
        data_table_full_path = fullfile(data_files(i).folder, file_names);
        
        % Get subject number
        subject_number = string(extractAfter(data_files(i).folder, 'data/'));

        % Load data
        subject_data = load(data_table_full_path);
        subject_data = subject_data.(strcat(method, '_data_table'));

        % Convert into easily accessible form
        subject_data = [subject_data.condition, subject_data.convolution];
        subject_data.Properties.VariableNames = ['condition', string(1:128)];
    end

    %% Split four-letter condition code up into individual arrays for each IV
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
    
    %% Function for conducting an individual t-test
    function [h, p, ci, stats] = one_t_test(data, channel, condition)
        % Get values into right class to be used as indexes
        channel = string(channel);
        condition = string(condition);
        
        % Separate groups for t-test
        if strcmp(condition, 'constraint')
            x = data.(channel)(data.(condition) == 'G');
            y = data.(channel)(data.(condition) == 'S');
        elseif strcmp(condition, 'meaning')
            x = data.(channel)(data.(condition) == 'M');
            y = data.(channel)(data.(condition) == 'N');
        elseif strcmp(condition, 'talker')
            x = data.(channel)(data.(condition) == 'S');
            y = data.(channel)(data.(condition) == 'T');
        else
            error('Invalid condition, valid options are ''constraint'', ''meaning'', ''talker''')
        end

        % Conduct t-test
        [h, p, ci, stats] = ttest(x, y);
    end
    
    %% Check data
    function [subject_means_2] = check_data(data, channels)
        % Get conditions
        constraint = data.constraint;
        meaning = data.meaning;
        talker = data.talker;

        % CHECK
        subject_means_2 = [];
        for i = 1:length(channels)
            subject_means_2 = [subject_means_2, data.(string(channels(i)))];
        end
        subject_means_2 = mean(subject_means_2, 2);
        subject_means_2 = table(constraint, meaning, talker, subject_means_2);
        subject_means_2 = sortrows(subject_means_2, {'constraint', 'meaning', 'talker'});

    end