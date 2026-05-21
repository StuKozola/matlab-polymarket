classdef SignatureType
    %SIGNATURETYPE Polymarket CLOB signature type constants.

    properties (Constant)
        EOA = 0
        POLY_PROXY = 1
        GNOSIS_SAFE = 2
        POLY_1271 = 3
    end

    methods (Static)
        function value = parse(input)
            %PARSE Convert a numeric or textual signature type to an integer.
            if nargin == 0 || isempty(input)
                value = polymarket.SignatureType.POLY_1271;
                return
            end

            if isnumeric(input) || islogical(input)
                value = double(input);
                return
            end

            text = upper(strrep(string(input), "-", "_"));
            switch text
                case "EOA"
                    value = polymarket.SignatureType.EOA;
                case "POLY_PROXY"
                    value = polymarket.SignatureType.POLY_PROXY;
                case "GNOSIS_SAFE"
                    value = polymarket.SignatureType.GNOSIS_SAFE;
                case "POLY_1271"
                    value = polymarket.SignatureType.POLY_1271;
                otherwise
                    error("polymarket:InvalidSignatureType", ...
                        "Unsupported signature type: %s", string(input));
            end
        end
    end
end

