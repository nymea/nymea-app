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

QString PlatformHelperIOS::deviceSerial() const
{
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
    qDebug() << "SYSINFO:" << QSysInfo::productType() << QSysInfo::prettyProductName() << QSysInfo::productVersion();
    return QSysInfo::prettyProductName();
}

QString PlatformHelperIOS::deviceManufacturer() const
{
    return QString("iPhone");
}
