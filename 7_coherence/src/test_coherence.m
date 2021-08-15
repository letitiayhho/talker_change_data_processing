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

%% Vectorized coherence
% eeg = double(eeg_data(:, :, epoch_num))';
% [cxy, f] = mscohere(stim, eeg, [], [], [], fs);
% cxy = mean(cxy, 2);
% plot(f, cxy)
% title("Coherence between stim and eeg: all channels")
% xlabel("Frequency")

%% Plot power spectra
% plot_power_spectra(stim, fs)
% plot_power_spectra(eeg, fs)

%% Plot coherence
% plot_coherence(stim, eeg, fs)
% lowpass_stim = lowpass(stim, 100, fs);
% lowpass_eeg = lowpass(eeg, 100, fs);
% plot_coherence(lowpass_stim, lowpass_eeg, fs)

%% Pitch
winLength = round(.05*fs);
f0 = pitch(stim, fs, 'WindowLength',winLength);
plot(f0)

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

% figure
% lowpass_stim = lowpass(stim, 100, fs);
% lowpass_eeg = lowpass(eeg, 100, fs);
% [cxy, f] = mscohere(lowpass_stim, lowpass_eeg, [], [], [], fs);
% plot(f, cxy)
% title("Coherence between low-pass filtered stim and eeg")
% xlabel("Frequency")

% Vectorized implementation (nrows = time points)
% [cross_correlation, lag] = xcorr(epoch, stim);
% cross_correlations = [cross_correlations; cross_correlation];
% abs_average = [abs_average, mean(abs(cross_correlation))];
% [m, I] = max(abs(cross_correlation));
% maximum = [maximum, m];
% lags = [lag(I)];
% end

% time_points = -100:1499;
% figure
% plot(time_points, epoch)
% xlim([-100, 1500])
% ylim([-20, 20])
% figure
% plot(stim)
% xlim([-100, 1500])
% ylim([-1, 1])
% figure
% plot(cross_correlation)
% xlim([0, 3200])
% cross_correlation = cross_correlation/max(cross_correlation);
% audiowrite('sample_cross_correlation.wav', cross_correlation, 1000)