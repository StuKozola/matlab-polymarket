function tokenIds = extractClobTokenIds(data)
%EXTRACTCLOBTOKENIDS Extract CLOB token IDs from Gamma market data.
tokenIds = strings(1, 0);
if isempty(data)
    return
end

if istable(data)
    data = table2struct(data);
end

if isstruct(data) && numel(data) > 1
    for i = 1:numel(data)
        tokenIds = [tokenIds, polymarket.extractClobTokenIds(data(i))]; %#ok<AGROW>
    end
    tokenIds = unique(tokenIds, "stable");
    return
end

if isstruct(data)
    tokenIds = collectStructTokens(data);
elseif iscell(data)
    tokenIds = string(data);
elseif isstring(data) || ischar(data)
    tokenIds = parseTokenText(string(data));
end

tokenIds = tokenIds(strlength(tokenIds) > 0);
tokenIds = unique(tokenIds, "stable");
end

function tokenIds = collectStructTokens(data)
tokenIds = strings(1, 0);
candidateFields = ["clobTokenIds", "clob_token_ids", "tokenIds", ...
    "token_ids", "tokens", "outcomeTokens"];
for i = 1:numel(candidateFields)
    name = char(candidateFields(i));
    if isfield(data, name)
        tokenIds = [tokenIds, parseTokenValue(data.(name))]; %#ok<AGROW>
    end
end
end

function tokenIds = parseTokenValue(value)
if isstruct(value)
    tokenIds = strings(1, 0);
    fields = ["token_id", "tokenId", "id"];
    for i = 1:numel(value)
        for j = 1:numel(fields)
            name = char(fields(j));
            if isfield(value(i), name)
                tokenIds(end + 1) = string(value(i).(name)); %#ok<AGROW>
                break
            end
        end
    end
elseif iscell(value)
    tokenIds = strings(1, numel(value));
    for i = 1:numel(value)
        tokenIds(i) = string(value{i});
    end
elseif isnumeric(value)
    tokenIds = string(value);
elseif isstring(value) || ischar(value)
    tokenIds = parseTokenText(string(value));
else
    tokenIds = strings(1, 0);
end
end

function tokenIds = parseTokenText(text)
text = strtrim(text);
if strlength(text) == 0
    tokenIds = strings(1, 0);
    return
end
if startsWith(text, "[")
    decoded = jsondecode(char(text));
    tokenIds = parseTokenValue(decoded);
else
    tokenIds = split(text, ",").';
    tokenIds = strtrim(tokenIds);
end
end

