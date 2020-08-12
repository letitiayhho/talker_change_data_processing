# Bash scripts 

Scripts in this folder download and install necessary files and run all the source files in the `src/` folder. This enables everything to be excuted from the command line, which is convenient because there are scripts from both MATLAB and R to work with and things that need to be installed from command line to run those scripts. Also convenient because I'm trying to eventually have everything run from a single entry point so that I can do the entire analysis on an aws instance or something.

### Install

`install-matlab` - actually a bigger pain than you'd think, you need your MATLAB license information for this

`install-eeglab-plugin` - install the EEGLAB plugin for MATLAB

### Download data files

`download-eeg-data` - downloads the `.raw` eeg data and `.sfp` channel location files from the lab server. You'll need server access to `ssh` into the server with your CNET password

`download-stim-data` - downloads the audio stimuli `.wav` files and the `stim_order.txt` files  from the lab server. Same as above, you'll need authorization to access the files with your CNET log in

`extract-stim-order-from-text-files` - run this after you have the `stim_order.txt` files downloaded from above. This script just cleans up that file and creates the list mapping epoch to stim that you'll use later.

### Preprocessing

`preprocess-audio` - downsamples and filters the audio files as specified

`preprocess-audio-formants` - creates subband filtered copies of the audio files to capture f0, f1+f2, and f3 separately

`preprocess-eeg-data` - wrapper script to run `src/preprocess_eeg_data.m`. Enables automated preprocessing of all subjects at once. Uses the EEGLAB plugin for MATLAB

`run-convolution-and-cross-correlations` - wrapper script to run `src/convolve_and_cross_correlate.m` on all subjects at once

`run-convolution-and-cross-correlatinos-with-formants` - wrapper script to run `src/convolve_and_cross_correlate_with_formants.m` on all subjects at once

`run-rms` - wrapper script to run `src/get_rms.m` on all subjects at once
