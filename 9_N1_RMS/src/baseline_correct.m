function [] = baseline_correct(git_home)

arguments
    git_home string
end

cd(git_home)
subject_numbers = load_subject_numbers('./0_set_up_and_raw_data/data/subject_numbers.txt');

for i = 1:length(subject_numbers)
    subject_number = num2str(subject_numbers(i));
    fprintf(1, ['Baseline correcting for subject ', subject_number, '\n'])
    eeg = load_eeg(subject_number);
    eeg = correct_baseline(eeg);
    savefp = fullfile('./9_N1_RMS/data', subject_number, 'baseline_corrected_eeg_data.mat');
    fprintf(1, ['Saving data to ', savefp, '\n'])
    save(savefp, 'eeg')
end

    function [subject_numbers] = load_subject_numbers(fp)
        fileID = fopen(fp,'r');
        subject_numbers = fscanf(fileID, '%f');
    end

    function [eeg] = load_eeg(subject_number)
        fp = fullfile('./1_preprocessing/data',  subject_number, 'eeg_data.mat');
        eeg = load(fp).eeg_data;
    end

    function [eeg] = correct_baseline(eeg)
        baseline_period = eeg(:, 1:100, :);
        baseline = mean(baseline_period, 2);
        eeg = eeg - baseline;
    end

end