# Source files

Most of the files in here are run through bash scripts in `scripts/`. These files do all the actual processing and analysis of the data. Below is a description of the files you might directly run for any analysis. I haven't included all the helper function files.

### Preprocessing

`preprocess_eeg_data.m` - Automated pipeline for preprocessing eeg data using EEGLAB toolbox on MATLAB

`cross_correlate.m` - Takes the preprocessed eeg data and cross-correlates the waveforms with the waveform of the auditory stimuli

`average_and_concat_cross_correlations.m` - Shapes the cross-correlation values for each subject and collects them into a data frame

`concat_cross_correlations.m` - Combines all cross correlation values for each subject into one file

### Channel locations

`get_mni_coordinates.R` - Get MNI coordinates of the average channel locations using the transformation matrix given by DIPFIT in EEGLAB

`get_nearest_cortical areas.R` - Apply a modified version get mni_cortical_areas to output a list of cortical areas closest to the surrounding coordinates

### Permutation test

`shuffle.m` - compute cross correlations between shuffled eeg-stimuli pairs

`shape_shuffles.m` - shape the output files from `shuffle.m`, concatenate all results into `.csv` files in `data/aggregate/`

`plot_shuffles_maximum.Rmd` - Generates various plots of the computed maximums of the permutation test

`plot_shuffles_lag.Rmd` - Generates various plots of the computed lags of the permutation test

`plot_shuffles_maps.Rmd` - Generates maps of channels showing significant cross correlations with stimuli under different conditions

### RMS

`get_rms.m` - computes RMS, a measure of overall power, for each trial

`concat_rms.m` - combines all RMS values for each subject into one file



