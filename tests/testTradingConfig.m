classdef testTradingConfig < matlab.unittest.TestCase
    %TESTTRADINGCONFIG Tests for guarded live trading configuration.

    methods (TestMethodSetup)
        function clearTradingEnvironment(testCase)
            names = ["POLYMARKET_RUN_TRADING_E2E", "POLYMARKET_TRADING_TOKEN_ID", ...
                "POLYMARKET_TRADING_PRICE", "POLYMARKET_TRADING_SIZE", ...
                "POLYMARKET_TRADING_MAX_NOTIONAL"];
            for i = 1:numel(names)
                oldValue = getenv(names(i));
                testCase.addTeardown(@() setenv(names(i), oldValue));
                setenv(names(i), "");
            end
        end
    end

    methods (Test)
        function incompleteConfigIsNotRunnable(testCase)
            config = polymarket.TradingE2EConfig.fromEnvironment();

            testCase.verifyFalse(config.IsComplete);
        end

        function configEnforcesNotionalLimit(testCase)
            setenv("POLYMARKET_RUN_TRADING_E2E", "true");
            setenv("POLYMARKET_TRADING_TOKEN_ID", "123");
            setenv("POLYMARKET_TRADING_PRICE", "0.5");
            setenv("POLYMARKET_TRADING_SIZE", "10");
            setenv("POLYMARKET_TRADING_MAX_NOTIONAL", "1");

            config = polymarket.TradingE2EConfig.fromEnvironment();

            testCase.verifyFalse(config.IsComplete);
            testCase.verifyError(@() config.validate(), ...
                "polymarket:TradingE2ENotionalLimit");
        end

        function completeConfigIsRunnable(testCase)
            setenv("POLYMARKET_RUN_TRADING_E2E", "true");
            setenv("POLYMARKET_TRADING_TOKEN_ID", "123");
            setenv("POLYMARKET_TRADING_PRICE", "0.01");
            setenv("POLYMARKET_TRADING_SIZE", "1");
            setenv("POLYMARKET_TRADING_MAX_NOTIONAL", "1");

            config = polymarket.TradingE2EConfig.fromEnvironment();

            testCase.verifyTrue(config.IsComplete);
            testCase.verifyWarningFree(@() config.validate());
        end
    end
end

