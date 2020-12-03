function [] = get_max_only(git_home)
% Extract the max and conditions from the original data in .mat files and 
% save as .csv files to analyze in R
arguments
    git_home char = '/Users/letitiaho/src/talker_change_data_processing'
end

    subject_numbers = readmatrix('scripts/subject_numbers.txt');
    for i = 1:length(subject_numbers)
        % Get file names
        subject_dir = fullfile(git_home, 'data', num2str(subject_numbers(i)));
        fp = fullfile(subject_dir, 'cross_correlations.mat')
        load(fp);

        % Keep only maximum and condition
        condition = get_split_conditions(cross_correlations.condition);
        maximum = cross_correlations.maximum;

        % Save values
        writetable(condition, fullfile(subject_dir, 'condition.csv'))
        writematrix(maximum, fullfile(subject_dir, 'maximum.csv'))
    end
end