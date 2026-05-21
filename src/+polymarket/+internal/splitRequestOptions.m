function [query, auth, headers, raw] = splitRequestOptions(varargin)
%SPLITREQUESTOPTIONS Split endpoint name-value pairs from client options.
query = struct();
auth = false;
headers = struct();
raw = false;

if nargin == 0
    return
end
if nargin == 1 && isstruct(varargin{1})
    query = varargin{1};
    return
end
if mod(nargin, 2) ~= 0
    error("polymarket:InvalidNameValue", "Expected name-value pairs.");
end

for i = 1:2:nargin
    name = string(varargin{i});
    value = varargin{i + 1};
    switch lower(name)
        case "auth"
            auth = value;
        case "headers"
            headers = value;
        case "raw"
            raw = logical(value);
        case "query"
            query = mergeStruct(query, value);
        otherwise
            if ~isvarname(char(name))
                error("polymarket:InvalidQueryName", ...
                    "Query parameter name must be a valid MATLAB field name: %s", name);
            end
            query.(char(name)) = value;
    end
end
end

function out = mergeStruct(out, value)
if isempty(value)
    return
end
if ~isstruct(value)
    error("polymarket:InvalidQuery", "Query option must be a struct.");
end
names = fieldnames(value);
for j = 1:numel(names)
    out.(names{j}) = value.(names{j});
end
end

