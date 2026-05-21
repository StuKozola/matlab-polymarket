classdef PythonClobSdk < handle
    %PYTHONCLOBSDK Optional bridge to the official Polymarket Python SDK.
    %   This class delegates EIP-712 API-key and order signing to
    %   py_clob_client_v2 when that package is installed in MATLAB's Python.

    properties
        Host string = "https://clob.polymarket.com"
        ChainId double = 137
        Auth polymarket.AuthConfig
        Client = []
        Module = []
    end

    methods
        function obj = PythonClobSdk(options)
            arguments
                options.Auth polymarket.AuthConfig = polymarket.AuthConfig.fromEnvironment()
                options.Host string = "https://clob.polymarket.com"
                options.ChainId double = 137
            end
            obj.Auth = options.Auth;
            obj.Host = options.Host;
            obj.ChainId = options.ChainId;
            obj.Module = obj.importModule();
            obj.Client = obj.createClient();
        end

        function credentials = createOrDeriveApiKey(obj)
            %CREATEORDERIVEAPIKEY Create or derive CLOB API credentials.
            response = obj.Client.create_or_derive_api_key();
            credentials = struct( ...
                "apiKey", obj.getField(response, ["apiKey", "api_key"]), ...
                "secret", obj.getField(response, ["secret", "api_secret"]), ...
                "passphrase", obj.getField(response, ["passphrase", "api_passphrase"]));
        end

        function response = createAndPostLimitOrder(obj, tokenId, price, size, side, options)
            %CREATEANDPOSTLIMITORDER Sign and post a limit order through the SDK.
            arguments
                obj
                tokenId string
                price double {mustBePositive}
                size double {mustBePositive}
                side string {mustBeMember(side, ["BUY", "SELL"])}
                options.TickSize string = "0.01"
                options.OrderType string = "GTC"
            end

            sideValue = py.getattr(obj.Module.Side, char(upper(side)));
            orderTypeValue = py.getattr(obj.Module.OrderType, char(upper(options.OrderType)));
            orderArgs = obj.Module.OrderArgs(pyargs( ...
                "token_id", char(tokenId), ...
                "price", price, ...
                "side", sideValue, ...
                "size", size));
            createOptions = obj.Module.PartialCreateOrderOptions(pyargs( ...
                "tick_size", char(options.TickSize)));
            response = obj.Client.create_and_post_order(pyargs( ...
                "order_args", orderArgs, ...
                "options", createOptions, ...
                "order_type", orderTypeValue));
        end
    end

    methods (Access = private)
        function module = importModule(~)
            if ~polymarket.PythonClobSdk.isAvailable()
                error("polymarket:MissingPythonSdk", ...
                    "Install py_clob_client_v2 in MATLAB's Python environment before using PythonClobSdk.");
            end
            module = py.importlib.import_module("py_clob_client_v2");
        end

        function client = createClient(obj)
            if strlength(obj.Auth.PrivateKey) == 0
                error("polymarket:MissingPrivateKey", ...
                    "AuthConfig.PrivateKey is required for the Python SDK signing bridge.");
            end

            args = {"host", char(obj.Host), "chain_id", int64(obj.ChainId), ...
                "key", char(obj.Auth.PrivateKey)};
            if obj.Auth.hasL2Credentials()
                creds = obj.Module.ApiCreds(pyargs( ...
                    "api_key", char(obj.Auth.ApiKey), ...
                    "api_secret", char(obj.Auth.Secret), ...
                    "api_passphrase", char(obj.Auth.Passphrase)));
                args = [args, {"creds", creds}];
            end

            extendedArgs = [args, {"signature_type", int64(obj.Auth.SignatureType)}];
            if strlength(obj.Auth.Funder) > 0
                extendedArgs = [extendedArgs, {"funder_address", char(obj.Auth.Funder)}];
            end

            try
                client = obj.Module.ClobClient(pyargs(extendedArgs{:}));
            catch
                client = obj.Module.ClobClient(pyargs(args{:}));
            end
        end

        function value = getField(~, response, names)
            value = "";
            for i = 1:numel(names)
                name = char(names(i));
                try
                    value = string(py.getattr(response, name));
                    if strlength(value) > 0
                        return
                    end
                catch
                end
                try
                    value = string(response{name});
                    if strlength(value) > 0
                        return
                    end
                catch
                end
            end
        end
    end

    methods (Static)
        function tf = isAvailable()
            %ISAVAILABLE True when py_clob_client_v2 imports successfully.
            tf = false;
            try
                py.importlib.import_module("py_clob_client_v2");
                tf = true;
            catch
            end
        end
    end
end

