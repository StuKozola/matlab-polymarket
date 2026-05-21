function data = maybeTable(data)
%MAYBETABLE Convert homogeneous struct arrays to tables.
if isstruct(data) && numel(data) > 1
    try
        data = struct2table(data);
    catch
    end
end
end

