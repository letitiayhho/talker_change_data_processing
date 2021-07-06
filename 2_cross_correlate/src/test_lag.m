%% x as exponential decay
% n = 0:15;
% x = 0.84.^n;
% x_trimmed = x(1:8);
% y = circshift(x, 5);

%% x as exponential decay with rms changed
n = 0:15;
x = 0.84.^n;
x_down = x - 0.1;
x_up = x + 0.1;

%% x as a sine-wave
% t = [pi/8:pi/8:2*pi];
% x = sin(t);
% x_trimmed = x(1:8);
% y = cos(t);

%% Plot
tiledlayout(3, 3)

nexttile
stem(x)
title("x")
xlabel("Sample")
ylabel("Amplitude")

nexttile
stem(x)
title("x")

nexttile
stem(x)
title("x")

nexttile
stem(x_down)
title("x with RMS decreased")
xlabel("Sample")
ylabel("Amplitude")

nexttile
stem(x)
title("x")

nexttile
stem(x_up)
title("x with RMS increased")

nexttile
[c,lags] = xcorr(x, x_down);
stem(lags,c)
title("Cross-correlation between x and x with RMS decreased")
xlabel("Lag")
ylabel("Cross-correlation")
ylim([0, 4])

nexttile
[c,lags] = xcorr(x);
stem(lags,c)
title("Autocorrelation of x")
ylim([0, 4])

nexttile
[c,lags] = xcorr(x, x_up);
stem(lags,c)
title("Cross-correlation x and x with RMS increased")
ylim([0, 4])

% %% Plot
% tiledlayout(3, 3)
% 
% nexttile
% stem(x)
% title("x")
% xlabel("Sample")
% ylabel("Amplitude")
% 
% nexttile
% stem(x_trimmed)
% title("x trimmed")
% ylim([-1, 1])
% xlim([0, 16])
% 
% nexttile
% stem(x)
% title("x")
% 
% nexttile
% stem(x)
% title("x")
% xlabel("Sample")
% ylabel("Amplitude")
% 
% nexttile
% stem(x)
% title("x")
% 
% nexttile
% stem(y)
% title("y")
% 
% nexttile
% [c,lags] = xcorr(x);
% stem(lags,c)
% title("Autocorrelation of x")
% xlabel("Lag")
% ylabel("Cross-correlation")
% 
% % in the original cross correlation it is (stim, epoch) latter dragged over
% % former, (short, long)
% % so all of the cross-correlations should have the length of the longest
% % signal-- the eeg epoch (because we picked a window length longer than the
% % longest word, which is 1.2437 sec)
% nexttile
% [c,lags] = xcorr(x_trimmed, x);
% stem(lags,c)
% title("Cross-correlation between x trimmed and x")
% ylim([0, 4])
% 
% nexttile
% [c,lags] = xcorr(x, y);
% stem(lags,c)
% title("Cross-correlation x and y")
