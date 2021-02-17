function [full_file_names] = get_file_names(path, identifier)
% Extract the names of multiple files that with names that match a certain 
% string or identifier
    dir_details = what(path);
    all_mat_files = dir_details.mat;
    file_names = all_mat_files(contains(all_mat_files, identifier));
    full_file_names = fullfile(path, file_names);
end