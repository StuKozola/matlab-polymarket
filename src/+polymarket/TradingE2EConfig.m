classdef TradingE2EConfig
    %TRADINGE2ECONFIG Explicit opt-in settings for live order E2E tests.

    properties
        Enabled logical = false
        TokenId string = ""
        Price double = NaN
        Size double = NaN
        Side string = "BUY"
        TickSize string = "0.01"
        OrderType string = "GTC"
        MaxNotional double = 1.0
    end

    properties (Dependent)
        Notional double
        IsComplete logical
    end

    methods
        function value = get.Notional(obj)
            value = obj.Price * obj.Size;
        end

        function value = get.IsComplete(obj)
            value = obj.Enabled && strlength(obj.TokenId) > 0 && ...
                isfinite(obj.Price) && obj.Price > 0 && obj.Price < 1 && ...
                isfinite(obj.Size) && obj.Size > 0 && ...
                strlength(obj.Side) > 0 && obj.Notional <= obj.MaxNotional;
        end

        function validate(obj)
            %VALIDATE Throw if config is unsafe or incomplete.
            if ~obj.Enabled
                error("polymarket:TradingE2EDisabled", ...
                    "Set POLYMARKET_RUN_TRADING_E2E=true to run live trading E2E.");
            end
            if strlength(obj.TokenId) == 0
                error("polymarket:TradingE2EConfig", ...
                    "Set POLYMARKET_TRADING_TOKEN_ID before running live trading E2E.");
            end
            if ~isfinite(obj.Price) || obj.Price <= 0 || obj.Price >= 1
                error("polymarket:TradingE2EConfig", ...
                    "POLYMARKET_TRADING_PRICE must be between 0 and 1.");
            end
            if ~isfinite(obj.Size) || obj.Size <= 0
                error("polymarket:TradingE2EConfig", ...
                    "POLYMARKET_TRADING_SIZE must be a positive number.");
            end
            if obj.Notional > obj.MaxNotional
                error("polymarket:TradingE2ENotionalLimit", ...
                    "Configured notional %.4f exceeds POLYMARKET_TRADING_MAX_NOTIONAL %.4f.", ...
                    obj.Notional, obj.MaxNotional);
            end
        end
    end

    methods (Static)
        function obj = fromEnvironment()
            %FROMENVIRONMENT Load explicit live trading test settings.
            obj = polymarket.TradingE2EConfig();
            obj.Enabled = localTruthy(getenv("POLYMARKET_RUN_TRADING_E2E"));
            obj.TokenId = string(getenv("POLYMARKET_TRADING_TOKEN_ID"));
            obj.Price = str2double(string(getenv("POLYMARKET_TRADING_PRICE")));
            obj.Size = str2double(string(getenv("POLYMARKET_TRADING_SIZE")));
            obj.Side = upper(localDefault(getenv("POLYMARKET_TRADING_SIDE"), "BUY"));
            obj.TickSize = localDefault(getenv("POLYMARKET_TRADING_TICK_SIZE"), "0.01");
            obj.OrderType = upper(localDefault(getenv("POLYMARKET_TRADING_ORDER_TYPE"), "GTC"));
            obj.MaxNotional = str2double(localDefault(getenv("POLYMARKET_TRADING_MAX_NOTIONAL"), "1"));
        end
    end
end

function value = localTruthy(text)
value = strcmpi(text, "true") || strcmp(text, "1") || strcmpi(text, "yes");
end

function value = localDefault(text, defaultValue)
if strlength(string(text)) == 0
    value = string(defaultValue);
else
    value = string(text);
end
end

