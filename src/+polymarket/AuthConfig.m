classdef AuthConfig
    %AUTHCONFIG Authentication settings for Polymarket API clients.
    %   Stores CLOB L2 API credentials, wallet metadata, and optional signer
    %   callbacks for L1/API-key and order signing operations.

    properties
        Address string = ""
        ApiKey string = ""
        Secret string = ""
        Passphrase string = ""
        PrivateKey string = ""
        SignatureType double = polymarket.SignatureType.POLY_1271
        Funder string = ""
        ChainId double = 137
        L1Signer = []
        OrderSigner = []
    end

    methods
        function obj = AuthConfig(options)
            arguments
                options.Address string = ""
                options.ApiKey string = ""
                options.Secret string = ""
                options.Passphrase string = ""
                options.PrivateKey string = ""
                options.SignatureType = polymarket.SignatureType.POLY_1271
                options.Funder string = ""
                options.ChainId double = 137
                options.L1Signer = []
                options.OrderSigner = []
            end

            obj.Address = options.Address;
            obj.ApiKey = options.ApiKey;
            obj.Secret = options.Secret;
            obj.Passphrase = options.Passphrase;
            obj.PrivateKey = options.PrivateKey;
            obj.SignatureType = polymarket.SignatureType.parse(options.SignatureType);
            obj.Funder = options.Funder;
            obj.ChainId = options.ChainId;
            obj.L1Signer = options.L1Signer;
            obj.OrderSigner = options.OrderSigner;
        end

        function tf = hasL2Credentials(obj)
            %HASL2CREDENTIALS True when all CLOB API key headers can be built.
            tf = strlength(obj.Address) > 0 && strlength(obj.ApiKey) > 0 && ...
                strlength(obj.Secret) > 0 && strlength(obj.Passphrase) > 0;
        end

        function headers = l2Headers(obj, method, requestPath, bodyText, timestamp)
            %L2HEADERS Build POLY_* HMAC headers for authenticated CLOB calls.
            if nargin < 5 || strlength(string(timestamp)) == 0
                timestamp = string(floor(posixtime(datetime("now", "TimeZone", "UTC"))));
            else
                timestamp = string(timestamp);
            end
            if nargin < 4 || isempty(bodyText)
                bodyText = "";
            end

            if ~obj.hasL2Credentials()
                error("polymarket:MissingCredentials", ...
                    "Address, API key, secret, and passphrase are required for L2 authentication.");
            end

            message = char(timestamp + upper(string(method)) + string(requestPath) + string(bodyText));
            signature = polymarket.internal.hmacSha256Base64Url(obj.Secret, message);

            headers = struct( ...
                "POLY_ADDRESS", char(obj.Address), ...
                "POLY_SIGNATURE", char(signature), ...
                "POLY_TIMESTAMP", char(timestamp), ...
                "POLY_API_KEY", char(obj.ApiKey), ...
                "POLY_PASSPHRASE", char(obj.Passphrase));
        end

        function headers = l1Headers(obj, method, requestPath, bodyText, nonce, timestamp)
            %L1HEADERS Build L1 headers using a caller-provided signer callback.
            if nargin < 6 || strlength(string(timestamp)) == 0
                timestamp = string(floor(posixtime(datetime("now", "TimeZone", "UTC"))));
            else
                timestamp = string(timestamp);
            end
            if nargin < 5 || isempty(nonce)
                nonce = 0;
            end
            if nargin < 4 || isempty(bodyText)
                bodyText = "";
            end
            if strlength(obj.Address) == 0
                error("polymarket:MissingCredentials", "Address is required for L1 authentication.");
            end
            if isempty(obj.L1Signer)
                error("polymarket:MissingSigner", ...
                    "Set AuthConfig.L1Signer to create or derive CLOB API keys.");
            end

            payload = struct( ...
                "address", obj.Address, ...
                "chainId", obj.ChainId, ...
                "method", upper(string(method)), ...
                "path", string(requestPath), ...
                "body", string(bodyText), ...
                "timestamp", timestamp, ...
                "nonce", nonce);
            signature = obj.L1Signer(payload);

            headers = struct( ...
                "POLY_ADDRESS", char(obj.Address), ...
                "POLY_SIGNATURE", char(signature), ...
                "POLY_TIMESTAMP", char(timestamp), ...
                "POLY_NONCE", char(string(nonce)));
        end

        function credentials = websocketAuth(obj)
            %WEBSOCKETAUTH Return the user-channel auth payload.
            if ~obj.hasL2Credentials()
                error("polymarket:MissingCredentials", ...
                    "API key, secret, and passphrase are required for the user WebSocket channel.");
            end
            credentials = struct( ...
                "apiKey", obj.ApiKey, ...
                "secret", obj.Secret, ...
                "passphrase", obj.Passphrase);
        end

        function signedOrder = signOrder(obj, order)
            %SIGNORDER Sign an order using a caller-provided signer callback.
            if isempty(obj.OrderSigner)
                error("polymarket:MissingSigner", ...
                    "Set AuthConfig.OrderSigner before posting signed CLOB orders.");
            end
            signedOrder = obj.OrderSigner(order);
        end
    end

    methods (Static)
        function obj = fromEnvironment(options)
            %FROMENVIRONMENT Create AuthConfig from environment, .env, and Vault.
            %   Environment variables take precedence over .env values, which
            %   take precedence over MATLAB Vault secrets with the same names.
            arguments
                options.DotEnvFile string = ".env"
                options.UseEnvironment logical = true
                options.UseDotEnv logical = true
                options.UseVault logical = true
                options.VaultPrefix string = ""
                options.SecretProvider = []
            end

            dotenv = containers.Map("KeyType", "char", "ValueType", "char");
            if options.UseDotEnv && strlength(options.DotEnvFile) > 0
                dotenv = polymarket.internal.loadDotEnv(options.DotEnvFile);
            end

            provider = options.SecretProvider;
            if isempty(provider) && options.UseVault
                provider = @(name) polymarket.internal.getVaultSecret(options.VaultPrefix + string(name));
            end

            obj = polymarket.AuthConfig( ...
                "Address", readCredential("POLY_ADDRESS", ""), ...
                "ApiKey", readCredential("POLY_API_KEY", ""), ...
                "Secret", readCredential("POLY_SECRET", ""), ...
                "Passphrase", readCredential("POLY_PASSPHRASE", ""), ...
                "PrivateKey", readCredential("POLY_PRIVATE_KEY", ""), ...
                "SignatureType", readCredential("POLY_SIGNATURE_TYPE", "POLY_1271"), ...
                "Funder", readCredential("POLY_FUNDER", ""));

            function value = readCredential(name, defaultValue)
                if options.UseEnvironment
                    value = string(getenv(name));
                    if strlength(value) > 0
                        return
                    end
                end
                if isKey(dotenv, name)
                    value = string(dotenv(char(name)));
                    if strlength(value) > 0
                        return
                    end
                end
                if ~isempty(provider)
                    value = string(provider(name));
                    if strlength(value) > 0
                        return
                    end
                end
                value = string(defaultValue);
            end
        end

        function obj = fromDotEnv(fileName)
            %FROMDOTENV Create AuthConfig from a .env file only.
            arguments
                fileName string = ".env"
            end
            obj = polymarket.AuthConfig.fromEnvironment( ...
                "DotEnvFile", fileName, "UseEnvironment", false, ...
                "UseDotEnv", true, "UseVault", false);
        end

        function obj = fromVault(options)
            %FROMVAULT Create AuthConfig from MATLAB Vault secrets only.
            arguments
                options.VaultPrefix string = ""
                options.SecretProvider = []
            end
            obj = polymarket.AuthConfig.fromEnvironment( ...
                "UseEnvironment", false, "UseDotEnv", false, "UseVault", true, ...
                "VaultPrefix", options.VaultPrefix, ...
                "SecretProvider", options.SecretProvider);
        end
    end
end
