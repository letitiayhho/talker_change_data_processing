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

%% Test coherence between simulated signals
x = createComplexSignal([40, 300]);
y = createComplexSignal([40, 100, 300]);

% Plot power spectrum
% plotPowerSpectrum(x, fs)
% plotPowerSpectrum(y, fs)

% Test with mscohere
% apply_mscohere(x, y, fs)

% Test with coherencyc
% params = struct('Fs', 1000, 'tapers', [3, 5]);
% apply_coherencyc(x, y, params)
% apply_coherencyc(stim, eeg, params)
% apply_mscohere(stim, eeg, fs)

tiledlayout(5,5)
for i = 2:4:20
    for j = 2:4:20
        nexttile
        params = struct('Fs', 1000, 'tapers', [i, j]);
        [C,phi,S12,S1,S2,f] = coherencyc(x, y, params);
        plot(f, C)
        title(['TW: ', num2str(i), ' K: ', num2str(j)])
        xlabel("Frequency")
    end
end

%% Plot power spectra
% plotPowerSpectrum(stim, fs)
% plotPowerSpectrum(eeg, fs)

%% Plot coherence
% plotCoherence(stim, eeg, fs)

%% FUNCTIONS
% Create complex signal
function [x] = createComplexSignal(frequency_components, amplitudes, duration, fs)
    arguments
        frequency_components double
        amplitudes double = repmat(1, 1, length(frequency_components))
        duration double = 1.6
        fs double = 1000
    end
    % time span vector
    t = 0:1/fs:duration-1/fs;

    % initialize a signal of Gaussian noise
    x = randn(size(t));

    % create a sine wave for each component and add to waveform
    for i = 1:length(frequency_components)
        component = amplitudes(i)*sin(2*pi*frequency_components(i)*t);
        x = x + component; 
    end
end

% Power spectra
function [] = plotPowerSpectrum(x, fs)
    y = fft(x);
    n = length(x);
    f = (0:n-1)*(fs/n);
    power = abs(y).^2/n;
    figure
    plot(f, power)
    xlim([0, fs/2])
    title("Power spectrum")
    xlabel('Frequency')
    ylabel('Power')
end

% Coherence with mscohere
function [] = apply_mscohere(x, y, fs)
    [cxy, f] = mscohere(x, y, [], [], [], fs);

    figure
    plot(f, cxy)
    title("Coherence")
    xlabel("Frequency")
end

% Coherence with chronux
function [] = apply_coherencyc(x, y, params)
    [C,phi,S12,S1,S2,f] = coherencyc(x, y, params);
    
    figure
    plot(f, C)
    title("Coherence")
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