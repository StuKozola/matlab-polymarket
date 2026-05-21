function value = commaList(items)
%COMMALIST Convert a scalar or vector into a comma-separated string.
if ischar(items) || (isstring(items) && isscalar(items))
    value = string(items);
elseif isnumeric(items)
    value = strjoin(string(items(:).'), ",");
elseif iscell(items)
    value = strjoin(string(items(:).'), ",");
else
    value = strjoin(string(items(:).'), ",");
end
end

