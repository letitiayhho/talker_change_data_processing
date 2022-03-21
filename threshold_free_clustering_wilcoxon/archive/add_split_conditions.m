function ft = add_split_conditions(ft, subject_number)
        conditions_fp = char(fullfile('2_cross_correlate/data', subject_number, 'split_conditions.mat'));
        load(conditions_fp)
        ft.trialinfo = [ft.trialinfo, split_conditions];
end