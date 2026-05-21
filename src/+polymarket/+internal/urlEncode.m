function encoded = urlEncode(value)
%URLENCODE Percent-encode a query string component.
encoded = string(java.net.URLEncoder.encode(char(string(value)), "UTF-8"));
encoded = strrep(encoded, "+", "%20");
end

