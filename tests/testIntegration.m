classdef testIntegration < matlab.unittest.TestCase
    %TESTINTEGRATION Live API smoke tests, skipped unless explicitly enabled.

    methods (Test, TestTags = {'Integration'})
        function clobPublicTimeEndpointResponds(testCase)
            testCase.assumeTrue(localIntegrationEnabled());
            client = polymarket.ClobClient();

            response = client.getTime();

            testCase.verifyNotEmpty(response);
        end

        function gammaPublicMarketsRespond(testCase)
            testCase.assumeTrue(localIntegrationEnabled());
            client = polymarket.GammaClient();

            response = client.listMarkets("limit", 1);

            testCase.verifyNotEmpty(response);
        end

        function bridgeSupportedAssetsRespond(testCase)
            testCase.assumeTrue(localIntegrationEnabled());
            client = polymarket.BridgeClient();

            response = client.getSupportedAssets();

            testCase.verifyNotEmpty(response);
        end

        function clobAuthenticatedOrdersRespond(testCase)
            testCase.assumeTrue(localIntegrationEnabled());
            auth = polymarket.AuthConfig.fromEnvironment();
            testCase.assumeTrue(auth.hasL2Credentials());
            client = polymarket.ClobClient("Auth", auth);

            response = client.getOrders("limit", 1);

            testCase.verifyNotEmpty(response);
        end

        function marketWebSocketReceivesMessage(testCase)
            testCase.assumeTrue(localIntegrationEnabled());
            testCase.assumeTrue(localWebSocketTestsEnabled());
            tokenId = string(getenv("POLYMARKET_EXAMPLE_TOKEN_ID"));
            testCase.assumeGreaterThan(strlength(tokenId), 0);
            client = polymarket.WebSocketClient.market();
            testCase.addTeardown(@() client.close());

            client.subscribe(tokenId);
            message = client.receive(10);

            testCase.verifyNotEmpty(message);
        end
    end
end

function tf = localIntegrationEnabled()
tf = strcmpi(getenv("POLYMARKET_RUN_INTEGRATION"), "true") || ...
    strcmp(getenv("POLYMARKET_RUN_INTEGRATION"), "1");
end

function tf = localWebSocketTestsEnabled()
tf = strcmpi(getenv("POLYMARKET_RUN_WEBSOCKET_TESTS"), "true") || ...
    strcmp(getenv("POLYMARKET_RUN_WEBSOCKET_TESTS"), "1");
end
