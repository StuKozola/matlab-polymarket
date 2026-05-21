# Repository Guidelines

## Project Structure & Module Organization

This workspace currently has no committed source tree. As code is added, keep MATLAB source files under `src/`, tests under `tests/`, runnable examples under `examples/`, and small static assets or fixtures under `assets/` or `tests/fixtures/`. Keep generated outputs, downloaded market data, logs, and temporary analysis artifacts out of source control unless they are intentional test fixtures.

Use package folders such as `+polymarket/` when the project grows beyond a few standalone functions. Prefer small, single-purpose functions over large scripts; scripts should mainly live in `examples/` or `scripts/`.

## Build, Test, and Development Commands

- `matlab -batch "addpath('src'); runtests('tests')"`: run the MATLAB test suite from a clean session.
- `matlab -batch "checkcode('src','-cyc')"`: run MATLAB static analysis on source files.
- `matlab -batch "run('examples/example_name.m')"`: execute a specific example script.

If the project later adds a `buildfile.m`, prefer `matlab -batch "buildtool test"` as the standard test entry point and document new tasks here.

## Coding Style & Naming Conventions

Use 4-space indentation for MATLAB files. Name functions and variables in `lowerCamelCase`, classes in `UpperCamelCase`, constants in descriptive uppercase only when truly constant, and test files as `test*.m` or `*Test.m`. Match the primary function name to its filename.

Avoid hidden global state. Pass configuration, API clients, and file paths explicitly. Keep public functions documented with a short H1 line and concise input/output notes.

## Testing Guidelines

Use `matlab.unittest` for automated tests. Place unit tests in `tests/` and mirror the source area being tested where practical, for example `tests/testPriceParsing.m` for `src/+polymarket/parsePrices.m`. Tests that require network access or credentials should be clearly named and skipped by default unless the required environment variable is present.

## Commit & Pull Request Guidelines

No repository Git history is available yet. Use short, imperative commit subjects such as `Add market parser tests` or `Refactor API client configuration`. Keep unrelated changes in separate commits.

Pull requests should include a concise description, the commands run for verification, any required configuration or credentials, and screenshots or sample output when behavior changes are user-visible.

## Security & Configuration Tips

Do not commit API keys, `.env` files, raw credentials, or large downloaded datasets. Store local secrets in environment variables and document required variable names without exposing values.
