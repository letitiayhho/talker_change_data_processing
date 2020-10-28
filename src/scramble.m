function [] = scramble(git_home, scrambles, unique_id)
arguments
    git_home string
    scrambles string
    unique_id string
end

    %% Paths
    cd(git_home)
    load('scripts/subject_numbers.txt')
    
    %% Iterate
    scrambles = str2num(scrambles);
    for i = 1:scrambles
        
        
        % Cross correlate each subject
        for j = 1:11
            subject_number = num2str(subject_numbers(j));
            cross_correlations_file_name = cross_correlate(git_home, subject_number, unique_id, true)
        end
        
        % Shape
        shape_data(git_home, unique_id, cross_correlations_file_name)
        
    end
end
