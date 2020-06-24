# talker_change_data_processing

Running convolutions and cross correlations between the EEG data and audio signal of ending words of six types of sentence stems- high vs lowmeaning constraint, congruent vs incongruent, same vs different talker.

#### File management

Make a directory for each subject named `<subject_number>` under `data/`. Place all raw, preprocessed and analyzed data into their corresponding subject folder. Name all raw eeg data files `eeg_data.raw`, name all channel location files `channel_locations.sfp`.

#### Run preprocessing

To run the preprocessing script with the wrapper bash script use `./scripts/preprocess <subject_number> ...`. The script will run the process in the background so that it continues even if the Terminal window exits. To see the MATLAB outputs run `tail -f <name of log file.log>` the log file name should come up after you run the bash script. Kill the process to stop viewing the output, type in the same `tail` command to see it again. To kill the process, use the `kill <pid>` that the bash script also gives you when you first run it.

To run the preprocessing manually with the matlab script from command line with `preprocess_eeg_data.m` run `matlab -nodisplay -r "preprocess_eeg_data('<subject number>','<eeg data file name.raw>','<channel location file name.sfp')"`. e.g. `matlab -nodisplay -r "preprocess_eeg_data('302','302_eeg_data.raw','302_channel_locations.sfp')"`

#### Run analysis of individual subject data

To run convolutions and cross correlations over the data of each subject use `./scripts/analyze-individual-subject-data <subject_number> ...`.
