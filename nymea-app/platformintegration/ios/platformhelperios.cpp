#include "platformhelperios.h"
#include <QDebug>
#include <QUuid>

PlatformHelperIOS::PlatformHelperIOS(QObject *parent) : PlatformHelper(parent)
{

}

void PlatformHelperIOS::requestPermissions()
{
    emit permissionsRequestFinished();
}

bool PlatformHelperIOS::hasPermissions() const
{
    return true;
}

QString PlatformHelperIOS::machineHostname() const
{
    return QSysInfo::machineHostName();
}

QString PlatformHelperIOS::deviceSerial() const
{
    // There is no way on iOS to get to a persistent serial number of the device.
    // We're not interested tracking users or the actual serials anyways but we want
    // something that is persistent across app installations. So let's generate a UUID
    // ourselves and store that in the keychain.
    QString deviceId = const_cast<PlatformHelperIOS*>(this)->readKeyChainEntry("io.guh.nymea-app", "deviceId");
    qDebug() << "read keychain value:" << deviceId;
    if (deviceId.isEmpty()) {
        deviceId = QUuid::createUuid().toString();
        const_cast<PlatformHelperIOS*>(this)->writeKeyChainEntry("io.guh.nymea-app", "deviceId", deviceId);
    }
    qDebug() << "Returning device ID" << deviceId;
    return deviceId;
}

QString PlatformHelperIOS::deviceModel() const
{
    return QSysInfo::prettyProductName();
}

QString PlatformHelperIOS::deviceManufacturer() const
{
    return QString("iPhone");
}

void PlatformHelperIOS::vibrate(PlatformHelper::HapticsFeedback feedbackType)
{
    switch (feedbackType) {
    case HapticsFeedbackSelection:
        generateSelectionFeedback();
        break;
    case HapticsFeedbackImpact:
        generateImpactFeedback();
        break;
    case HapticsFeedbackNotification:
        generateNotificationFeedback();
        break;
    }
}

