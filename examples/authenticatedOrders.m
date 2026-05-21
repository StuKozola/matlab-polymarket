%% List authenticated CLOB orders.
% Requires POLY_ADDRESS, POLY_API_KEY, POLY_SECRET, and POLY_PASSPHRASE.
addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

auth = polymarket.AuthConfig.fromEnvironment();
if ~auth.hasL2Credentials()
    error("Set POLY_ADDRESS, POLY_API_KEY, POLY_SECRET, and POLY_PASSPHRASE.");
end

clob = polymarket.ClobClient("Auth", auth);
orders = clob.getOrders();
disp(orders);

