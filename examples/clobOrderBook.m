%% Fetch a CLOB order book.
% Set tokenId to an active CLOB token ID from a Gamma market.
addpath(fullfile(fileparts(fileparts(mfilename("fullpath"))), "src"));

tokenId = getenv("POLYMARKET_EXAMPLE_TOKEN_ID");
if strlength(string(tokenId)) == 0
    error("Set POLYMARKET_EXAMPLE_TOKEN_ID before running this example.");
end

clob = polymarket.ClobClient();
book = clob.getBook(tokenId);
disp(book);

