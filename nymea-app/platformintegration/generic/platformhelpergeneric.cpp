#include "platformhelpergeneric.h"

PlatformHelperGeneric::PlatformHelperGeneric(QObject *parent) : PlatformHelper(parent)
{
    m_piHelper = new RaspberryPiHelper(this);
}

void PlatformHelperGeneric::requestPermissions()
{
    emit permissionsRequestFinished();
}

void PlatformHelperGeneric::hideSplashScreen()
{

}

bool PlatformHelperGeneric::hasPermissions() const
{
    return true;
}

QString PlatformHelperGeneric::machineHostname() const
{
    return QSysInfo::machineHostName();
}

QString PlatformHelperGeneric::device() const
{
    return QSysInfo::prettyProductName();
}

QString PlatformHelperGeneric::deviceSerial() const
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 11, 0)
    return QSysInfo::machineUniqueId();
#else
    return "1234567890";
#endif
}

QString PlatformHelperGeneric::deviceModel() const
{
    return QSysInfo::prettyProductName();
}

QString PlatformHelperGeneric::deviceManufacturer() const
{
    return QSysInfo::productType();
}

bool PlatformHelperGeneric::canControlScreen() const
{
    return m_piHelper->active();
}

int PlatformHelperGeneric::screenTimeout() const
{
    return m_piHelper->screenTimeout();
}

void PlatformHelperGeneric::setScreenTimeout(int timeout)
{
    if (m_piHelper->screenTimeout() != timeout) {
        m_piHelper->setScreenTimeout(timeout);
        emit screenTimeoutChanged();
    }
}

void PlatformHelperGeneric::vibrate(PlatformHelper::HapticsFeedback feedbyckType)
{
    Q_UNUSED(feedbyckType)
}
