%% Stream CLOB market updates.
% Requires tools/buildJavaHelper.m to have produced lib/polymarket-java-helper.jar.
addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

tokenId = getenv("POLYMARKET_EXAMPLE_TOKEN_ID");
if strlength(string(tokenId)) == 0
    error("Set POLYMARKET_EXAMPLE_TOKEN_ID before running this example.");
end

ws = polymarket.WebSocketClient.market();
cleanup = onCleanup(@() ws.close());
ws.subscribe(tokenId, @(message) disp(message));
pause(30);

