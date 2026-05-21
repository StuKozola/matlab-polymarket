classdef DataClient < polymarket.Client
    %DATACLIENT Client for the Polymarket Data API.

    methods
        function obj = DataClient(options)
            arguments
                options.BaseUrl string = "https://data-api.polymarket.com"
                options.Auth = []
                options.Timeout double = 30
                options.MaxRetries double = 2
                options.ReturnTables logical = false
            end
            obj@polymarket.Client(options.BaseUrl, "Auth", options.Auth, ...
                "Timeout", options.Timeout, "MaxRetries", options.MaxRetries, ...
                "ReturnTables", options.ReturnTables);
        end

        function data = health(obj)
            data = obj.get("/");
        end

        function data = getPositions(obj, varargin)
            data = obj.get("/positions", varargin{:});
        end

        function data = getTrades(obj, varargin)
            data = obj.get("/trades", varargin{:});
        end

        function data = getActivity(obj, varargin)
            data = obj.get("/activity", varargin{:});
        end

        function data = getHolders(obj, varargin)
            data = obj.get("/holders", varargin{:});
        end

        function data = getTraded(obj, varargin)
            data = obj.get("/traded", varargin{:});
        end

        function data = getRevisions(obj, varargin)
            data = obj.get("/revisions", varargin{:});
        end

        function data = getValue(obj, varargin)
            data = obj.get("/value", varargin{:});
        end

        function data = getOpenInterest(obj, varargin)
            data = obj.get("/oi", varargin{:});
        end

        function data = getLiveVolume(obj, varargin)
            data = obj.get("/live-volume", varargin{:});
        end

        function data = getClosedPositions(obj, varargin)
            data = obj.get("/closed-positions", varargin{:});
        end

        function data = getOtherSize(obj, varargin)
            data = obj.get("/other", varargin{:});
        end

        function data = getMarketPositions(obj, varargin)
            data = obj.get("/v1/market-positions", varargin{:});
        end

        function data = getBuilderLeaderboard(obj, varargin)
            data = obj.get("/v1/builders/leaderboard", varargin{:});
        end

        function data = getBuilderVolume(obj, varargin)
            data = obj.get("/v1/builders/volume", varargin{:});
        end

        function data = getTraderLeaderboard(obj, varargin)
            data = obj.get("/v1/leaderboard", varargin{:});
        end

        function fileName = downloadAccountingSnapshot(obj, fileName, varargin)
            %DOWNLOADACCOUNTINGSNAPSHOT Download the accounting snapshot ZIP.
            if nargin < 2 || strlength(string(fileName)) == 0
                fileName = fullfile(tempdir, "polymarket-accounting-snapshot.zip");
            end
            bytes = obj.get("/v1/accounting/snapshot", "Raw", true, varargin{:});
            fid = fopen(fileName, "wb");
            cleanup = onCleanup(@() fclose(fid));
            fwrite(fid, bytes, "uint8");
        end
    end
end
