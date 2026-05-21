classdef ClobClient < polymarket.Client
    %CLOBCLIENT Client for the Polymarket CLOB API.

    methods
        function obj = ClobClient(options)
            arguments
                options.BaseUrl string = "https://clob.polymarket.com"
                options.Auth = []
                options.Timeout double = 30
                options.MaxRetries double = 2
                options.ReturnTables logical = false
            end
            obj@polymarket.Client(options.BaseUrl, "Auth", options.Auth, ...
                "Timeout", options.Timeout, "MaxRetries", options.MaxRetries, ...
                "ReturnTables", options.ReturnTables);
        end

        function data = postOrder(obj, payload, varargin)
            payload = obj.signPayloadIfNeeded(payload);
            data = obj.post("/order", payload, "Auth", true, varargin{:});
        end

        function data = postOrders(obj, payloads, varargin)
            for i = 1:numel(payloads)
                payloads(i) = obj.signPayloadIfNeeded(payloads(i));
            end
            data = obj.post("/orders", payloads, "Auth", true, varargin{:});
        end

        function data = cancelOrder(obj, orderID, varargin)
            body = struct("orderID", string(orderID));
            data = obj.delete("/order", body, "Auth", true, varargin{:});
        end

        function data = cancelOrders(obj, orderIDs, varargin)
            data = obj.delete("/orders", string(orderIDs), "Auth", true, varargin{:});
        end

        function data = getOrders(obj, varargin)
            data = obj.get("/data/orders", "Auth", true, varargin{:});
        end

        function data = getOrder(obj, orderID, varargin)
            data = obj.get("/data/order/" + polymarket.internal.urlEncode(orderID), ...
                "Auth", true, varargin{:});
        end

        function data = cancelAllOrders(obj, varargin)
            data = obj.delete("/cancel-all", [], "Auth", true, varargin{:});
        end

        function data = cancelMarketOrders(obj, body, varargin)
            data = obj.delete("/cancel-market-orders", body, "Auth", true, varargin{:});
        end

        function data = getTime(obj)
            data = obj.get("/time");
        end

        function data = getMidpoint(obj, tokenId, varargin)
            data = obj.get("/midpoint", "token_id", tokenId, varargin{:});
        end

        function data = getMidpoints(obj, tokenIds, varargin)
            data = obj.get("/midpoints", "token_ids", polymarket.internal.commaList(tokenIds), varargin{:});
        end

        function data = postMidpoints(obj, body, varargin)
            data = obj.post("/midpoints", body, varargin{:});
        end

        function data = getSpread(obj, tokenId, varargin)
            data = obj.get("/spread", "token_id", tokenId, varargin{:});
        end

        function data = getSpreads(obj, tokenIds, varargin)
            data = obj.get("/spreads", "token_ids", polymarket.internal.commaList(tokenIds), varargin{:});
        end

        function data = getLastTradePrice(obj, tokenId, varargin)
            data = obj.get("/last-trade-price", "token_id", tokenId, varargin{:});
        end

        function data = getLastTradePrices(obj, tokenIds, varargin)
            data = obj.get("/last-trades-prices", "token_ids", polymarket.internal.commaList(tokenIds), varargin{:});
        end

        function data = postLastTradePrices(obj, body, varargin)
            data = obj.post("/last-trades-prices", body, varargin{:});
        end

        function data = getFeeRate(obj, varargin)
            data = obj.get("/fee-rate", varargin{:});
        end

        function data = getFeeRateByPath(obj, tokenId, varargin)
            data = obj.get("/fee-rate/" + polymarket.internal.urlEncode(tokenId), varargin{:});
        end

        function data = getTickSize(obj, varargin)
            data = obj.get("/tick-size", varargin{:});
        end

        function data = getTickSizeByPath(obj, tokenId, varargin)
            data = obj.get("/tick-size/" + polymarket.internal.urlEncode(tokenId), varargin{:});
        end

        function data = getNegRisk(obj, varargin)
            data = obj.get("/neg-risk", varargin{:});
        end

        function data = getNegRiskByPath(obj, tokenId, varargin)
            data = obj.get("/neg-risk/" + polymarket.internal.urlEncode(tokenId), varargin{:});
        end

        function data = getPrice(obj, tokenId, side, varargin)
            data = obj.get("/price", "token_id", tokenId, "side", upper(string(side)), varargin{:});
        end

        function data = getPrices(obj, varargin)
            data = obj.get("/prices", varargin{:});
        end

        function data = postPrices(obj, body, varargin)
            data = obj.post("/prices", body, varargin{:});
        end

        function data = getBook(obj, tokenId, varargin)
            data = obj.get("/book", "token_id", tokenId, varargin{:});
        end

        function data = getBooks(obj, tokenIds, varargin)
            data = obj.get("/books", "token_ids", polymarket.internal.commaList(tokenIds), varargin{:});
        end

        function data = postBooks(obj, body, varargin)
            data = obj.post("/books", body, varargin{:});
        end

        function data = getSimplifiedMarkets(obj, varargin)
            data = obj.get("/simplified-markets", varargin{:});
        end

        function data = getSamplingMarkets(obj, varargin)
            data = obj.get("/sampling-markets", varargin{:});
        end

        function data = getSamplingSimplifiedMarkets(obj, varargin)
            data = obj.get("/sampling-simplified-markets", varargin{:});
        end

        function data = getClobMarketInfo(obj, conditionId, varargin)
            data = obj.get("/clob-markets/" + polymarket.internal.urlEncode(conditionId), varargin{:});
        end

        function data = getMarketByToken(obj, tokenId, varargin)
            data = obj.get("/markets-by-token/" + polymarket.internal.urlEncode(tokenId), varargin{:});
        end

        function data = getMarketsLiveActivity(obj, varargin)
            data = obj.get("/markets/live-activity", varargin{:});
        end

        function data = getMarketLiveActivity(obj, conditionId, varargin)
            data = obj.get("/markets/live-activity/" + polymarket.internal.urlEncode(conditionId), varargin{:});
        end

        function data = getPricesHistory(obj, varargin)
            data = obj.get("/prices-history", varargin{:});
        end

        function data = getBatchPricesHistory(obj, body, varargin)
            data = obj.post("/batch-prices-history", body, varargin{:});
        end

        function data = createApiKey(obj, nonce, varargin)
            headers = obj.l1Headers("POST", "/auth/api-key", "", nonce);
            data = obj.request("POST", "/auth/api-key", "Headers", headers, varargin{:});
        end

        function data = deleteApiKey(obj, varargin)
            data = obj.delete("/auth/api-key", [], "Auth", true, varargin{:});
        end

        function data = getApiKeys(obj, nonce, varargin)
            headers = obj.l1Headers("GET", "/auth/api-keys", "", nonce);
            data = obj.request("GET", "/auth/api-keys", "Headers", headers, varargin{:});
        end

        function data = deriveApiKey(obj, nonce, varargin)
            headers = obj.l1Headers("GET", "/auth/derive-api-key", "", nonce);
            data = obj.request("GET", "/auth/derive-api-key", "Headers", headers, varargin{:});
        end

        function data = getBalanceAllowance(obj, varargin)
            data = obj.get("/balance-allowance", "Auth", true, varargin{:});
        end

        function data = updateBalanceAllowance(obj, body, varargin)
            data = obj.post("/balance-allowance", body, "Auth", true, varargin{:});
        end

        function data = getUpdateBalanceAllowance(obj, varargin)
            data = obj.get("/balance-allowance/update", "Auth", true, varargin{:});
        end

        function data = getClosedOnlyMode(obj, varargin)
            data = obj.get("/auth/ban-status/closed-only", "Auth", true, varargin{:});
        end

        function data = getBuilderApiKeys(obj, varargin)
            data = obj.get("/auth/builder-api-key", "Auth", true, varargin{:});
        end

        function data = createBuilderApiKey(obj, body, varargin)
            data = obj.post("/auth/builder-api-key", body, "Auth", true, varargin{:});
        end

        function data = revokeBuilderApiKey(obj, body, varargin)
            data = obj.delete("/auth/builder-api-key", body, "Auth", true, varargin{:});
        end

        function data = getNotifications(obj, varargin)
            data = obj.get("/notifications", "Auth", true, varargin{:});
        end

        function data = markNotificationsRead(obj, body, varargin)
            data = obj.delete("/notifications", body, "Auth", true, varargin{:});
        end

        function data = getEarningsForUserForDay(obj, varargin)
            data = obj.get("/rewards/user", "Auth", true, varargin{:});
        end

        function data = getTotalEarningsForUserForDay(obj, varargin)
            data = obj.get("/rewards/user/total", "Auth", true, varargin{:});
        end

        function data = getRewardPercentagesForUser(obj, varargin)
            data = obj.get("/rewards/user/percentages", "Auth", true, varargin{:});
        end

        function data = getUserEarningsAndMarketsConfig(obj, varargin)
            data = obj.get("/rewards/user/markets", "Auth", true, varargin{:});
        end

        function data = getCurrentRewards(obj, varargin)
            data = obj.get("/rewards/markets/current", varargin{:});
        end

        function data = getRawRewardsForMarket(obj, conditionId, varargin)
            data = obj.get("/rewards/markets/" + polymarket.internal.urlEncode(conditionId), varargin{:});
        end

        function data = getMultiMarkets(obj, varargin)
            data = obj.get("/rewards/markets/multi", varargin{:});
        end

        function data = getCurrentRebatedFees(obj, varargin)
            data = obj.get("/rebates/current", "Auth", true, varargin{:});
        end

        function data = sendHeartbeat(obj, body, varargin)
            data = obj.post("/heartbeats", body, "Auth", true, varargin{:});
        end

        function data = sendHeartbeatV1(obj, body, varargin)
            data = obj.post("/v1/heartbeats", body, "Auth", true, varargin{:});
        end

        function data = getOrderScoring(obj, varargin)
            data = obj.get("/order-scoring", "Auth", true, varargin{:});
        end

        function data = getOrdersScoring(obj, varargin)
            data = obj.get("/orders-scoring", "Auth", true, varargin{:});
        end

        function data = postOrdersScoring(obj, body, varargin)
            data = obj.post("/orders-scoring", body, "Auth", true, varargin{:});
        end

        function data = getTrades(obj, varargin)
            data = obj.get("/data/trades", "Auth", true, varargin{:});
        end

        function data = getBuilderTrades(obj, varargin)
            data = obj.get("/builder/trades", "Auth", true, varargin{:});
        end

        function payload = createLimitOrder(obj, tokenId, price, size, side, options)
            %CREATELIMITORDER Build a CLOB order payload ready for signing.
            arguments
                obj
                tokenId string
                price double {mustBePositive}
                size double {mustBePositive}
                side string
                options.OrderType string = "GTC"
                options.Maker string = ""
                options.Signer string = ""
                options.Owner string = ""
                options.Expiration string = "0"
                options.Timestamp string = ""
                options.Metadata string = ""
                options.Builder string = "0x0000000000000000000000000000000000000000000000000000000000000000"
                options.PostOnly logical = false
                options.DeferExec logical = false
                options.Salt string = ""
                options.Sign logical = false
            end

            side = upper(string(side));
            if side ~= "BUY" && side ~= "SELL"
                error("polymarket:InvalidSide", "Order side must be BUY or SELL.");
            end
            auth = obj.requireAuthConfig();
            maker = obj.defaultString(options.Maker, obj.defaultString(auth.Funder, auth.Address));
            signer = obj.defaultString(options.Signer, auth.Address);
            owner = obj.defaultString(options.Owner, auth.ApiKey);
            timestamp = obj.defaultString(options.Timestamp, string(floor(posixtime(datetime("now", "TimeZone", "UTC")) * 1000)));
            salt = obj.defaultString(options.Salt, string(randi([1, intmax('int32')])));

            scale = 1e6;
            if side == "BUY"
                makerAmount = round(price * size * scale);
                takerAmount = round(size * scale);
            else
                makerAmount = round(size * scale);
                takerAmount = round(price * size * scale);
            end

            order = struct( ...
                "maker", maker, ...
                "signer", signer, ...
                "tokenId", tokenId, ...
                "makerAmount", string(makerAmount), ...
                "takerAmount", string(takerAmount), ...
                "side", side, ...
                "expiration", string(options.Expiration), ...
                "timestamp", timestamp, ...
                "metadata", options.Metadata, ...
                "builder", options.Builder, ...
                "signature", "", ...
                "salt", salt, ...
                "signatureType", auth.SignatureType);

            if options.Sign
                order = auth.signOrder(order);
            end

            payload = struct( ...
                "order", order, ...
                "owner", owner, ...
                "orderType", upper(string(options.OrderType)), ...
                "deferExec", options.DeferExec, ...
                "postOnly", options.PostOnly);
        end
    end

    methods (Access = private)
        function headers = l1Headers(obj, method, path, body, nonce)
            auth = obj.requireAuthConfig();
            headers = auth.l1Headers(method, path, body, nonce);
        end

        function auth = requireAuthConfig(obj)
            if isempty(obj.Auth)
                error("polymarket:MissingAuth", "AuthConfig is required for this operation.");
            end
            auth = obj.Auth;
        end

        function payload = signPayloadIfNeeded(obj, payload)
            if isstruct(payload) && isfield(payload, "order") && isfield(payload.order, "signature")
                if strlength(string(payload.order.signature)) == 0 && ~isempty(obj.Auth) && ~isempty(obj.Auth.OrderSigner)
                    payload.order = obj.Auth.signOrder(payload.order);
                end
            end
        end

        function value = defaultString(~, value, fallback)
            if strlength(string(value)) == 0
                value = string(fallback);
            else
                value = string(value);
            end
        end
    end
end
