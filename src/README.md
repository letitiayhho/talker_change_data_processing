# Source files

Most of the files in here are run through bash scripts in `scripts/`. These files do all the actual processing and analysis of the data.

**preprocess-eeg-data.m**

Automated pipeline for preprocessing eeg data

**convolve_and_cross_correlate.m**

Takes the preprocessed eeg data and convolves or cross-correlates the waveforms with the waveform of the auditory stimuli

**get_shaped_data.m**

Shapes the convolution and cross-correlation values for each subject and collects them into a data frame

**get_clusters.R**

Identifies clusters of spatially contiguous channels that show condition-dependent verdicality

**get_permutation_test_on_clusters.R**

Takes the clusters and conducts a permutation test to see whether clusters are different between the two conditions/levels of each factor.

**get_mni_coordinates.R**

Get MNI coordinates of the average channel locations using the transformation matrix given by DIPFIT in EEGLAB

**get_mni_cortical_areas.R**

Apply function from yunshiuan's repo to get the nearest mni coordinates of each electrode


