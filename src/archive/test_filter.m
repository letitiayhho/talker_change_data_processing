function [] = test_filter(subject, channel, epoch, bin_center)

    % Convert string args to ints and print for sanity check
    subject = str2num(subject)
    channel = str2num(channel)
    epoch = str2num(epoch)
    bin_center = str2num(bin_center)

    % Load eeg data
    fprintf(1, 'Loading data...\n');
    cd('/home/ubuntu/talker_change_data_processing');
    addpath(fullfile('data', string(subject)));
    eeg_data = load('eeg_data').('eeg_data');
    sample = eeg_data(channel, :, epoch);

    % Filter eeg data
    fprintf(1, 'Filtering...\n');
    [b, a] = butter(10, [0.8*bin_center, 1.25*bin_center]/500, 'bandpass');
    filtered_sample = filter(b, a, sample);

    % Compute power
    fprintf(1, 'Computing power...\n');
    fs = 1000;
    n = length(sample);
    f = (0:n-1)*(fs/n);
    y = fft(sample);
    y_filtered = fft(filtered_sample);
    power = abs(y).^2/n;
    power_filtered = abs(y_filtered).^2/n;

    % Plot in time domain
    fprintf(1, 'Plotting in time domain...\n');
    cla
    fig = figure('Visible', 'off');
    subplot(2, 2, 1)
    plot(sample)
    xlabel('Time')
    ylabel('Amplitude')
    subplot(2, 2, 2)
    plot(filtered_sample)
    xlabel('Time')
    ylabel('Amplitude')

    % Plot in frequency domain
    fprintf(1, 'Plotting in frequency domain...\n');
    subplot(2, 2, 3)
    plot(f, power)
    xlim([0, 100])
    xlabel('Frequency')
    ylabel('Power')
    subplot(2, 2, 4)
    plot(f, power_filtered)
    xlim([0, 100])
    xlabel('Frequency')
    ylabel('Power')

    % Save plot
    fprintf(1, 'Saving figure...\n');
    save_fp = fullfile('src/archive', strcat('test_filter_', string(subject), string(channel), string(epoch), '.png'));
    saveas(fig, save_fp) 
end
