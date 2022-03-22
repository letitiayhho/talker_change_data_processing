function [] = fn_spectrogram(files, figure)
    figure = figure;
    for i = 1:length(files)
        subplot(length(files),1,i);
        char(files(i));
%         [y,Fs] = audioread(char(files(i)));
% 
%         window = 100;
%         noverlap = 1;
%         nfft = 10000;
% 
%         spectrogram(y, window, noverlap, nfft, Fs, 'yaxis'); 
%         title(files(i))
    end
end