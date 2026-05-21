classdef testAuthConfig < matlab.unittest.TestCase
    %TESTAUTHCONFIG Tests for credential source handling.

    methods (TestMethodSetup)
        function clearPolymarketEnvironment(testCase)
            names = ["POLY_ADDRESS", "POLY_API_KEY", "POLY_SECRET", ...
                "POLY_PASSPHRASE", "POLY_PRIVATE_KEY", ...
                "POLY_SIGNATURE_TYPE", "POLY_FUNDER"];
            for i = 1:numel(names)
                oldValue = getenv(names(i));
                testCase.addTeardown(@() setenv(names(i), oldValue));
                setenv(names(i), "");
            end
        end
    end

    methods (Test)
        function fromDotEnvLoadsCredentials(testCase)
            fileName = fullfile(tempdir, "polymarket-test.env");
            fid = fopen(fileName, "w");
            testCase.addTeardown(@() delete(fileName));
            cleanup = onCleanup(@() fclose(fid));
            fprintf(fid, "POLY_ADDRESS=0xabc\n");
            fprintf(fid, "POLY_API_KEY=api-key\n");
            fprintf(fid, "POLY_SECRET=""secret value""\n");
            fprintf(fid, "POLY_PASSPHRASE='pass phrase'\n");
            fprintf(fid, "POLY_SIGNATURE_TYPE=EOA\n");
            clear cleanup

            auth = polymarket.AuthConfig.fromDotEnv(fileName);

            testCase.verifyEqual(auth.Address, "0xabc");
            testCase.verifyEqual(auth.ApiKey, "api-key");
            testCase.verifyEqual(auth.Secret, "secret value");
            testCase.verifyEqual(auth.Passphrase, "pass phrase");
            testCase.verifyEqual(auth.SignatureType, polymarket.SignatureType.EOA);
        end

        function environmentOverridesDotEnv(testCase)
            fileName = fullfile(tempdir, "polymarket-test-env-precedence.env");
            writelines(["POLY_ADDRESS=0xfromfile"; "POLY_API_KEY=file-key"], fileName);
            testCase.addTeardown(@() delete(fileName));
            setenv("POLY_ADDRESS", "0xfromenv");

            auth = polymarket.AuthConfig.fromEnvironment( ...
                "DotEnvFile", fileName, "UseVault", false);

            testCase.verifyEqual(auth.Address, "0xfromenv");
            testCase.verifyEqual(auth.ApiKey, "file-key");
        end

        function fromDotEnvIgnoresEnvironment(testCase)
            fileName = fullfile(tempdir, "polymarket-test-dotenv-only.env");
            writelines("POLY_ADDRESS=0xfromfile", fileName);
            testCase.addTeardown(@() delete(fileName));
            setenv("POLY_ADDRESS", "0xfromenv");

            auth = polymarket.AuthConfig.fromDotEnv(fileName);

            testCase.verifyEqual(auth.Address, "0xfromfile");
        end

        function vaultProviderSuppliesMissingCredentials(testCase)
            secrets = containers.Map( ...
                ["POLY_ADDRESS", "POLY_API_KEY", "POLY_SECRET", "POLY_PASSPHRASE"], ...
                ["0xvault", "vault-key", "vault-secret", "vault-pass"]);
            provider = @(name) localSecretProvider(secrets, name);

            auth = polymarket.AuthConfig.fromVault("SecretProvider", provider);

            testCase.verifyEqual(auth.Address, "0xvault");
            testCase.verifyEqual(auth.ApiKey, "vault-key");
            testCase.verifyEqual(auth.Secret, "vault-secret");
            testCase.verifyEqual(auth.Passphrase, "vault-pass");
        end
    end
end

function value = localSecretProvider(secrets, name)
if isKey(secrets, char(name))
    value = secrets(char(name));
else
    value = "";
end
end
