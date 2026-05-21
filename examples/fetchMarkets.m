%% Fetch active Polymarket markets.
addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

gamma = polymarket.GammaClient("ReturnTables", true);
markets = gamma.listMarkets("limit", 10, "active", true);
disp(markets);

