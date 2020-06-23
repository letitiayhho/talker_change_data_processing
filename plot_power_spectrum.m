function [] = plot_power_spectrum(file_stem)
%     file_stem = extractBefore(filename, ".");
    files = [strcat(file_stem, ".wav"), strcat(file_stem, "_preprocessed.wav")];

    for i = 1:2
        files(i)
        [y, fs] = audioread(files(i));
        n = length(y);          % number of samples
        f = (0:n-1)*(fs/n);     % frequency range
        power = abs(y).^2/n;    % power of the DFT
        
        figure(1)
        subplot(2, 2, i)
        plot(f,power)
        title(files(i))
        xlim([0 1000])
        xlabel('Frequency')
        ylabel('Power')
        
        subplot(2, 2, i+2)
        spectrogram(y, 100, 1, 10000, fs, 'yaxis');
        title(files(i))
    end
end
