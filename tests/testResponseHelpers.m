classdef testResponseHelpers < matlab.unittest.TestCase
    %TESTRESPONSEHELPERS Tests for response normalization helpers.

    methods (Test)
        function extractClobTokenIdsParsesGammaJsonString(testCase)
            market = localFixture("gamma_market.json");

            tokenIds = polymarket.extractClobTokenIds(market);

            testCase.verifyEqual(numel(tokenIds), 2);
            testCase.verifyEqual(tokenIds(1), ...
                "1111111111111111111111111111111111111111111111111111111111111111");
        end

        function marketTableReturnsCompactColumns(testCase)
            market = localFixture("gamma_market.json");

            markets = polymarket.marketTable(market);

            testCase.verifyEqual(markets.slug, "example-market");
            testCase.verifyEqual(markets.active, true);
            testCase.verifyTrue(contains(markets.clobTokenIds, "111111"));
        end

        function orderBookTablesAddsNumericColumns(testCase)
            book = localFixture("order_book.json");

            tables = polymarket.orderBookTables(book);

            testCase.verifyEqual(tables.bids.priceNumeric(1), 0.45);
            testCase.verifyEqual(tables.asks.sizeNumeric(2), 125);
            testCase.verifyEqual(string(tables.metadata.asset_id), ...
                "1111111111111111111111111111111111111111111111111111111111111111");
        end

        function nextCursorFindsCommonFields(testCase)
            response = struct("data", [], "next_cursor", "abc");

            cursor = polymarket.nextCursor(response);

            testCase.verifyEqual(cursor, "abc");
        end

        function pythonToMatlabConvertsPythonDict(testCase)
            data = py.dict(pyargs("api_key", "key", "flag", py.bool(true)));

            converted = polymarket.internal.pythonToMatlab(data);

            testCase.verifyEqual(converted.api_key, "key");
            testCase.verifyTrue(converted.flag);
        end
    end
end

function data = localFixture(name)
fixturePath = fullfile(fileparts(mfilename("fullpath")), "fixtures", name);
data = jsondecode(fileread(fixturePath));
end

