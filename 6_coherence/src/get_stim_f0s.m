% % function [secs, file_order] = compute_vowel_duration()
% cd ~/src/talker_change_data_processing/
% files = dir('0_set_up_and_raw_data/data/stim/original/*.wav');
% path = fullfile(files(1).folder, files(1).name);
% path
% 
% %     for i = 1:length(paths)
% [y, fs] = audioread(path);
%     
% 
% windowLength = round(0.05*fs);
% overlapLength = round(0.045*fs);
% % windowLength = 1000; % window length of 24 msec
% % overlapLength = windowLength/2;
% pitch(y, fs, 'WindowLength', windowLength, 'OverlapLength', overlapLength)

%     paths = dir(fullfile('..', 'stim', '*', '*.wav'));
%     files = zeros(length(paths), 1);
%     file_order = [];
%     for i = 1:length(paths)
%         filepath = fullfile(paths(i).folder, paths(i).name);
%         info = audioinfo(filepath);
%         secs(i) = info.Duration;
%         file_order = [file_order; cellstr(filepath)];
%     end
% end

% [x,fs] = audioread('singing-a-major.ogg');
% t = (0:size(x,1)-1)/fs;
% 
% winLength = round(0.05*fs);
% overlapLength = round(0.045*fs);
% [f0,idx] = pitch(x,fs,'Method','SRH','WindowLength',winLength,'OverlapLength',overlapLength);
% tf0 = idx/fs;
% https://www.mathworks.com/help/audio/ref/pitch.html winlength in samples
% overlap length

% compute coherence for same window
% https://www.fieldtriptoolbox.org/tutorial/coherence/

% specify 24 msec, 12 overlap


% just go with praat? min pitch of 75, so 100 samples per second
% so 441 time points per window
% Note that if you set the time step to zero, the analysis windows for consecutive measurements will overlap appreciably: 
% Praat will always compute 4 pitch values within one window length, i.e., the degree of oversampling is 4.
% so overlap of 330 samples

cd ~/src/talker_change_data_processing/7_coherence
files = dir('data/pitch_listings/churchbells_f.txt');

% min_f0 = 600;
for i = length(files)
    path = fullfile(files(i).folder, files(i).name);
    data = readmatrix(path);
    length(data)
    f0 = data(~isnan(data(:,2)),2);
%     this_min_f0 = min(f0);
%     if this_min_f0 < min_f0
%         min_f0 = this_min_f0;
%     end
end
% min_f0
hist(f0)

% IDENTIFY MEAN PITCH

% get pitch across entire vowel on praat
% use that as a weighting for the coherences plot??? just find the cross
% correlation

% plot f0 for each vowel side by side with corresponding coherence plot