cd /Users/letitiaho/src/talker_change_data_processing
[S_y, fs] = audioread("0_set_up_and_raw_data/data/stim/low_pass_400/doorbell_f.wav");
[T_y, fs] = audioread("0_set_up_and_raw_data/data/stim/low_pass_400/word_doorbell.wav");

[r, lags] = xcorr(S_y, T_y, 500); % limits the lag range from -maxlag to maxlag
plot(r)