# Source files

Most of the files in here are run through bash scripts in `scripts/`. These files do all the actual processing and analysis of the data.

### Preprocessing

`preprocess_eeg_data.m` - Automated pipeline for preprocessing eeg data using EEGLAB toolbox on MATLAB

`convolve_and_cross_correlate.m` - Takes the preprocessed eeg data and convolves or cross-correlates the waveforms with the waveform of the auditory stimuli

`convolve_and_cross_correlate_formants.m` - Takes the preprocessed eeg data and convolves or cross-correlates the waveforms with the subband-filtered versions of the auditory stimuli. See script for frequency bands and corresponding formants

`shape_data.m` - Shapes the convolution and cross-correlation values for each subject and collects them into a data frame

### Main analysis

`main_analysis.Rmd` - t-tests to answer basic questions about the data. Outputs an `.html` file for easy reading

`main_analysis_maps.Rmd` - map the test statistics for each condition onto a 2D map of the electrodes

### Clustering analysis

`get_permutation_clusters.R` - Identifies clusters of spatially contiguous channels that show condition-dependent verdicality

`get_permutation_test_on_clusters.R` - Takes the clusters and conducts a permutation test to see whether clusters are different between the two conditions/levels of each factor

`get_cluster_map.R` - Get a pretty figure of cross-correlation or convolution values on a 2-d map of the electrodes. Node size represents cross-correlation or convolution magnitude (abs). Color represents closest cortical area. Edges are a function of the similarity of the cross-correlation/convolution between the two nodes, and their euclidean distance

### RMS analysis

`get_rms.m` - Calculate the RMS of each channel

`get_rms_multreg.R` - Create models predicting electrode correlation with audio signal based on condition and RMS values of other channels

`get_rms_simplified_multreg.R` - Compute the same regression but for individual conditions and only for specified temporal subregions

### Electrode location analysis.

`get_mni_coordinates.R` - Get MNI coordinates of the average channel locations using the transformation matrix given by DIPFIT in EEGLAB

`get_mni_cortical_areas.R` - Apply function from yunshiuan's repo to get the nearest mni coordinates of each electrode



