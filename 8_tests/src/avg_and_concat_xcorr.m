function [] = avg_and_concat_xcorr(filename)
% DESCRIPTION:
%   Computes cross-correlations or convolutions between eeg signal and audio
%   stimuli across all subjects, channels and trials for each condition

    %% Main
    file_struct = dir(['2_cross_correlate/data/*/', filename, '.mat']);
    data = shape(file_struct);
    write_to = ['8_t_tests/data/', filename '_averages.csv'];
    fprintf(1, strcat('Writing data to /', write_to, '\n'))
    writetable(data, write_to)

    %% Shape data
    function [data] = shape(file_struct)

        % Create empty table to write data
        data = table();

        % Iterate over subjects
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, file_struct(i).name);
            cross_correlations = load(path).data_frame;
            
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
