%% Signing Strategy
% Polymarket CLOB authentication has two distinct signing layers.
%
% * L2 request signing is implemented natively in MATLAB with HMAC-SHA256.
% * L1 EIP-712 API-key signing and order-payload signing use the official
%   Python SDK bridge by default.
%
% The Python bridge keeps the MATLAB toolbox small while matching the
% current upstream Polymarket signing implementation.

%% Install the official SDK
% Configure MATLAB Python, then install:
%
%   run("tools/installPythonSdk.m")
%
% This installs the `py-clob-client-v2` package used by Polymarket's docs.

%% Create or derive API credentials
auth = polymarket.AuthConfig.fromEnvironment();
if polymarket.PythonClobSdk.isAvailable() && strlength(auth.PrivateKey) > 0
    sdk = polymarket.PythonClobSdk("Auth", auth);
    creds = sdk.createOrDeriveApiKey();
    disp(creds);
end

%% Place a guarded test order
% The live trading E2E path requires explicit opt-in variables:
%
% POLYMARKET_RUN_INTEGRATION=true
% POLYMARKET_RUN_TRADING_E2E=true
% POLYMARKET_TRADING_TOKEN_ID=<token id>
% POLYMARKET_TRADING_PRICE=<0..1>
% POLYMARKET_TRADING_SIZE=<positive size>
% POLYMARKET_TRADING_MAX_NOTIONAL=1
%
% Then run:
%
%   buildtool trading

