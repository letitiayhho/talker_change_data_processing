cd("/Users/letitiaho/src/talker_change_data_processing")

addpath(fullfile('0_set_up_and_raw_data/data/stim/original')) % add audio stimuli directory to path
file_struct = dir('0_set_up_and_raw_data/data/stim/original/*.wav');
male_file_struct = dir('0_set_up_and_raw_data/data/stim/original/word_*.wav');
female_file_struct = dir('0_set_up_and_raw_data/data/stim/original/*_f.wav');

% get_mean_f0(male_file_struct)
% get_mean_f0(female_file_struct)
get_f0(male_file_struct, 6)
% get_f0(female_file_struct, 6)
% get_rms(file_struct)
% get_longest_audio(file_struct)
% get_cross_correlate_random_audio(file_struct)

function [] = get_f0(file_struct, factor)
    figure
    winlength = round(44100/factor);
    overlaplength = round(winlength/2);
    for i = 1:length(file_struct)
        [y, fs] = audioread(file_struct(i).name);
        f0 = pitch(y, fs, 'WindowLength', winlength, 'OverlapLength', overlaplength);
        plot(f0)
        hold on
    end
    title(['44100/', num2str(factor), '=', num2str(winlength), ' samples per window'])
    xlabel('Frame Number')
    ylabel('Pitch (Hz)')
end

function [] = get_mean_f0(file_struct)
    means = zeros(1, length(file_struct));
    for i = 1:length(file_struct)
        [y, fs] = audioread(file_struct(i).name);
        means(i) = mean(pitch(y, fs));
    end
    figure
    histogram(means)
    title('Distribution of mean F0 for each word')
    xlabel('Pitch (Hz)')
    ylabel('Count')
    xlim([0, 400])
    ylim([0, 25])
end


function [] = get_cross_correlate_random_audio(file_struct)
    for i = 1:length(file_struct)
        [y1, ~] = audioread(file_struct(i).name);
        [c, ~] = xcorr(y1, y1);
        auto_maximum = max(c);
        auto_average = mean(abs(c));
        fprintf(1, ['Autocorrelation: Abs mean: ', num2str(auto_average), ', maximum: ', num2str(auto_maximum), '\n'])
        
        rand_i = randi([1, length(file_struct)]);
        [y2, ~] = audioread(file_struct(rand_i).name);
        [c, ~] = xcorr(y1, y2);
        maximum = max(c);
        average = mean(abs(c));
        fprintf(1, ['Abs mean: ', num2str(average), ', maximum: ', num2str(maximum), '\n'])
        
        if auto_average < average
            fprintf(1, ['Avg correlation between ', file_struct(i).name, ' and ', file_struct(rand_i).name, ' greater than autocorrelation of ', file_struct(i).name, '\n'])
        end
        
        if auto_maximum < maximum
            fprintf(1, ['Max correlation between ', file_struct(i).name, ' and ', file_struct(rand_i).name, ' greater than autocorrelation of ', file_struct(i).name, '\n'])
        end
    end
end

function [] = get_rms(file_struct)
    for i = 1:length(file_struct)
        [y, ~] = audioread(file_struct(i).name);
        fprintf(1, num2str(rms(y)))
    end
end

function [] = get_longest_audio(file_struct)
    longest_audio = 0;

    for i = 1:length(file_struct)
        [y, ~] = audioread(file_struct(i).name);
        duration = length(y)/44100;

        if duration > longest_audio
            longest_audio = duration;
        end
    end

    fprintf(1, ['Longest audio: ', num2str(longest_audio), '\n'])
end
