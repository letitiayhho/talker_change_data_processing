stim$ = "saxophone_f"
filename$ = "/Users/letitiaho/src/talker_change_data_processing/0_set_up_and_raw_data/data/stim/original/" + stim$ + ".wav"
Read from file: filename$
writeFileLine: "./pitch_list.txt", "time,pitch"
selectObject: 1
To Pitch: 0, 75, 600
no_of_frames = Get number of frames

for frame from 1 to no_of_frames
    time = Get time from frame number: frame
    pitch = Get value in frame: frame, "Hertz"
    appendFileLine: "/Users/letitiaho/src/talker_change_data_processing/7_coherence/data/pitch_listings/" + stim$ + ".txt", "'time','pitch'"
endfor



# Load stim, set vars
stim$ = "saxophone_f"
filename$ = "/Users/letitiaho/src/talker_change_data_processing/0_set_up_and_raw_data/data/stim/original/" + stim$ + ".wav"
Read from file: filename$
selectObject: "Sound " + stim$
vowel_start = Get start time
vowel_end = Get end time

# Get pitch listing
Edit
editor "Sound " + stim$
	Select: vowel_start, vowel_end
Pitch listing
"/Users/letitiaho/src/talker_change_data_processing/7_coherence/data/pitch_listings/" + stim$ + ".txt"


