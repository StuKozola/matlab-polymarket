classdef testInternalHelpers < matlab.unittest.TestCase
    %TESTINTERNALHELPERS Tests for local helpers that do not hit the network.

    methods (Test)
        function encodeQueryHandlesArraysAndBooleans(testCase)
            query = struct( ...
                "limit", 10, ...
                "active", true, ...
                "token_ids", ["abc", "def"], ...
                "space", "a b");

            actual = polymarket.internal.encodeQuery(query);

            testCase.verifyTrue(contains(actual, "limit=10"));
            testCase.verifyTrue(contains(actual, "active=true"));
            testCase.verifyTrue(contains(actual, "token_ids=abc"));
            testCase.verifyTrue(contains(actual, "token_ids=def"));
            testCase.verifyTrue(contains(actual, "space=a%20b"));
        end

        function hmacMatchesKnownVector(testCase)
            signature = polymarket.internal.hmacSha256Base64Url("a2V5", "123GET/path");

            testCase.verifyEqual(signature, "FqsuFtRa5irhBYFUFCVmgn8k7T7Hh-EkuSUrUqPJz8Q");
        end

        function authConfigBuildsL2Headers(testCase)
            auth = polymarket.AuthConfig( ...
                "Address", "0xabc", ...
                "ApiKey", "api-key", ...
                "Secret", "a2V5", ...
                "Passphrase", "pass");

            headers = auth.l2Headers("GET", "/path", "", "123");

            testCase.verifyEqual(string(headers.POLY_ADDRESS), "0xabc");
            testCase.verifyEqual(string(headers.POLY_API_KEY), "api-key");
            testCase.verifyEqual(string(headers.POLY_PASSPHRASE), "pass");
            testCase.verifyEqual(string(headers.POLY_TIMESTAMP), "123");
            testCase.verifyEqual(string(headers.POLY_SIGNATURE), "FqsuFtRa5irhBYFUFCVmgn8k7T7Hh-EkuSUrUqPJz8Q");
        end

        function websocketDecodeParsesJson(testCase)
            message = polymarket.WebSocketClient.decodeMessage('{"event_type":"book","asset_id":"123"}');

            testCase.verifyEqual(string(message.event_type), "book");
            testCase.verifyEqual(string(message.asset_id), "123");
        end

        function pythonSdkAvailabilityReturnsLogical(testCase)
            available = polymarket.PythonClobSdk.isAvailable();

            testCase.verifyClass(available, "logical");
        end
    end
end
