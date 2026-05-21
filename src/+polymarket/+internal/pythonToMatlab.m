function value = pythonToMatlab(input)
%PYTHONTOMATLAB Convert common Python values to MATLAB values.
if isempty(input)
    value = [];
elseif isa(input, "py.dict")
    value = dictToStruct(input);
elseif isa(input, "py.list") || isa(input, "py.tuple")
    value = sequenceToCell(input);
elseif isa(input, "py.str")
    value = string(input);
elseif isa(input, "py.bool")
    value = logical(input);
elseif isa(input, "py.int")
    value = double(input);
elseif isa(input, "py.float")
    value = double(input);
elseif isa(input, "py.NoneType")
    value = [];
elseif isa(input, "py.object")
    value = objectToStruct(input);
else
    value = input;
end
end

function value = dictToStruct(input)
value = struct();
keys = cell(py.list(input.keys()));
for i = 1:numel(keys)
    key = string(keys{i});
    field = matlab.lang.makeValidName(char(key));
    value.(field) = polymarket.internal.pythonToMatlab(input{keys{i}});
end
end

function value = sequenceToCell(input)
items = cell(input);
value = cell(size(items));
for i = 1:numel(items)
    value{i} = polymarket.internal.pythonToMatlab(items{i});
end
end

function value = objectToStruct(input)
try
    dataclasses = py.importlib.import_module("dataclasses");
    if logical(dataclasses.is_dataclass(input))
        value = polymarket.internal.pythonToMatlab(dataclasses.asdict(input));
        return
    end
catch
end

try
    value = polymarket.internal.pythonToMatlab(py.getattr(input, "__dict__"));
catch
    value = string(input);
end
end
