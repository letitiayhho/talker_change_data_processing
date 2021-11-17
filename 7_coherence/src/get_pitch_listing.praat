form get pitch listings
	word stim
endform

readfile$ = "/Users/letitiaho/src/talker_change_data_processing/0_set_up_and_raw_data/data/stim/original/" + stim$ + ".wav"
writefile$ = "/Users/letitiaho/src/talker_change_data_processing/7_coherence/data/pitch_listings/" + stim$ + ".txt"
Read from file: readfile$
writeFileLine: writefile$, "time,pitch"
selectObject: 1
To Pitch: 0, 75, 600
no_of_frames = Get number of frames

for frame from 1 to no_of_frames
    time = Get time from frame number: frame
    pitch = Get value in frame: frame, "Hertz"
    appendFileLine: writefile$, "'time','pitch'"
endfor


