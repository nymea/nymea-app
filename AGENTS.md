# Repository Guidelines

## Project Structure & Module Organization
`nymea-app/` holds the QtQuick entry point plus top-level QML, and `libnymea-app/` supplies shared C++ helpers, models, and logging categories. Feature bundles reside in `experiences/`, which should stay self-contained with QML, assets, and translations. Vendored code lives in `3rdParty/` and `QtZeroConf/`. Tests sit inside `tests/testrunner/` (unit) and `tests/integration/` (scenario). Packaging and store metadata are in `packaging/`, `snap/`, `debian/`, and `fastlane/`; edit them only when coordinating a release.

## Build, Test, and Development Commands
After cloning, run `git submodule update --init --recursive`. Configure with `cmake -S . -B build -DNYMEA_ENABLE_ZEROCONF=ON` and build via `cmake --build build --target nymea-app -j$(nproc)`. Execute the suite with `cmake --build build --target test` or `ctest --test-dir build --output-on-failure`. Qt Creator users can rely on `qmake nymea-app.pro CONFIG+=withtests && make`. Re-run `messages.sh` whenever you touch translations.

## Coding Style & Naming Conventions
Use Qt’s 4-space indentation, braces on new lines, and PascalCase for types (`DashboardModel`) with lowerCamelCase members (`defaultStyle`). Order includes as Qt, nymea, then local headers, and prefer `NYMEA_LOGGING_CATEGORY` over raw `qDebug`. In QML, match filenames to the exported component, avoid wildcard imports, and keep property names lowerCamelCase.

## Testing Guidelines
Add Qt Test cases under `tests/testrunner/` following the module path (e.g., `tests/testrunner/dashboard/tst_dashboard.cpp`) and use descriptive names such as `shouldConnectOnValidCredentials`. Integration flows belong to `tests/integration/` and may drive nymead or device simulators. Every functional PR needs at least one automated test plus a screenshot for UI changes. Run `ctest --test-dir build -V` before requesting review and document any skipped cases.

## Commit & Pull Request Guidelines
Commits should have concise, imperative subjects like “Fix Android packaging target configuration” plus a short body covering motivation, toggles, and tests. Pull requests must describe the issue solved, summarize design choices, link related issues, and attach test evidence (command snippets, screenshots, or APK links). Tag reviewers responsible for touched areas and keep changes scoped to a single feature or bugfix.

## Security & Configuration Tips
Store secrets in local environment files, never in git. Update `config.h.in` or `config.pri` when adding switches and document the defaults in the PR. Android builds download OpenSSL during configuration, so ensure CI nodes have first-run network access or cache the package internally. Call out any new runtime permissions so reviewers can test them explicitly.
