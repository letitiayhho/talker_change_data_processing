function [] = concat_xcorr(git_home)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home char
end

    %% Main
    cd(git_home)    
    addpath('tools/')
    file_struct = dir(fullfile('2_cross_correlations/data/*/cross_correlations.mat'));
    data = combine_cross_correlations(file_struct);
    writetable(data, '8_t_tests/data/maximum.csv')
    quit
        
    %% Combine data file from each subject
    function [data] = combine_cross_correlations(file_struct)
        data = table();
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, 'cross_correlations.mat');
            cross_correlations = load(path).cross_correlations;
            data = [data; cross_correlations];
        end
    end

end
