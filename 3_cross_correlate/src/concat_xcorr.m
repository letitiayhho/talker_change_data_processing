function [] = concat_xcorr(git_home, fstem)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

arguments
    git_home char
    fstem char % 'lag_normalized', 'average_below_f0_normalized'
end

    %% Main
    cd(git_home)    
    addpath('tools/')
    file_struct = dir(['3_cross_correlate/data/*/', fstem, '.mat']);
    data = combine_cross_correlations(file_struct);
    write_fp = ['3_cross_correlate/data/', fstem, '.csv'];
    fprintf(1, ['Writing data to ', write_fp, '\n']);
    writetable(data, write_fp)
    quit
        
    %% Combine data file from each subject
    function [data] = combine_cross_correlations(file_struct)
        data = table();
        fprintf("Reading...\n")
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, file_struct(i).name);
            fprintf(1, [path, '\n'])
            cross_correlations = load(path).data_frame;
            data = [data; cross_correlations];
        end
    end
end
