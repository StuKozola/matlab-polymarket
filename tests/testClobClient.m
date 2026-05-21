classdef testClobClient < matlab.unittest.TestCase
    %TESTCLOBCLIENT Tests for CLOB payload construction.

    methods (Test)
        function createLimitOrderUsesStringTokenAmounts(testCase)
            auth = polymarket.AuthConfig( ...
                "Address", "0x1111111111111111111111111111111111111111", ...
                "ApiKey", "owner-key", ...
                "Secret", "a2V5", ...
                "Passphrase", "pass", ...
                "Funder", "0x2222222222222222222222222222222222222222");
            client = polymarket.ClobClient("Auth", auth);

            payload = client.createLimitOrder("12345", 0.65, 100, "BUY", ...
                "Timestamp", "1700000000000", "Salt", "42");

            testCase.verifyEqual(payload.owner, "owner-key");
            testCase.verifyEqual(payload.order.maker, "0x2222222222222222222222222222222222222222");
            testCase.verifyEqual(payload.order.signer, "0x1111111111111111111111111111111111111111");
            testCase.verifyEqual(payload.order.tokenId, "12345");
            testCase.verifyEqual(payload.order.makerAmount, "65000000");
            testCase.verifyEqual(payload.order.takerAmount, "100000000");
            testCase.verifyEqual(payload.order.side, "BUY");
            testCase.verifyEqual(payload.order.signatureType, polymarket.SignatureType.POLY_1271);
        end

        function createLimitOrderRejectsInvalidSide(testCase)
            client = polymarket.ClobClient("Auth", polymarket.AuthConfig("Address", "0xabc"));

            testCase.verifyError( ...
                @() client.createLimitOrder("123", 0.5, 1, "HOLD"), ...
                "polymarket:InvalidSide");
        end
    end
end

