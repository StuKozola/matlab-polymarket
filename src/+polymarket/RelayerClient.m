classdef RelayerClient < polymarket.Client
    %RELAYERCLIENT Client for the Polymarket Relayer API.

    methods
        function obj = RelayerClient(options)
            arguments
                options.BaseUrl string = "https://relayer-v2.polymarket.com"
                options.Auth = []
                options.Timeout double = 30
                options.MaxRetries double = 2
                options.ReturnTables logical = false
            end
            obj@polymarket.Client(options.BaseUrl, "Auth", options.Auth, ...
                "Timeout", options.Timeout, "MaxRetries", options.MaxRetries, ...
                "ReturnTables", options.ReturnTables);
        end

        function data = submitTransaction(obj, body, varargin)
            data = obj.post("/submit", body, varargin{:});
        end

        function data = getTransaction(obj, varargin)
            data = obj.get("/transaction", varargin{:});
        end

        function data = getTransactions(obj, varargin)
            data = obj.get("/transactions", varargin{:});
        end

        function data = getNonce(obj, varargin)
            data = obj.get("/nonce", varargin{:});
        end

        function data = getRelayPayload(obj, varargin)
            data = obj.get("/relay-payload", varargin{:});
        end

        function data = isDeployed(obj, varargin)
            data = obj.get("/deployed", varargin{:});
        end

        function data = getRelayerApiKeys(obj, varargin)
            data = obj.get("/relayer/api/keys", varargin{:});
        end
    end
end

