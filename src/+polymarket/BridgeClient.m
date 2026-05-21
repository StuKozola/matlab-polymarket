classdef BridgeClient < polymarket.Client
    %BRIDGECLIENT Client for the Polymarket Bridge API.

    methods
        function obj = BridgeClient(options)
            arguments
                options.BaseUrl string = "https://bridge.polymarket.com"
                options.Auth = []
                options.Timeout double = 30
                options.MaxRetries double = 2
                options.ReturnTables logical = false
            end
            obj@polymarket.Client(options.BaseUrl, "Auth", options.Auth, ...
                "Timeout", options.Timeout, "MaxRetries", options.MaxRetries, ...
                "ReturnTables", options.ReturnTables);
        end

        function data = getSupportedAssets(obj, varargin)
            data = obj.get("/supported-assets", varargin{:});
        end

        function data = getQuote(obj, varargin)
            data = obj.get("/quote", varargin{:});
        end

        function data = createDepositAddresses(obj, body, varargin)
            data = obj.post("/deposit", body, varargin{:});
        end

        function data = createWithdrawalAddresses(obj, body, varargin)
            data = obj.post("/withdraw", body, varargin{:});
        end

        function data = getTransactionStatus(obj, address, varargin)
            data = obj.get("/status/" + polymarket.internal.urlEncode(address), varargin{:});
        end
    end
end

