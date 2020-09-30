# talker_change_data_processing

This is basically an exploratory data analysis using data from a previous [study](https://osf.io/x8dau/) by Soph Uddin and Katie Reis. Typical EEG studies calculate subject-averaged ERPs and examine the presence and amplitude of certain peaks to make inferences about the cognitive processes underlying the processing of speech. In our analysis, we are using cross-correlation as a measure of similarity between the EEG and stimuli waveforms. High EEG-stimuli similarity indicates the signal at a particular electrode is tracking temporal features in the stimuli, which may suggest that nearby cortical areas are encoding, following, or attending to the speech signal. We are not only looking at degree of overall tracking, but whether tracking varies as a function of whether the stimuli is predictable, is spoken by the same talker as previous words, or meaningful. A difference in tracking between conditions is further evidence that our measure of tracking reflects some underlying cognitive process, instead of random noise or general listening. Further analysis looking at network topology, tracking of specific formants, and the effects of attention on tracking, will also be conducted.

## Dependencies

* MATLAB R2019b or later with the dependencies for EEGLAB also listed [here](https://sccn.ucsd.edu/eeglab/ressources.php).
    * Signal processing toolbox
    * Statistics toolbox
    * Optimization toolbox
    * Image processing toolbox
* R version 3.6.1 with following packages (\* only needed for certain analyses)
    * R.matlab
    * tools
    * dplyr
    * label4mri\*

## File management

To run anything your folders data files and scripts should be organized as they are in this repo. Everything is run from the root directory i.e. if you git cloned it then you should run everything from `talker-change-data-processing/`.

The files in this repo are divided into three folders- `scripts`, `src`, and `data`. `scripts` is for wrapper bash scripts that you call to run the MATLAB files in `src`. `data` is where all the raw, preprocessed, and analyzed data end up, each subject has its own subdirectory within `data`. If you run everything using the scripts in `scripts`, you shouldn't have to directly touch anything in `src` or `data`, the bash scripts should take the correct files, apply correct MATLAB scripts to them and spit output into their correct subject folders.


**Download raw data from lab server**

For this you will need a CNET log in with access to the server. Check the APEX lab wiki to see how to get access approval. To download the eeg data and stimuli files use the following code to run the bash scripts.

```
./scripts/download-eeg-data
./scripts/download-stim-data
./scripts/extract-stim-order-from-text-files
```

## Data processing

### Preprocessing

To run the preprocessing script with the wrapper bash script use `./scripts/<script_name> <subject_number> ...`, where the elipses `...` denote any number of subjects. The script will run the process in the background so that it continues even if the Terminal window exits. To see the MATLAB outputs run `tail -f <name of log file.log>` the log file name should come up after you run the bash script. Kill the process to stop viewing the output, type in the same `tail` command to see it again. To kill the process, use the `kill <pid>` that the bash script also gives you when you first run it.

**Preprocessing raw audio and eeg data**

```
./scripts/preprocess-audio <downsample frequency> <high-pass frequency> <low-pass frequency>
./scripts/preprocess-audio-formants 
./scripts/preprocess-eeg-data <subject number> ...
```

**Compute convolutions and cross-correlations**

Convolves and cross-correlates the preprocessed eeg signal with the preprocessed stimuli signal.

```
./scripts/run_convolution_and_cross_correlations <subject_number> ...
./scripts/run_convolution_and_cross_correlations_with_formants <subject_number> ...
./scripts/run_rms <subject_number> ...
```

### Main analysis

Run statistical tests and generate output frequency tables and figures in a .html document. To see the results just open `src/main_analysis.html` and `src/main_analysis_maps.html` in your browser.

```
R -e "rmarkdown::render('src/main_analysis.Rmd')"
R -e "rmarkdown::render('src/main_analysis_maps.Rmd')"
```
