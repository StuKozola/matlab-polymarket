function tableOut = marketTable(markets)
%MARKETTABLE Convert Gamma market structs into a compact MATLAB table.
if isempty(markets)
    tableOut = table();
    return
end
if istable(markets)
    tableOut = markets;
    return
end
if iscell(markets)
    markets = [markets{:}];
end

rows = repmat(emptyRow(), numel(markets), 1);
for i = 1:numel(markets)
    row = emptyRow();
    row.id = fieldString(markets(i), ["id", "marketId"]);
    row.slug = fieldString(markets(i), "slug");
    row.question = fieldString(markets(i), ["question", "title"]);
    row.conditionId = fieldString(markets(i), ["conditionId", "condition_id"]);
    row.active = fieldLogical(markets(i), "active");
    row.closed = fieldLogical(markets(i), "closed");
    row.clobTokenIds = strjoin(polymarket.extractClobTokenIds(markets(i)), ",");
    rows(i) = row;
end
tableOut = struct2table(rows);
end

function row = emptyRow()
row = struct( ...
    "id", "", ...
    "slug", "", ...
    "question", "", ...
    "conditionId", "", ...
    "active", false, ...
    "closed", false, ...
    "clobTokenIds", "");
end

function value = fieldString(data, names)
value = "";
for i = 1:numel(names)
    name = char(names(i));
    if isfield(data, name) && ~isempty(data.(name))
        value = string(data.(name));
        return
    end
end
end

function value = fieldLogical(data, name)
value = false;
name = char(name);
if isfield(data, name) && ~isempty(data.(name))
    value = logical(data.(name));
end
end

