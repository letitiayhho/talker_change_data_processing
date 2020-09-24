% Parameters
subject_number = '302'; % has to be, I only have full xcorr values for 302
epoch1 = 10;
epoch2 = 24;
epoch3 = 25;
channel_index = 8;
figure(3)

% Source
cd('/Applications/eeglab2019/talker-change-data-processing')
addpath('data/stim/')
addpath(fullfile('data', subject_number))
load('cross_correlations_full.mat')
load('eeg_data')

% Epoch 1
plot_all(epoch1, channel_index, eeg_data, cross_correlations, 1)
plot_all(epoch2, channel_index, eeg_data, cross_correlations, 2)
plot_all(epoch3, channel_index, eeg_data, cross_correlations, 3)

function[] = plot_all(epoch, channel_index, eeg_data, xcorr, word_number)
    word = extractBefore(char(xcorr.word(epoch)), '.');
    subplot(3,3,word_number*3-2)
    plot_eeg(epoch, channel_index, eeg_data, word)
    subplot(3,3,word_number*3-1)
    plot_audio(epoch, xcorr, word)
    subplot(3,3,word_number*3)
    plot_correlations(epoch, channel_index, xcorr, word);
    print_banner(epoch, channel_index, xcorr)
end

function[] = plot_eeg(epoch, channel_index, eeg_data, word)
    epoch = double(eeg_data(channel_index+30, :, epoch+100));
    resampled_epoch = resample(epoch, 44100, 1000);
    plot(resampled_epoch)
    xlim([1 70560])
    title(strcat(word, ' eeg'))
end

function[] = plot_audio(epoch, xcorr, word)
    stim = audioread(char(xcorr.word(epoch)));
    plot(stim)
    xlim([1 70560])
    title(strcat(word, ' audio'))
end

function[] = plot_correlations(epoch, channel_index, xcorr, word)
    correlations = xcorr.cross_correlations(epoch, channel_index, :);  %epoch, channel
    correlations = abs(correlations(:));
    plot(correlations)
    xlim([1 70560])
    title(strcat(word, ' correlation'))
    
    % Calculate delay
%     [M, I] = max(correlations);
%     lags = xcorr.lags(epoch, channel_index, :);
%     lag = lags(I);
end

function[] = print_banner(epoch, channel_index, xcorr)
    fprintf(1, strcat("Correlations for epoch: ", num2str(xcorr.epoch(epoch)), "\n",...
        "Word: ", char(xcorr.word(epoch)), "\n",...
        "Condition: ", char(xcorr.condition(epoch)), "\n",...
        "Channel: ", num2str(channel_index+30), "\n"))
%         "Lag: ", num2str(lag/44100), " sec \n\n"))
end