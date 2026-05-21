function value = getVaultSecret(name)
%GETVAULTSECRET Retrieve a MATLAB Vault secret when it exists.
value = "";
try
    if exist("isSecret", "file") == 2 && isSecret(name)
        value = string(getSecret(name));
    end
catch
    value = "";
end
end

