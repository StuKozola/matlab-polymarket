function queryText = encodeQuery(query)
%ENCODEQUERY Encode a struct or containers.Map as a URL query string.
queryText = "";
if nargin == 0 || isempty(query)
    return
end

parts = strings(1, 0);
if isa(query, "containers.Map")
    names = string(query.keys);
    for i = 1:numel(names)
        parts = appendValue(parts, names(i), query(char(names(i)))); %#ok<AGROW>
    end
elseif isstruct(query)
    names = string(fieldnames(query));
    for i = 1:numel(names)
        parts = appendValue(parts, names(i), query.(names(i))); %#ok<AGROW>
    end
else
    error("polymarket:InvalidQuery", "Query must be a struct or containers.Map.");
end

parts = parts(strlength(parts) > 0);
if ~isempty(parts)
    queryText = strjoin(parts, "&");
end
end

function parts = appendValue(parts, name, value)
if isempty(value)
    return
end
if iscell(value)
    for j = 1:numel(value)
        parts = appendValue(parts, name, value{j}); %#ok<AGROW>
    end
    return
end
if isstring(value) && ~isscalar(value)
    for j = 1:numel(value)
        parts = appendValue(parts, name, value(j)); %#ok<AGROW>
    end
    return
end
if isnumeric(value) && ~isscalar(value)
    for j = 1:numel(value)
        parts = appendValue(parts, name, value(j)); %#ok<AGROW>
    end
    return
end
if islogical(value)
    valueText = lower(string(value));
elseif isdatetime(value)
    valueText = string(value, "yyyy-MM-dd'T'HH:mm:ss'Z'");
elseif isduration(value)
    valueText = string(seconds(value));
elseif isstruct(value)
    valueText = string(jsonencode(value));
else
    valueText = string(value);
end
parts(end + 1) = polymarket.internal.urlEncode(name) + "=" + ...
    polymarket.internal.urlEncode(valueText);
end

