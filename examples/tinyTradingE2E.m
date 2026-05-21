%% Explicit opt-in tiny live order placement and cancellation.
% This example uses the official Python SDK bridge for EIP-712 signing.
% It will not run unless all POLYMARKET_TRADING_* safety variables are set.
addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

config = polymarket.TradingE2EConfig.fromEnvironment();
config.validate();

auth = polymarket.AuthConfig.fromEnvironment();
if ~auth.hasL2Credentials() || strlength(auth.PrivateKey) == 0
    error("Set L2 credentials and POLY_PRIVATE_KEY before running this example.");
end
if ~polymarket.PythonClobSdk.isAvailable()
    error("Install py-clob-client-v2 in MATLAB's Python environment first.");
end

sdk = polymarket.PythonClobSdk("Auth", auth);
clob = polymarket.ClobClient("Auth", auth);

response = sdk.createAndPostLimitOrder(config.TokenId, config.Price, ...
    config.Size, config.Side, "TickSize", config.TickSize, ...
    "OrderType", config.OrderType, "PostOnly", true);
disp(response);

orderId = polymarket.internal.extractOrderId(response);
if strlength(orderId) > 0
    cancelResponse = clob.cancelOrder(orderId);
    disp(cancelResponse);
else
    warning("polymarket:MissingOrderId", ...
        "Could not identify an order ID to cancel from the response.");
end

