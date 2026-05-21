function out = orderBookTables(book)
%ORDERBOOKTABLES Convert CLOB order book bid/ask arrays into tables.
out = struct("bids", table(), "asks", table(), "metadata", table());
if isempty(book) || ~isstruct(book)
    return
end

if isfield(book, "bids")
    out.bids = priceLevelTable(book.bids);
end
if isfield(book, "asks")
    out.asks = priceLevelTable(book.asks);
end
metadata = rmfieldSafe(book, ["bids", "asks"]);
if ~isempty(fieldnames(metadata))
    out.metadata = struct2table(metadata, "AsArray", true);
end
end

function tableOut = priceLevelTable(levels)
if isempty(levels)
    tableOut = table();
    return
end
if iscell(levels)
    levels = [levels{:}];
end
tableOut = struct2table(levels);
if any(strcmp(tableOut.Properties.VariableNames, "price"))
    tableOut.priceNumeric = str2double(string(tableOut.price));
end
if any(strcmp(tableOut.Properties.VariableNames, "size"))
    tableOut.sizeNumeric = str2double(string(tableOut.size));
end
end

function data = rmfieldSafe(data, names)
for i = 1:numel(names)
    name = char(names(i));
    if isfield(data, name)
        data = rmfield(data, name);
    end
end
end

