# talker_change_data_processing

#### Run preprocessing

To run the preprocessing script with the wrapper bash script use `./preprocess <subject_number>`. To see the MATLAB outputs run `tail -f <name of log file.log>` the log file name should come up after you run the preprocess script. Kill the process to stop viewing the output, type in the same `tail` command to see it again.

To run the preprocessing manually with the matlab script from command line with `preprocess_eeg_data.m` run `matlab -nodisplay -r "preprocess_eeg_data('<subject number>','<eeg data file name.raw>','<channel location file name.sfp')"`. e.g. `matlab -nodisplay -r "preprocess_eeg_data('302','302_eeg_data.raw','302_channel_locations.sfp')"`

##### File management

Place all raw data files (`.raw` and `.sfp`) into a subdirectory called `raw_data`. Name all data files `<subject number>_eeg_data.raw` and `<subject_number>_channel_locations.sfp`.
