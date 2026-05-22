#!/usr/bin/env bash

set -euo pipefail

app_bundle="$1"
qml_dir="$2"
qt_plugins_dir="$3"

mimer_plugin="${qt_plugins_dir}/sqldrivers/libqsqlmimer.dylib"
mimer_plugin_hidden="${mimer_plugin}.disabled-by-nymea"
webengine_framework="${app_bundle}/Contents/Frameworks/QtWebEngineCore.framework"

restore_mimer_plugin() {
    if [ -f "${mimer_plugin_hidden}" ]; then
        mv "${mimer_plugin_hidden}" "${mimer_plugin}"
    fi
}

trap restore_mimer_plugin EXIT

# Some Qt installs ship the Mimer SQL driver plugin with a dependency on a
# locally installed libmimerapi.dylib. The app does not use QtSql, but
# macdeployqt still scans the plugin and aborts if that library is missing.
if [ -f "${mimer_plugin}" ]; then
    mv "${mimer_plugin}" "${mimer_plugin_hidden}"
fi

macdeployqt "${app_bundle}" -appstore-compliant -qmldir="${qml_dir}" -dmg

# macdeployqt may no longer bundle QtWebEngineCore when the webengine-backed
# WebView plugin was skipped, so remove it only when present.
if [ -e "${webengine_framework}" ]; then
    rm -rf "${webengine_framework}"
fi
