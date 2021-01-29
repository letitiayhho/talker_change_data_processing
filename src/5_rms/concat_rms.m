function[] = concat_rms(git_home)
% DESCRIPTION:
%     Concatenates rms values from all subjects into a file
%
% OUTPUT:
%     Writes files rms.csv

arguments
    git_home char
end

    %% Main
    file_struct = dir(fullfile('data/5_rms/*/rms.mat'));
    data = combine_rms(file_struct);
    writetable(data, 'data/5_rms/rms.csv')
    quit

    %% Functions
    function [data] = combine_rms(file_struct)
        data = table();
        for i = 1:length(file_struct)
            path = fullfile(file_struct(i).folder, 'rms.mat');
            rms_data = load(path).rms_data;
            data = [data; rms_data];
        end
    end
end
