#include "platformhelperios.h"
#include <QDebug>
#include <QUuid>
#include <QScreen>
#include <QApplication>

PlatformHelperIOS::PlatformHelperIOS(QObject *parent) : PlatformHelper(parent)
{
    QScreen *screen = qApp->primaryScreen();
    screen->setOrientationUpdateMask(Qt::PortraitOrientation | Qt::LandscapeOrientation | Qt::InvertedPortraitOrientation | Qt::InvertedLandscapeOrientation);
    QObject::connect(screen, &QScreen::orientationChanged, qApp, [this](Qt::ScreenOrientation) {
        setBottomPanelColor(bottomPanelColor());
    });

}

void PlatformHelperIOS::requestPermissions()
{
    emit permissionsRequestFinished();
}

void PlatformHelperIOS::hideSplashScreen()
{
    // Nothing to be done
}

bool PlatformHelperIOS::hasPermissions() const
{
    return true;
}

QString PlatformHelperIOS::machineHostname() const
{
    return QSysInfo::machineHostName();
}

QString PlatformHelperIOS::device() const
{
    return deviceModel();
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

void PlatformHelperIOS::setTopPanelColor(const QColor &color)
{
    PlatformHelper::setTopPanelColor(color);
    setTopPanelColorInternal(color);
}

void PlatformHelperIOS::setBottomPanelColor(const QColor &color)
{
    PlatformHelper::setBottomPanelColor(color);

    // In landscape, ignore settings and keep it to black. On notched devices it'll look crap otherwise
    if (qApp->primaryScreen()->orientation() == Qt::LandscapeOrientation || qApp->primaryScreen()->orientation() == Qt::InvertedLandscapeOrientation) {
        setBottomPanelColorInternal(QColor("black"));
    } else {
        setBottomPanelColorInternal(color);
    }

}

