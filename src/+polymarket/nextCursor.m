function cursor = nextCursor(response)
%NEXTCURSOR Return a pagination cursor from common response shapes.
cursor = "";
if isempty(response) || ~isstruct(response)
    return
end
fields = ["next_cursor", "nextCursor", "cursor", "next"];
for i = 1:numel(fields)
    name = char(fields(i));
    if isfield(response, name) && ~isempty(response.(name))
        cursor = string(response.(name));
        return
    end
end
if isfield(response, "pagination")
    cursor = polymarket.nextCursor(response.pagination);
end
end

