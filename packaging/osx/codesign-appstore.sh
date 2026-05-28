#!/usr/bin/env bash

set -euo pipefail

app_bundle="$1"
identity="$2"
entitlements="$3"

sign_code() {
    local path="$1"

    if [ -e "${path}" ]; then
        codesign --force -s "${identity}" --verbose "${path}"
    fi
}

sign_found_code() {
    local root="$1"
    local pattern="$2"
    local type="$3"

    if [ -d "${root}" ]; then
        find "${root}" -type "${type}" -name "${pattern}" -print | sort -r | while IFS= read -r path; do
            sign_code "${path}"
        done
    fi
}

# Sign nested code first. The app entitlements belong to the top-level bundle;
# applying them through codesign --deep can fail on Qt plugins and frameworks.
sign_found_code "${app_bundle}/Contents" "*.dylib" f
sign_found_code "${app_bundle}/Contents" "*.so" f
sign_found_code "${app_bundle}/Contents/Frameworks" "*.framework" d
sign_found_code "${app_bundle}/Contents" "*.app" d

codesign --force -s "${identity}" --verbose --entitlements "${entitlements}" "${app_bundle}"
codesign --verify --strict --deep --verbose=2 "${app_bundle}"
