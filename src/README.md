# Source files

Most of the files in here are run through bash scripts in `scripts/`. These files do all the actual processing and analysis of the data.

**preprocess-eeg-data.m**

Automated pipeline for preprocessing eeg data

**convolve_and_cross_correlate.m**

Takes the preprocessed eeg data and convolves or cross-correlates the waveforms with the waveform of the auditory stimuli

**analyze.m**

Takes the convolution and cross-correlation values for each channel and shapes them for further analysis in R and computes basic statistics such as summary statistics and ANOVAs between conditions for specified channels.

**get_clusters.R**

Identifies clusters of spatially contiguous channels that show condition-dependent verdicality

**permutation_test_on_clusters.R**

Takes the clusters and conducts a permutation test to see whether clusters are different between the two conditions/levels of each factor.




