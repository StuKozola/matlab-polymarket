function values = loadDotEnv(fileName)
%LOADDOTENV Parse a dotenv file into a containers.Map.
values = containers.Map("KeyType", "char", "ValueType", "char");
fileName = char(string(fileName));
if ~isfile(fileName)
    return
end

lines = readlines(fileName, "EmptyLineRule", "read");
for i = 1:numel(lines)
    line = strtrim(lines(i));
    if strlength(line) == 0 || startsWith(line, "#")
        continue
    end
    if startsWith(line, "export ")
        line = extractAfter(line, strlength("export "));
        line = strtrim(line);
    end
    separator = strfind(char(line), "=");
    if isempty(separator)
        continue
    end
    key = strtrim(extractBefore(line, separator(1)));
    value = strtrim(extractAfter(line, separator(1)));
    values(char(key)) = char(stripQuotes(value));
end
end

function value = stripQuotes(value)
if strlength(value) >= 2
    first = extractBetween(value, 1, 1);
    last = extractBetween(value, strlength(value), strlength(value));
    if (first == """" && last == """") || (first == "'" && last == "'")
        value = extractBetween(value, 2, strlength(value) - 1);
    end
end
value = string(value);
end

