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