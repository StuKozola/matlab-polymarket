function text = base64UrlEncode(bytes)
%BASE64URLENCODE Encode bytes as unpadded base64url text.
text = string(matlab.net.base64encode(uint8(bytes)));
text = erase(text, "=");
text = strrep(text, "+", "-");
text = strrep(text, "/", "_");
end
