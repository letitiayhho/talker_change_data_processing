function [] = preprocess_all_eeg_data()
subjects = ["301", "302", "303", "304", "305", "307", "308", "310", "315", "316", "317"];
    for subject = subjects
        preprocess_all_eeg_data(subject)
    end
end
