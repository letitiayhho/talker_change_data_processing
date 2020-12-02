%% Concatenate all shuffles into one file
function [] = get_joined_shuffles(git_home, subject_number)
% To save computing power and storage space, I'm only going to be
% concatenating ~ 1000 trials. This function opens up the files containing
% the shuffled cross-correlation values and concatenates them to one list

    % Get file names
    subject_dir = fullfile(git_home, 'data', subject_number);
    file_names = get_file_names(subject_dir, 'scramble');
    check_number_of_files(file_names)

    % Loop over files and append them to the data structure as you go.
    % Break out of loop once data array has 1000 trials. Start with the
    % first file. Keep maximum values only
    first_file = load(string(file_names(1))).cross_correlations;
    sample_shuffles = first_file.maximum;
    for i = 2:length(file_names)
        resample = load(string(file_names(i))).cross_correlations;
        maximum = resample.maximum;
        sample_shuffles = vertcat(sample_shuffles, maximum);
        if size(sample_shuffles, 1) >= 1000
            break
        end
    end
    
    % Save values
    writematrix(sample_shuffles(1:1000,:), fullfile(subject_dir, 'sample_shuffles.csv'))

    %% Checks
    % Check whether there are files under that folder
    function [] = check_number_of_files(file_names)
        if length(file_names) < 2
            error('Only 1 file to concatenate, try changing get_file_names')
        end
    end
end