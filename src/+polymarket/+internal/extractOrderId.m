function orderId = extractOrderId(response)
%EXTRACTORDERID Extract an order identifier from common response shapes.
orderId = "";
if isempty(response)
    return
end
if isstruct(response)
    orderId = extractFromStruct(response);
elseif isa(response, "py.object")
    orderId = extractFromPython(response);
end
end

function orderId = extractFromStruct(response)
fields = ["orderID", "orderId", "order_id", "id"];
for i = 1:numel(fields)
    name = char(fields(i));
    if isfield(response, name) && ~isempty(response.(name))
        orderId = string(response.(name));
        return
    end
end
if isfield(response, "order") && isstruct(response.order)
    orderId = extractFromStruct(response.order);
else
    orderId = "";
end
end

function orderId = extractFromPython(response)
orderId = "";
fields = ["orderID", "orderId", "order_id", "id"];
for i = 1:numel(fields)
    try
        value = string(py.getattr(response, char(fields(i))));
        if strlength(value) > 0
            orderId = value;
            return
        end
    catch
    end
end
end

