%% Set up
cd("/Users/letitiaho/src/talker_change_data_processing")
addpath(fullfile('1_preprocessing/data/304')) % add subject data to path
addpath(fullfile('0_set_up_and_raw_data/data/stim/low_pass_400')) % add audio stimuli directory to path
addpath('tools')

% Load eeg data
load('eeg_data')
epoch_num = 120;
eeg = double(eeg_data(40, :, epoch_num));

% Load audio file
stim = audioread('churchbells_f.wav');
fs = 1000;
stim = resample(stim, 10, 441);
pad = zeros(length(eeg) - length(stim), 1);
stim = [stim; pad];

%% Plot power spectra
plot_power_spectra(stim, fs)
plot_power_spectra(eeg, fs)

%% Plot coherence
plot_coherence(stim, eeg, fs)

%% FUNCTIONS
% Power spectra
function [] = plot_power_spectra(x, fs)
    y = fft(x);
    n = length(x);
    f = (0:n-1)*(fs/n); 
    power = abs(y).^2/n;
    figure
    plot(f, power)
    xlim([0, 500])
    title("Power spectra")
    xlabel('Frequency')
    ylabel('Power')
end

% Coherence
function [] = plot_coherence(x, y, fs)
    figure
    [cxy, f] = mscohere(x, y, [], [], [], fs);
    plot(f, cxy)
    title("Coherence between stim and eeg")
    xlabel("Frequency")
end

%% Compute pitch
% winLength = round(.05*fs);
% f0 = pitch(stim, fs, 'WindowLength',winLength);
% plot(f0)

%% Test vectorized coherence
% eeg = double(eeg_data(:, :, epoch_num))';
% [cxy, f] = mscohere(stim, eeg, [], [], [], fs);
% cxy = mean(cxy, 2);
% plot(f, cxy)
% title("Coherence between stim and eeg: all channels")
% xlabel("Frequency")