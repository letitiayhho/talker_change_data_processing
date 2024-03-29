function [] = concat_coherence(git_home, fstem)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home char
    fstem char % 'average.mat', 'max.mat', or 'coherence.mat'
end

    %% Main
    cd(git_home)    
    addpath('tools/')
    file_struct = dir(['6_coherence/data/*/', fstem, '.mat']);
    data = combine_cross_correlations(file_struct);
    write_fp = ['6_coherence/data/', fstem, '.csv'];
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
