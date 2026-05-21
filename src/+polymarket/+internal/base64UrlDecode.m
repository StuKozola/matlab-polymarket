function bytes = base64UrlDecode(text)
%BASE64URLDECODE Decode base64url text into uint8 bytes.
text = char(string(text));
text = strrep(text, '-', '+');
text = strrep(text, '_', '/');
padding = mod(4 - mod(strlength(string(text)), 4), 4);
text = [text repmat('=', 1, padding)];
bytes = matlab.net.base64decode(char(text));
end
