function signature = hmacSha256Base64Url(secret, message)
%HMACSHA256BASE64URL Compute a base64url HMAC-SHA256 signature.
keyBytes = polymarket.internal.base64UrlDecode(secret);
messageBytes = unicode2native(char(message), "UTF-8");

mac = javax.crypto.Mac.getInstance("HmacSHA256");
keySpec = javax.crypto.spec.SecretKeySpec(typecast(uint8(keyBytes), "int8"), "HmacSHA256");
mac.init(keySpec);
digest = mac.doFinal(typecast(uint8(messageBytes), "int8"));
signature = polymarket.internal.base64UrlEncode(typecast(digest, "uint8"));
end

