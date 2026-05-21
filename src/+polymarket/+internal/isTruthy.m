function tf = isTruthy(value)
%ISTRUTHY True for logical true or nonempty non-false auth mode strings.
if islogical(value)
    tf = value;
elseif isnumeric(value)
    tf = value ~= 0;
else
    text = lower(string(value));
    tf = strlength(text) > 0 && text ~= "false" && text ~= "none" && text ~= "0";
end
end

