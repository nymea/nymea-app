#!/bin/sh
set -eu

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <application-name> <app-version> <qml-dir> <package-dir> <codesign-identity>" >&2
    exit 2
fi

application_name=$1
app_version=$2
qml_dir=$3
package_dir=$4
codesign_identity=$5

qt_plugins_dir=$(qmake -query QT_INSTALL_PLUGINS)
sql_mimer_driver="${qt_plugins_dir}/sqldrivers/libqsqlmimer.dylib"
hidden_sql_mimer_driver=""

restore_sql_mimer_driver()
{
    if [ -n "${hidden_sql_mimer_driver}" ] && [ -f "${hidden_sql_mimer_driver}" ]; then
        mv "${hidden_sql_mimer_driver}" "${sql_mimer_driver}"
    fi
}

trap restore_sql_mimer_driver EXIT HUP INT TERM

rm -f ../*.dmg ../*pkg ./*.dmg
hdiutil eject "/Volumes/${application_name}" || true

# The app does not use QtSql. Hide the optional Mimer SQL driver while running
# macdeployqt so it does not scan a plugin with a missing client library.
if [ -f "${sql_mimer_driver}" ]; then
    hidden_sql_mimer_driver="${sql_mimer_driver}.${application_name}.$$"
    mv "${sql_mimer_driver}" "${hidden_sql_mimer_driver}"
fi

macdeployqt "${application_name}.app" -appstore-compliant -qmldir="${qml_dir}" -dmg
restore_sql_mimer_driver
trap - EXIT HUP INT TERM

rm -rf "${application_name}.app/Contents/Frameworks/QtWebEngineCore.framework"
codesign --force -s "${codesign_identity}" --verbose --entitlements "${package_dir}/${application_name}.entitlements" --deep "${application_name}.app"
hdiutil convert "${application_name}.dmg" -format UDRW -o "${application_name}_writable.dmg"
hdiutil attach -readwrite -noverify -nobrowse -noautoopen "${application_name}_writable.dmg"
sleep 2
rm -f "/Volumes/${application_name}/.DS_Store"
tar -xpf "${package_dir}/template.tar" -C "/Volumes/${application_name}/"
sync
hdiutil eject "/Volumes/${application_name}"
hdiutil convert "${application_name}_writable.dmg" -format UDRO -o "../${application_name}-osx-bundle-${app_version}.dmg"
rm "${application_name}.dmg" "${application_name}_writable.dmg"
