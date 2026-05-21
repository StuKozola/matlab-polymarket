%% Getting Started with MATLAB Polymarket
% This toolbox provides MATLAB clients for Polymarket's documented APIs:
%
% * Gamma API: markets, events, tags, profiles, sports metadata, and search
% * Data API: positions, trades, activity, holders, open interest, and leaderboards
% * CLOB API: order books, prices, authenticated orders, rewards, rebates, and API keys
% * Bridge and Relayer APIs
% * Market, User, and Sports WebSocket channels

%% Public market data
addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

gamma = polymarket.GammaClient();
markets = gamma.listMarkets("limit", 5, "active", true);
disp(markets);

%% CLOB data
% Resolve CLOB token IDs from a Gamma market, then call the CLOB client.
clob = polymarket.ClobClient();
serverTime = clob.getTime();
disp(serverTime);

%% Authenticated requests
% Configure credentials as environment variables:
%
% POLY_ADDRESS, POLY_API_KEY, POLY_SECRET, POLY_PASSPHRASE
%
% Then create an authenticated client:
auth = polymarket.AuthConfig.fromEnvironment();
if auth.hasL2Credentials()
    privateClob = polymarket.ClobClient("Auth", auth);
    disp(privateClob.getOrders());
end

%% Signing callbacks
% L1 API-key creation and order signing are extension points. Set
% AuthConfig.L1Signer or AuthConfig.OrderSigner to a function handle that
% accepts the payload struct and returns the signature or signed order.

%% WebSockets
% Build the Java helper once before using WebSockets:
%
%   run("tools/buildJavaHelper.m")
%
% Then connect to a channel:
%
%   ws = polymarket.WebSocketClient.market();
%   ws.subscribe(tokenId, @(message) disp(message));
