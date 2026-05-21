%% Live Testing
% Offline tests run by default:
%
%   buildtool test check package
%
% Public live tests are opt-in:
%
%   setenv("POLYMARKET_RUN_INTEGRATION", "true")
%   buildtool integration
%
% Authenticated tests additionally require credentials from environment,
% `.env`, or MATLAB Vault:
%
% POLY_ADDRESS, POLY_API_KEY, POLY_SECRET, POLY_PASSPHRASE

%% WebSocket live test
% Set a known active CLOB token ID and enable WebSocket tests:
%
%   setenv("POLYMARKET_EXAMPLE_TOKEN_ID", "<token id>")
%   setenv("POLYMARKET_RUN_WEBSOCKET_TESTS", "true")
%   buildtool integration

%% Trading E2E
% Trading tests are separate and require explicit order parameters. The test
% posts a post-only limit order through the official SDK bridge and then
% cancels it.
%
%   setenv("POLYMARKET_RUN_TRADING_E2E", "true")
%   setenv("POLYMARKET_TRADING_TOKEN_ID", "<token id>")
%   setenv("POLYMARKET_TRADING_PRICE", "0.01")
%   setenv("POLYMARKET_TRADING_SIZE", "1")
%   setenv("POLYMARKET_TRADING_MAX_NOTIONAL", "1")
%   buildtool trading

