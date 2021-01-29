function [] = concat_cross_correlations(git_home)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home char
end

    %% Main
    cd(git_home)    
    addpath('src/tools/')
    file_struct = dir(fullfile('data/2_cross_correlations/*/cross_correlations.mat'));
    data = combine_cross_correlations(file_struct);
    writetable(data, 'data/5_rms/maximum.csv')
%     quit
        
    %% Combine data file from each subject
    function [data] = combine_cross_correlations(file_struct)
        data = table();
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, 'cross_correlations.mat');
            load_single_subject_data(path);
            cross_correlations = load(path).cross_correlations;
            data = [data; cross_correlations];
        end
    end

    %% Load data of a single subject
    function [cross_correlations] = load_single_subject_data(path)
        
        % Load data
        load(path);

        % Clean up data and split up conditions
        subject_number = cross_correlations.subject_number;
        conditions = get_split_conditions(cross_correlations.condition);
        stat = cell2table(num2cell(cross_correlations.maximum));
        cross_correlations = [table(subject_number), conditions, stat];
    end

end
