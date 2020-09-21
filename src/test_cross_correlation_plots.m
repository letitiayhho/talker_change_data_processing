% Parameters
subject_number = '302'; % has to be, I only have full xcorr values for 302
epoch1 = 5;
epoch2 = 1;
epoch3 = 20;
channel_index = 8;
figure(2)

% Source
cd('/Applications/eeglab2019/talker-change-data-processing')
addpath('data/stim/')
addpath(fullfile('data', subject_number))
cross_correlations = load('cross_correlation_data_table_full_rev.mat').cross_correlation_data_table;
eeg_data = load('eeg_data').eeg_data;

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
    lag = plot_correlations(epoch, channel_index, xcorr, word);
    print_banner(epoch, channel_index, xcorr, lag)
end

function[] = plot_eeg(epoch, channel_index, eeg_data, word)
    epoch = eeg_data(channel_index+30, :, epoch+60);
    % save(fullfile('~/Desktop',strcat('eeg_', word)), 'epoch')
    plot(epoch)
    title(strcat(word, ' eeg'))
end

function[] = plot_audio(epoch, xcorr, word)
    stim = audioread(char(xcorr.word(epoch)));
    % sound(stim, 44100)
    plot(stim)
    xlim([1 66150])
    title(strcat(word, ' audio'))
end

function[lag] = plot_correlations(epoch, channel_index, xcorr, word)
    correlations = xcorr.cross_correlation(epoch, channel_index, :);  %epoch, channel
    correlations = correlations(:);
    % save(fullfile('~/Desktop',strcat('correlation_', word)), 'correlations')
    plot(correlations)
    xlim([1 132300])
    title(strcat(word, ' correlation'))
    
    % Calculate delay
    [M, I] = max(correlations);
    lags = xcorr.lags(epoch, channel_index, :);
    lag = lags(I);
end

function[] = print_banner(epoch, channel_index, xcorr, lag)
    fprintf(1, strcat("Correlations for epoch: ", num2str(xcorr.epoch(epoch)), "\n",...
        "Word: ", char(xcorr.word(epoch)), "\n",...
        "Condition: ", char(xcorr.condition(epoch)), "\n",...
        "Channel: ", num2str(channel_index+30), "\n",...
        "Lag: ", num2str(lag/44100), " sec \n\n"))
end