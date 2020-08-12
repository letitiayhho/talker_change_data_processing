# talker_change_data_processing

Running convolutions and cross correlations between the EEG data and audio signal of ending words of six types of sentence stems- high vs lowmeaning constraint, congruent vs incongruent, same vs different talker.

## Dependencies

* MATLAB R2019b or later with the dependencies for EEGLAB also listed [here](https://sccn.ucsd.edu/eeglab/ressources.php).
    * Signal processing toolbox
    * Statistics toolbox
    * Optimization toolbox
    * Image processing toolbox
* R version 3.6.1 with following packages.
    * R.matlab
    * tools
    * dplyr

## File management

As seen in this repo, everything in your working directory should be divided into three folders- `scripts`, `src`, and `data`. `scripts` is for wrapper bash scripts that you call to run the MATLAB files in `src`. `data` is where all the raw, preprocessed, and analyzed data end up, each subject has its own subdirectory within `data`. If you run everything using the scripts in `scripts`, you shouldn't have to directly touch anything in `src` or `data`, the bash scripts should take the correct files, apply correct MATLAB scripts to them and spit output into their correct subject folders.

All scripts should be run from the root directory of this repo, i.e. if you git cloned it then you should run everything from `talker-change-data-processing/`.

**Download raw data from lab server**

For this you will need a CNET log in with access to the server. Check the APEX lab wiki to see how to get access approval. To download the eeg data and stimuli files use the following code to run the bash scripts.

```
./scripts/download-eeg-data
./scripts/download-stim-data
./scripts/extract-stim-order-from-text-files
```

## Data processing

#### Preprocess

To run the preprocessing script with the wrapper bash script use `./scripts/preprocess <subject_number> ...`, where the elipses `...` denote any number of subjects. The script will run the process in the background so that it continues even if the Terminal window exits. To see the MATLAB outputs run `tail -f <name of log file.log>` the log file name should come up after you run the bash script. Kill the process to stop viewing the output, type in the same `tail` command to see it again. To kill the process, use the `kill <pid>` that the bash script also gives you when you first run it.

```
./scripts/preprocess-audio <downsample frequency> <high-pass frequency> <low-pass frequency>
./scripts/preprocess-eeg-data <subject number> ...
```

#### Compute convolutions and cross-correlations

Convolves and cross-correlates the eeg signal with the audio signal of the stimuli. To compute for each subject use the follow code, where the elipses `...` denote any number of subjects e.g. `./scripts/analyze-individual-subject-data 301 302 303`.

```
./scripts/compute_convolution_and_cross_correlations <subject_number> ...
```

