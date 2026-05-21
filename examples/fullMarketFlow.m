%% Discover a market, resolve token IDs, and fetch CLOB prices.
addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

gamma = polymarket.GammaClient();
clob = polymarket.ClobClient();

markets = gamma.listMarkets("limit", 5, "active", true, "closed", false);
summary = polymarket.marketTable(markets);
disp(summary(:, ["id", "slug", "question", "clobTokenIds"]));

tokenIds = polymarket.extractClobTokenIds(markets);
if isempty(tokenIds)
    error("No CLOB token IDs were found in the returned markets.");
end

tokenId = tokenIds(1);
book = clob.getBook(tokenId);
bookTables = polymarket.orderBookTables(book);
midpoint = clob.getMidpoint(tokenId);

disp(bookTables.metadata);
disp(bookTables.bids(1:min(height(bookTables.bids), 5), :));
disp(bookTables.asks(1:min(height(bookTables.asks), 5), :));
disp(midpoint);

