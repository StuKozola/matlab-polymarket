# MATLAB Polymarket Toolbox

MATLAB client toolbox for the Polymarket APIs documented at
https://docs.polymarket.com/api-reference/introduction.

This repository contains MATLAB package classes for the Gamma, Data, CLOB,
Bridge, Relayer, and WebSocket APIs, plus a programmatic toolbox packaging
script.

## Quick Start

```matlab
addpath("src")

gamma = polymarket.GammaClient();
markets = gamma.listMarkets("limit", 10);

clob = polymarket.ClobClient();
serverTime = clob.getTime();
```

Authenticated CLOB calls can use environment variables, a local `.env` file,
or MATLAB Vault secrets. The same names are used for all three sources:

```text
POLY_ADDRESS
POLY_API_KEY
POLY_SECRET
POLY_PASSPHRASE
POLY_SIGNATURE_TYPE
POLY_FUNDER
```

```matlab
auth = polymarket.AuthConfig.fromEnvironment();
clob = polymarket.ClobClient("Auth", auth);
orders = clob.getOrders();
```

Source precedence is environment variables, `.env`, then MATLAB Vault. Store
Vault secrets with names such as `POLY_API_KEY` and retrieve them with:

```matlab
auth = polymarket.AuthConfig.fromVault();
```

Create a `.env` file from `.env.example` for local development:

```matlab
auth = polymarket.AuthConfig.fromDotEnv(".env");
```

L2 API-key authentication is implemented in MATLAB. For EIP-712 signing,
either set `AuthConfig.L1Signer`/`AuthConfig.OrderSigner` callbacks or install
the official Python SDK and use the optional bridge:

```matlab
sdk = polymarket.PythonClobSdk("Auth", auth);
creds = sdk.createOrDeriveApiKey();
```

WebSockets require a Java helper JAR:

```matlab
run("tools/buildJavaHelper.m")
```

That script requires a JDK with `javac` and `jar` on PATH, or tool paths in
`POLYMARKET_JAVAC` and `POLYMARKET_JAR`.

## Package

Requires MATLAB R2023a or later for `matlab.addons.toolbox.ToolboxOptions`.

```matlab
run("tools/packageToolbox.m")
```

The package is written to `release/Polymarket.mltbx`.

The build tool provides the same automation:

```matlab
buildtool test check package
```

Use `examples/fullMarketFlow.m` for a complete public data flow:
market discovery, CLOB token extraction, order book conversion, and midpoint
lookup.

## Verify

```matlab
addpath("src")
runtests("tests")
checkcode("src","-cyc")
```

Network and credentialed examples are skipped unless the required environment
variables are configured.

Live integration tests are skipped by default:

```matlab
setenv("POLYMARKET_RUN_INTEGRATION", "true")
buildtool integration
```

Trading E2E is a separate explicit opt-in. It uses the official Python SDK
bridge for EIP-712 signing, posts a post-only tiny limit order, and cancels it:

```matlab
run("tools/installPythonSdk.m")
setenv("POLYMARKET_RUN_INTEGRATION", "true")
setenv("POLYMARKET_RUN_TRADING_E2E", "true")
setenv("POLYMARKET_TRADING_TOKEN_ID", "<token id>")
setenv("POLYMARKET_TRADING_PRICE", "0.01")
setenv("POLYMARKET_TRADING_SIZE", "1")
setenv("POLYMARKET_TRADING_MAX_NOTIONAL", "1")
buildtool trading
```

See `doc/SigningStrategy.m` and `doc/LiveTesting.m` for details.

For GitHub Actions live runs, configure the same names as repository secrets
and start the `CI` workflow manually with `run-integration=true`.
