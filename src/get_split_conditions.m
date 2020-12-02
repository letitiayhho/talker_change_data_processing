%% Split four-letter condition code up into individual columns
function [split_conditions] = get_split_conditions(conditions)
% G/S: general (i.e. low) vs specific (i.e. high) constraint sentence stems
% M/N: meaningful vs nonsense ending word in the context of the rest of the sentence
% S/T: same vs different talker in the ending word

for i = 1:size(conditions, 1)
    condition = char(conditions(i, :));
    % Recode S to H to avoid clash with same talker condition
    if condition(1) == 'S'
        constraint(i, :) = 'H';
    else
        constraint(i, :) = 'L';
    end
    meaning(i, :) = condition(2);
    talker(i, :) = condition(3);
end

% Create table of separated IVs
split_conditions = table(constraint, meaning, talker);
end