#!/usr/bin/env bash

set -euo pipefail

identity="$1"
input_pkg="$2"
output_pkg="$3"

if ! productsign -s "${identity}" "${input_pkg}" "${output_pkg}"; then
    echo "Failed to sign ${input_pkg} with installer identity: ${identity}" >&2
    echo "If this happens on CI, verify that the keychain is unlocked and the private key allows non-interactive product signing." >&2
    echo "Typical CI fix:" >&2
    echo "  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k <keychain-password> <keychain>" >&2
    exit 1
fi
