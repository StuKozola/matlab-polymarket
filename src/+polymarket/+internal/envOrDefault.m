function value = envOrDefault(name, defaultValue)
%ENVORDEFAULT Return an environment variable or a default value.
value = string(getenv(name));
if strlength(value) == 0
    value = string(defaultValue);
end
end

