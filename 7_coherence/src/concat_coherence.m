function [] = concat_coherence(git_home, stat)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home char
    stat char % 'average' or 'average_max'
end

    %% Main
    cd(git_home)    
    addpath('tools/')
    file_struct = dir(['7_coherence/data/*/', stat, '.mat']);
    data = combine_cross_correlations(file_struct);
    write_fp = ['7_coherence/data/', stat, '.csv'];
    fprintf(1, ['Writing data to ', write_fp, '\n']);
    writetable(data, write_fp)
    quit
        
    %% Combine data file from each subject
    function [data] = combine_cross_correlations(file_struct)
        data = table();
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, file_struct(i).name);
            cross_correlations = load(path).data_frame;
            data = [data; cross_correlations];
        end
    end
end
