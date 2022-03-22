function[] = wrap_get_rms(git_home)
% DESCRIPTION:
%     Wrapper script for get_rms so I don't have to boot matlab repeatedly
%
% OUTPUT:
%     Writes rms.mat for each subject
arguments
    git_home char
end

    %% 1. Import data
    cd(git_home)
    addpath('tools')
    addpath('5_rms/src')
    subject_numbers = readmatrix('0_set_up_and_raw_data/data/subject_numbers.txt');

    %% 2. Run get_rms over each subject
    data = table();
    for i = 1:length(subject_numbers)
        subject_number = num2str(subject_numbers(i));
        rms_data = get_rms_for_each_subject(subject_number);
        data = [data; rms_data];
    end

    %% 3. Write data
    writetable(data, '5_rms/data/rms.csv')

    %% Quit
    quit
end
