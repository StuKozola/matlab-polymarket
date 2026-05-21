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

Authenticated CLOB calls use environment variables by default:

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

L2 API-key authentication is implemented in MATLAB. L1 API-key creation and
order signing require an explicit signer callback on `AuthConfig` so private-key
handling can stay outside the toolbox boundary unless a project opts in.

WebSockets require a Java helper JAR:

```matlab
run("tools/buildJavaHelper.m")
```

That script requires a JDK with `javac` and `jar` on PATH.

## Package

Requires MATLAB R2023a or later for `matlab.addons.toolbox.ToolboxOptions`.

```matlab
run("tools/packageToolbox.m")
```

The package is written to `release/Polymarket.mltbx`.

## Verify

```matlab
addpath("src")
runtests("tests")
checkcode("src","-cyc")
```

Network and credentialed examples are skipped unless the required environment
variables are configured.
