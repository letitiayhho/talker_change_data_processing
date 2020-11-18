# talker_change_data_processing

This is basically an exploratory data analysis using data from a previous [study](https://osf.io/x8dau/) by Sophia Uddin and Katie Reis. Typical EEG studies calculate subject-averaged ERPs and examine the presence and amplitude of certain peaks to make inferences about the cognitive processes underlying the processing of speech. In our analysis, we are using cross-correlation as a measure of similarity between the EEG and stimuli waveforms. High EEG-stimuli similarity indicates the signal at a particular electrode is tracking temporal features in the stimuli, which may suggest that nearby cortical areas are encoding, following, or attending to the speech signal. We are not only looking at degree of overall tracking, but whether tracking varies as a function of whether the stimuli is predictable, is spoken by the same talker as previous words, or meaningful. A difference in tracking between conditions is further evidence that our measure of tracking reflects some underlying cognitive process, instead of random noise or general listening. Further analysis looking at network topology, tracking of specific formants, and the effects of attention on tracking, will also be conducted.

## Dependencies

* MATLAB R2019b or later with the dependencies for EEGLAB also listed [here](https://sccn.ucsd.edu/eeglab/ressources.php).
    * Signal processing toolbox
    * Statistics toolbox
    * Optimization toolbox
    * Image processing toolbox
* R version 3.6.1 with following packages
    * R.matlab
    * tools
    * dplyr
    * ggplot2
    * ggpubr
    * kableExtra

## File management

To run anything your folders data files and scripts should be organized as they are in this repo. Everything is run from the root directory i.e. if you git cloned it then you should run everything from `talker-change-data-processing/`.

The files in this repo are divided into three folders- `scripts`, `src`, and `data`. `scripts` is for wrapper bash scripts that you call to run the MATLAB files in `src`. `data` is where all the raw, preprocessed, and analyzed data end up, each subject has its own subdirectory within `data`. If you run everything using the scripts in `scripts`, you shouldn't have to directly touch anything in `src` or `data`, the bash scripts should take the correct files, apply correct MATLAB scripts to them and spit output into their correct subject folders.


**Download raw data from lab server**

For this you will need a CNET log in with access to the server. Check the APEX lab wiki to see how to get access approval. Use the following code to run the bash scripts that will download the eeg data and stimuli files from the server.

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

### Permutation tests

Run permutation tests by shuffling the EEG-stimuli pairs. I usually do this on a server where I can kick off multiple jobs in parallel. I have been using the RCC Midway cluster which you will need to sign up and request Service Units from. 

**Set up RCC**

Clone this repository into your RCC server and name it `tcdp` for simplicity's sake. Make a few directories for data to be written into later.

```
git clone https://github.com/letitiayhho/talker_change_data_processing/ tcdp
mkdir data/logs
mkdir data/aggregate
```

In your local computer in the Git root directory create a file called `data_files`. Type the following lines into the file and save and exit.

```
data/*/epoch*.mat
data/stim/original
data/*/eeg_data.mat
data/*/stim_order.txt
```

Then run the following lines to copy the compressed data files into your server.

```
tar cJvf data.tar.xz $(cat data_files)
scp data_files.tar.xz <your CNETID>@midway2.rcc.uchicago.edu:tcdp
```

Once in the server, run to unpack the files.

```
tar xJvf data.tar.xz
```

**Run permutation test**

When you are `ssh`ed into the RCC, use the commands below to run `n` permutations. When you run this commnad, `n` lines will print into `stdin` each reading `Submitted batch job <job id>`. Each job should create a file in the Git root directory called `slurm-<job id>.out` and a file in `data/logs` called `<job id>.log`. Check the contents of these logs using `tail -f <filename>` or `cat <filename>` to see if the jobs within them are still running or to view any errors they might spit out.

```
scripts/shuffle.wrapper <n>
```

Data files created by each of your jobs should be collected in `data/aggregate`. As you kicked off all of your jobs at the same time, all of the `job id`s should start with the same sequence of numbers. (For example, if your ids are `6602342`, `6602356` and `6602376`, the first few common numbers should be `6602`). To compress the data files, copy them into your local computer, and unpack them, use the following commands.

```
tar cJvf output.tar.xz data/aggregate/<first few common numbers of your job ids>*.mat
```

In your local computer, run

```
scp <your CNETID>@midway2.rcc.uchicago.edu:tcdp/output.tar.xz .
tar xJvf output.tar.xz
mkdir shuffles
mv data/aggregate/<first few common numbers of your job ids>*.mat data/aggregate/shuffles/shuffles/
```

**Preprocess permutation test**

To aggregate each resampling into averages and save all of the averages into a `.csv` file for further analysis in `R`, run

```
matlab -r -nosplash -nodisplay "addpath('src'); shape_shuffles('maximum')"
matlab -r -nosplash -nodisplay "addpath('src'); shape_shuffles('lag')"
matlab -r -nosplash -nodisplay "addpath('src'); shape_shuffles('abs_average')"
```

**Analyze permutation test**

Better than running these `RMarkdown` files on command line I suggest opening each of them and running or knitting them. To run the last one you are going to have to get the file `2d_coordinates` from me.

```
src/plot_shuffles_maximum.Rmd
src/plot_shuffles_lag.Rmd
src/plot_shuffles_maps.Rmd
```
You could theoretically just knit the analysis files and plots into pretty `html` documents with the following.

```
R -e "rmarkdown::render('src/plot_shuffles_maximum.Rmd')"
R -e "rmarkdown::render('src/plot_shuffles_lag.Rmd')"
R -e "rmarkdown::render('src/plot_shuffles_maps.Rmd')"
```
![talker](https://imgur.com/a/R0AZhmN)
