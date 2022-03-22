cd '/Users/letitiaho/src/talker_change_data_processing'
subjects = ["301", "302", "303", "304", "305", "307", "308", "310", "315", "316", "317"];

% Ys = zeros(128, 1600, length(subjects));
Ys = [];
% for i = 1:3
for i = 1:3
% for i = 1:length(subjects)
    subject_number = subjects(i);
    fp = char(fullfile('1_preprocessing/data', subject_number, 'eeg_data.mat'));
    load(fp) % should be called eeg_data because matlab is cancer
    
    Y = fft(eeg_data, [], 2);
    Y_trial_averaged = mean(Y, 3);
    Ys(:, :, i) = Y_trial_averaged;
    Ys = cat(3, Ys, Y_trial_averaged);
%     size(Ys)
end


%%
Y_mean = mean(Ys, 3);
Y_channel_means = log(mean(Y_mean, 1));
% Y_mean_one_channel = Y_mean(38,:);
% Y_log = log(Y_mean_one_channel);
% L = 1600;
% Fs = 1000;
% n = 2^nextpow2(L);
% P2 = abs(Y_mean/L);
% P1 = P2(:,1:n/2+1);
% P1(:,2:end-1) = 2*P1(:,2:end-1);
% plot(0:(Fs/n):(Fs/2-Fs/n),P1(i,1:n/2

fs = 1000;
n = 1600;
% n = length(Y_mean_one_channel);          % number of samples
f = (50:n/2)*(fs/n);     % frequency range
power = abs(Y_channel_means).^2/n;    % power of the DFT
plot(f, power(50:n/2))
% 
% %%
% % window = 100;
% % noverlap = 1;
% % nfft = 10000;
% 
% X = eeg_data(40, :, 50);
% Y = fft(X);
% L = 1600;
% Fs = 1000;
% n = 2^nextpow2(L);
% P2 = abs(Y/L);
% P1 = P2(:,1:n/2+1);
% P1(:,2:end-1) = 2*P1(:,2:end-1);
% plot(0:(Fs/n):(Fs/2-Fs/n),P1(i,1:n/2))
% 
% % spectrogram(Y, window, noverlap, nfft, Fs, 'yaxis');
% 
% %%
% Y_mean = mean(Ys, 3);
% P2 = abs(Y_mean/L);
% P1 = P2(:,1:n/2+1);
% P1(:,2:end-1) = 2*P1(:,2:end-1);
% 
% %% Plot spectrogram
% function [] = fn_spectrogram(files, figure)
%     figure = figure;
%     for i = 1:length(files)
%         subplot(length(files),1,i);
%         char(files(i));
%         [y,Fs] = audioread(char(files(i)));
% 
%         window = 100;
%         noverlap = 1;
%         nfft = 10000;
% 
%         spectrogram(y, window, noverlap, nfft, Fs, 'yaxis'); 
%         title(files(i))
%     end
% end