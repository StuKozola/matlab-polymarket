classdef testTradingE2E < matlab.unittest.TestCase
    %TESTTRADINGE2E Explicit opt-in live order placement and cancellation.

    methods (Test, TestTags = {'Integration', 'Trading'})
        function postOnlyTinyLimitOrderCanBeCanceled(testCase)
            testCase.assumeTrue(localIntegrationEnabled());
            config = polymarket.TradingE2EConfig.fromEnvironment();
            testCase.assumeTrue(config.IsComplete);
            config.validate();
            testCase.assumeTrue(polymarket.PythonClobSdk.isAvailable());
            auth = polymarket.AuthConfig.fromEnvironment();
            testCase.assumeTrue(auth.hasL2Credentials());
            testCase.assumeGreaterThan(strlength(auth.PrivateKey), 0);
            sdk = polymarket.PythonClobSdk("Auth", auth);
            clob = polymarket.ClobClient("Auth", auth);

            response = sdk.createAndPostLimitOrder(config.TokenId, config.Price, ...
                config.Size, config.Side, "TickSize", config.TickSize, ...
                "OrderType", config.OrderType, "PostOnly", true);
            orderId = polymarket.internal.extractOrderId(response);
            testCase.addTeardown(@() localCancelIfPossible(clob, orderId));

            testCase.verifyNotEmpty(response);
            testCase.verifyGreaterThan(strlength(orderId), 0);
            cancelResponse = clob.cancelOrder(orderId);

            testCase.verifyNotEmpty(cancelResponse);
        end
    end
end

function tf = localIntegrationEnabled()
tf = strcmpi(getenv("POLYMARKET_RUN_INTEGRATION"), "true") || ...
    strcmp(getenv("POLYMARKET_RUN_INTEGRATION"), "1");
end

function localCancelIfPossible(clob, orderId)
if strlength(orderId) == 0
    return
end
try
    clob.cancelOrder(orderId);
catch
end
end

