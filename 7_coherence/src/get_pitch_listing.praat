# Load stim, set vars
filename$ = "/Users/letitiaho/src/talker_change_data_processing/0_set_up_and_raw_data/data/stim/original/" + stim$ + ".wav"
Read from file: filename$
selectObject: "Sound " + stim$
Copy: stim$ + "_copy"
selectObject: "Sound " + stim$ + "_copy"
vowel_start = Get start time
vowel_end = Get end time

# Get pitch listing
View & Edit
Select: vowel_start, vowel_end
Pitch listing
"/Users/letitiaho/src/talker_change_data_processing/7_coherence/data/pitch_listings/" + stim$ + ".txt"
