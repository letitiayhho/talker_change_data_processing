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