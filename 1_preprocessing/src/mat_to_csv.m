function [] = mat_to_csv(git_home, subject_number)
    cd(fullfile(git_home, '1_preprocessing/data', subject_number))
    load('eeg_data')
    csvwrite('eeg_data.csv', eeg_data)
end
    
    