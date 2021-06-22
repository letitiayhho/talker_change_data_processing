function [] = average_and_concat_cross_correlations()
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

    %% Main
    file_struct = dir(fullfile('2_cross_correlations/data/*/cross_correlations.mat'));
    data = shape(file_struct);
    filename = '8_t_tests/data/maximum_averages.csv';
    fprintf(1, strcat('Writing data to /', filename, '\n'))
    writetable(data, filename)

    %% Shape data
    function [data] = shape(file_struct)

        % Create empty table to write data
        data = table();

        % Iterate over subjects
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, 'cross_correlations.mat');
            cross_correlations = load(path).cross_correlations;
            
            % Drop lags and indentifier columns
            cross_correlations = cross_correlations(:,1:134);
            cross_correlations = removevars(cross_correlations, {'epoch', 'word'});

            % Calculate means for each channel for each condition
            subject_avg = grpstats(cross_correlations, {'subject_number', 'talker', 'meaning', 'constraint'});
            subject_avg.Properties.RowNames = {};
            data = [data; subject_avg];
        end
    end
end
