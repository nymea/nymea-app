// SPDX-License-Identifier: GPL-3.0-or-later

#include <QtTest>

#include "platformintegration/ios/platformpermissionsiossettings.h"

class TestPlatformPermissionsIOSSettings : public QObject
{
    Q_OBJECT

private slots:
    void init();
    void defaultsToNotDetermined();
    void migratesLegacySetupMarker();
    void readsPersistedStatus();
    void ignoresInvalidPersistedStatus();

private:
    QSettings settings() const;

    QTemporaryDir m_temporaryDirectory;
};

QSettings TestPlatformPermissionsIOSSettings::settings() const
{
    return QSettings(m_temporaryDirectory.filePath("settings.ini"), QSettings::IniFormat);
}

void TestPlatformPermissionsIOSSettings::init()
{
    auto testSettings = settings();
    testSettings.clear();
}

void TestPlatformPermissionsIOSSettings::defaultsToNotDetermined()
{
    const auto state = PlatformPermissionsIOSSettings::localNetworkPermissionState(settings());

    QCOMPARE(static_cast<int>(state.status), static_cast<int>(PlatformPermissions::PermissionStatusNotDetermined));
    QVERIFY(!state.needsNativeRevalidation);
}

void TestPlatformPermissionsIOSSettings::migratesLegacySetupMarker()
{
    auto testSettings = settings();
    testSettings.setValue("askedForLocalNetworkPermission", true);

    const auto state = PlatformPermissionsIOSSettings::localNetworkPermissionState(testSettings);
    QCOMPARE(static_cast<int>(state.status), static_cast<int>(PlatformPermissions::PermissionStatusGranted));
    QVERIFY(state.needsNativeRevalidation);
}

void TestPlatformPermissionsIOSSettings::readsPersistedStatus()
{
    auto testSettings = settings();
    PlatformPermissionsIOSSettings::setLocalNetworkPermissionStatus(testSettings, PlatformPermissions::PermissionStatusDenied);

    const auto state = PlatformPermissionsIOSSettings::localNetworkPermissionState(testSettings);
    QCOMPARE(static_cast<int>(state.status), static_cast<int>(PlatformPermissions::PermissionStatusDenied));
    QVERIFY(!state.needsNativeRevalidation);
}

void TestPlatformPermissionsIOSSettings::ignoresInvalidPersistedStatus()
{
    auto testSettings = settings();
    testSettings.setValue("localNetworkPermissionStatus", 42);

    const auto state = PlatformPermissionsIOSSettings::localNetworkPermissionState(testSettings);
    QCOMPARE(static_cast<int>(state.status), static_cast<int>(PlatformPermissions::PermissionStatusNotDetermined));
    QVERIFY(!state.needsNativeRevalidation);
}

QTEST_MAIN(TestPlatformPermissionsIOSSettings)

#include "tst_platformpermissionsiossettings.moc"
