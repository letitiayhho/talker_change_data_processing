# Source files

Most of the files in here are run through bash scripts in `scripts/`. These files do all the actual processing and analysis of the data.

### Preprocessing

`preprocess_eeg_data.m` - Automated pipeline for preprocessing eeg data using EEGLAB toolbox on MATLAB

`cross_correlate.m` - Takes the preprocessed eeg data and cross-correlates the waveforms with the waveform of the auditory stimuli

`shape_data.m` - Shapes the convolution and cross-correlation values for each subject and collects them into a data frame

`get_stim_order.m` - function called in `cross_correlate.m

### Permutation test

`shuffle.m` - computer cross correlations between shuffled eeg-stimuli pairs

`shape_shuffles.m` - shape the output files from `shuffle.m`, concatenate all results into `.csv` files in `data/aggregate/`

`plot_shuffles.Rmd` - RMarkdown notebook with the results of the permutation test

### Electrode location analysis.

`get_mni_coordinates.R` - Get MNI coordinates of the average channel locations using the transformation matrix given by DIPFIT in EEGLAB

`get_nearest_cortical areas.R` - Apply a modified version get mni_cortical_areas to output a list of cortical areas closest to the surrounding coordinates



