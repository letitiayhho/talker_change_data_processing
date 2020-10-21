function [] = scramble(git_home, scrambles)
arguments
    git_home char
    scrambles string
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
            cross_correlate(git_home, subject_number, true)
        end
        
        % Shape
        shape_data(git_home, 'cross_correlations_scramble')
        
    end
end