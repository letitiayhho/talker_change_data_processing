function [] = permute(git_home, permutations)
arguments
    git_home char
    permutations single
end

    %% Paths
    cd(git_home)
    load('scripts/subject_numbers.txt')
    
    %% Iterate
    for i = 1:permutations
        
        % Cross correlate each subject
        for j = 1:11
            subject_number = num2str(subject_numbers(j));
            cross_correlate(git_home, subject_number, true)
        end
        
        % Shape
        shape_data(git_home, 'cross_correlations')
        
    end
end