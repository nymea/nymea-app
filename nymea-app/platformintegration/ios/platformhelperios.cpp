// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "platformhelperios.h"
#include <QDebug>
#include <QHash>
#include <QUuid>
#include <QScreen>
#include <QApplication>
#include <QSysInfo>
#include <QTimer>
#include <QWindow>
#include <QtWebView>
#include <QtGlobal>
#include <sys/utsname.h>

static QString deviceModelForMachineIdentifier(const QString &identifier)
{
    static const QHash<QString, QString> mapping = {
        {QStringLiteral("iPhone1,1"), QStringLiteral("iPhone")},
        {QStringLiteral("iPhone1,2"), QStringLiteral("iPhone 3G")},
        {QStringLiteral("iPhone2,1"), QStringLiteral("iPhone 3GS")},
        {QStringLiteral("iPhone3,1"), QStringLiteral("iPhone 4")},
        {QStringLiteral("iPhone3,2"), QStringLiteral("iPhone 4")},
        {QStringLiteral("iPhone3,3"), QStringLiteral("iPhone 4")},
        {QStringLiteral("iPhone4,1"), QStringLiteral("iPhone 4S")},
        {QStringLiteral("iPhone5,1"), QStringLiteral("iPhone 5")},
        {QStringLiteral("iPhone5,2"), QStringLiteral("iPhone 5")},
        {QStringLiteral("iPhone5,3"), QStringLiteral("iPhone 5c")},
        {QStringLiteral("iPhone5,4"), QStringLiteral("iPhone 5c")},
        {QStringLiteral("iPhone6,1"), QStringLiteral("iPhone 5s")},
        {QStringLiteral("iPhone6,2"), QStringLiteral("iPhone 5s")},
        {QStringLiteral("iPhone7,1"), QStringLiteral("iPhone 6 Plus")},
        {QStringLiteral("iPhone7,2"), QStringLiteral("iPhone 6")},
        {QStringLiteral("iPhone8,1"), QStringLiteral("iPhone 6s")},
        {QStringLiteral("iPhone8,2"), QStringLiteral("iPhone 6s Plus")},
        {QStringLiteral("iPhone8,4"), QStringLiteral("iPhone SE (1st generation)")},
        {QStringLiteral("iPhone9,1"), QStringLiteral("iPhone 7")},
        {QStringLiteral("iPhone9,2"), QStringLiteral("iPhone 7 Plus")},
        {QStringLiteral("iPhone9,3"), QStringLiteral("iPhone 7")},
        {QStringLiteral("iPhone9,4"), QStringLiteral("iPhone 7 Plus")},
        {QStringLiteral("iPhone10,1"), QStringLiteral("iPhone 8")},
        {QStringLiteral("iPhone10,2"), QStringLiteral("iPhone 8 Plus")},
        {QStringLiteral("iPhone10,3"), QStringLiteral("iPhone X")},
        {QStringLiteral("iPhone10,4"), QStringLiteral("iPhone 8")},
        {QStringLiteral("iPhone10,5"), QStringLiteral("iPhone 8 Plus")},
        {QStringLiteral("iPhone10,6"), QStringLiteral("iPhone X")},
        {QStringLiteral("iPhone11,2"), QStringLiteral("iPhone XS")},
        {QStringLiteral("iPhone11,4"), QStringLiteral("iPhone XS Max")},
        {QStringLiteral("iPhone11,6"), QStringLiteral("iPhone XS Max")},
        {QStringLiteral("iPhone11,8"), QStringLiteral("iPhone XR")},
        {QStringLiteral("iPhone12,1"), QStringLiteral("iPhone 11")},
        {QStringLiteral("iPhone12,3"), QStringLiteral("iPhone 11 Pro")},
        {QStringLiteral("iPhone12,5"), QStringLiteral("iPhone 11 Pro Max")},
        {QStringLiteral("iPhone12,8"), QStringLiteral("iPhone SE (2nd generation)")},
        {QStringLiteral("iPhone13,1"), QStringLiteral("iPhone 12 mini")},
        {QStringLiteral("iPhone13,2"), QStringLiteral("iPhone 12")},
        {QStringLiteral("iPhone13,3"), QStringLiteral("iPhone 12 Pro")},
        {QStringLiteral("iPhone13,4"), QStringLiteral("iPhone 12 Pro Max")},
        {QStringLiteral("iPhone14,2"), QStringLiteral("iPhone 13 Pro")},
        {QStringLiteral("iPhone14,3"), QStringLiteral("iPhone 13 Pro Max")},
        {QStringLiteral("iPhone14,4"), QStringLiteral("iPhone 13 mini")},
        {QStringLiteral("iPhone14,5"), QStringLiteral("iPhone 13")},
        {QStringLiteral("iPhone14,6"), QStringLiteral("iPhone SE (3rd generation)")},

        {QStringLiteral("iPhone14,7"), QStringLiteral("iPhone 14")},
        {QStringLiteral("iPhone14,8"), QStringLiteral("iPhone 14 Plus")},
        {QStringLiteral("iPhone15,2"), QStringLiteral("iPhone 14 Pro")},
        {QStringLiteral("iPhone15,3"), QStringLiteral("iPhone 14 Pro Max")},

        {QStringLiteral("iPhone15,4"), QStringLiteral("iPhone 15")},
        {QStringLiteral("iPhone15,5"), QStringLiteral("iPhone 15 Plus")},
        {QStringLiteral("iPhone16,1"), QStringLiteral("iPhone 15 Pro")},
        {QStringLiteral("iPhone16,2"), QStringLiteral("iPhone 15 Pro Max")},

        {QStringLiteral("iPhone17,1"), QStringLiteral("iPhone 16 Pro")},
        {QStringLiteral("iPhone17,2"), QStringLiteral("iPhone 16 Pro Max")},
        {QStringLiteral("iPhone17,3"), QStringLiteral("iPhone 16")},
        {QStringLiteral("iPhone17,4"), QStringLiteral("iPhone 16 Plus")},

        {QStringLiteral("iPad1,1"), QStringLiteral("iPad (1st generation)")},
        {QStringLiteral("iPad2,1"), QStringLiteral("iPad (2nd generation)")},
        {QStringLiteral("iPad2,2"), QStringLiteral("iPad (2nd generation)")},
        {QStringLiteral("iPad2,3"), QStringLiteral("iPad (2nd generation)")},
        {QStringLiteral("iPad2,4"), QStringLiteral("iPad (2nd generation)")},
        {QStringLiteral("iPad2,5"), QStringLiteral("iPad mini (1st generation)")},
        {QStringLiteral("iPad2,6"), QStringLiteral("iPad mini (1st generation)")},
        {QStringLiteral("iPad2,7"), QStringLiteral("iPad mini (1st generation)")},
        {QStringLiteral("iPad3,1"), QStringLiteral("iPad (3rd generation)")},
        {QStringLiteral("iPad3,2"), QStringLiteral("iPad (3rd generation)")},
        {QStringLiteral("iPad3,3"), QStringLiteral("iPad (3rd generation)")},
        {QStringLiteral("iPad3,4"), QStringLiteral("iPad (4th generation)")},
        {QStringLiteral("iPad3,5"), QStringLiteral("iPad (4th generation)")},
        {QStringLiteral("iPad3,6"), QStringLiteral("iPad (4th generation)")},
        {QStringLiteral("iPad4,1"), QStringLiteral("iPad Air (1st generation)")},
        {QStringLiteral("iPad4,2"), QStringLiteral("iPad Air (1st generation)")},
        {QStringLiteral("iPad4,3"), QStringLiteral("iPad Air (1st generation)")},
        {QStringLiteral("iPad4,4"), QStringLiteral("iPad mini (2nd generation)")},
        {QStringLiteral("iPad4,5"), QStringLiteral("iPad mini (2nd generation)")},
        {QStringLiteral("iPad4,6"), QStringLiteral("iPad mini (2nd generation)")},
        {QStringLiteral("iPad4,7"), QStringLiteral("iPad mini (3rd generation)")},
        {QStringLiteral("iPad4,8"), QStringLiteral("iPad mini (3rd generation)")},
        {QStringLiteral("iPad4,9"), QStringLiteral("iPad mini (3rd generation)")},
        {QStringLiteral("iPad5,1"), QStringLiteral("iPad mini (4th generation)")},
        {QStringLiteral("iPad5,2"), QStringLiteral("iPad mini (4th generation)")},
        {QStringLiteral("iPad5,3"), QStringLiteral("iPad Air (2nd generation)")},
        {QStringLiteral("iPad5,4"), QStringLiteral("iPad Air (2nd generation)")},
        {QStringLiteral("iPad6,3"), QStringLiteral("iPad Pro (9.7-inch)")},
        {QStringLiteral("iPad6,4"), QStringLiteral("iPad Pro (9.7-inch)")},
        {QStringLiteral("iPad6,7"), QStringLiteral("iPad Pro (12.9-inch) (1st generation)")},
        {QStringLiteral("iPad6,8"), QStringLiteral("iPad Pro (12.9-inch) (1st generation)")},
        {QStringLiteral("iPad6,11"), QStringLiteral("iPad (5th generation)")},
        {QStringLiteral("iPad6,12"), QStringLiteral("iPad (5th generation)")},
        {QStringLiteral("iPad7,1"), QStringLiteral("iPad Pro (12.9-inch) (2nd generation)")},
        {QStringLiteral("iPad7,2"), QStringLiteral("iPad Pro (12.9-inch) (2nd generation)")},
        {QStringLiteral("iPad7,3"), QStringLiteral("iPad Pro (10.5-inch)")},
        {QStringLiteral("iPad7,4"), QStringLiteral("iPad Pro (10.5-inch)")},
        {QStringLiteral("iPad7,5"), QStringLiteral("iPad (6th generation)")},
        {QStringLiteral("iPad7,6"), QStringLiteral("iPad (6th generation)")},
        {QStringLiteral("iPad7,11"), QStringLiteral("iPad (7th generation)")},
        {QStringLiteral("iPad7,12"), QStringLiteral("iPad (7th generation)")},
        {QStringLiteral("iPad8,1"), QStringLiteral("iPad Pro (11-inch) (1st generation)")},
        {QStringLiteral("iPad8,2"), QStringLiteral("iPad Pro (11-inch) (1st generation)")},
        {QStringLiteral("iPad8,3"), QStringLiteral("iPad Pro (11-inch) (1st generation)")},
        {QStringLiteral("iPad8,4"), QStringLiteral("iPad Pro (11-inch) (1st generation)")},
        {QStringLiteral("iPad8,5"), QStringLiteral("iPad Pro (12.9-inch) (3rd generation)")},
        {QStringLiteral("iPad8,6"), QStringLiteral("iPad Pro (12.9-inch) (3rd generation)")},
        {QStringLiteral("iPad8,7"), QStringLiteral("iPad Pro (12.9-inch) (3rd generation)")},
        {QStringLiteral("iPad8,8"), QStringLiteral("iPad Pro (12.9-inch) (3rd generation)")},
        {QStringLiteral("iPad8,9"), QStringLiteral("iPad Pro (11-inch) (2nd generation)")},
        {QStringLiteral("iPad8,10"), QStringLiteral("iPad Pro (11-inch) (2nd generation)")},
        {QStringLiteral("iPad8,11"), QStringLiteral("iPad Pro (12.9-inch) (4th generation)")},
        {QStringLiteral("iPad8,12"), QStringLiteral("iPad Pro (12.9-inch) (4th generation)")},
        {QStringLiteral("iPad11,1"), QStringLiteral("iPad mini (5th generation)")},
        {QStringLiteral("iPad11,2"), QStringLiteral("iPad mini (5th generation)")},
        {QStringLiteral("iPad11,3"), QStringLiteral("iPad Air (3rd generation)")},
        {QStringLiteral("iPad11,4"), QStringLiteral("iPad Air (3rd generation)")},
        {QStringLiteral("iPad11,6"), QStringLiteral("iPad (8th generation)")},
        {QStringLiteral("iPad11,7"), QStringLiteral("iPad (8th generation)")},
        {QStringLiteral("iPad12,1"), QStringLiteral("iPad (9th generation)")},
        {QStringLiteral("iPad12,2"), QStringLiteral("iPad (9th generation)")},
        {QStringLiteral("iPad13,1"), QStringLiteral("iPad Air (4th generation)")},
        {QStringLiteral("iPad13,2"), QStringLiteral("iPad Air (4th generation)")},
        {QStringLiteral("iPad13,4"), QStringLiteral("iPad Pro (11-inch) (3rd generation)")},
        {QStringLiteral("iPad13,5"), QStringLiteral("iPad Pro (11-inch) (3rd generation)")},
        {QStringLiteral("iPad13,6"), QStringLiteral("iPad Pro (11-inch) (3rd generation)")},
        {QStringLiteral("iPad13,7"), QStringLiteral("iPad Pro (11-inch) (3rd generation)")},
        {QStringLiteral("iPad13,8"), QStringLiteral("iPad Pro (12.9-inch) (5th generation)")},
        {QStringLiteral("iPad13,9"), QStringLiteral("iPad Pro (12.9-inch) (5th generation)")},
        {QStringLiteral("iPad13,10"), QStringLiteral("iPad Pro (12.9-inch) (5th generation)")},
        {QStringLiteral("iPad13,11"), QStringLiteral("iPad Pro (12.9-inch) (5th generation)")},
        {QStringLiteral("iPad13,16"), QStringLiteral("iPad Air (5th generation)")},
        {QStringLiteral("iPad13,17"), QStringLiteral("iPad Air (5th generation)")},
        {QStringLiteral("iPad13,18"), QStringLiteral("iPad (10th generation)")},
        {QStringLiteral("iPad13,19"), QStringLiteral("iPad (10th generation)")},
        {QStringLiteral("iPad14,1"), QStringLiteral("iPad mini (6th generation)")},
        {QStringLiteral("iPad14,2"), QStringLiteral("iPad mini (6th generation)")},
        {QStringLiteral("iPad14,3"), QStringLiteral("iPad Pro (11-inch) (4th generation)")},
        {QStringLiteral("iPad14,4"), QStringLiteral("iPad Pro (11-inch) (4th generation)")},
        {QStringLiteral("iPad14,5"), QStringLiteral("iPad Pro (12.9-inch) (6th generation)")},
        {QStringLiteral("iPad14,6"), QStringLiteral("iPad Pro (12.9-inch) (6th generation)")},
        {QStringLiteral("iPad14,8"), QStringLiteral("iPad Air (11-inch) (6th generation)")},
        {QStringLiteral("iPad14,9"), QStringLiteral("iPad Air (11-inch) (6th generation)")},
        {QStringLiteral("iPad14,10"), QStringLiteral("iPad Air (13-inch) (6th generation)")},
        {QStringLiteral("iPad14,11"), QStringLiteral("iPad Air (13-inch) (6th generation)")},
        {QStringLiteral("iPad16,3"), QStringLiteral("iPad Pro (11-inch) (M4)")},
        {QStringLiteral("iPad16,4"), QStringLiteral("iPad Pro (11-inch) (M4)")},
        {QStringLiteral("iPad16,5"), QStringLiteral("iPad Pro (13-inch) (M4)")},
        {QStringLiteral("iPad16,6"), QStringLiteral("iPad Pro (13-inch) (M4)")},
    };

    return mapping.value(identifier);
}

PlatformHelperIOS::PlatformHelperIOS(QObject *parent) : PlatformHelper(parent)
{
    QtWebView::initialize();

    QScreen *screen = qApp->primaryScreen();
    //screen->setOrientationUpdateMask(Qt::PortraitOrientation | Qt::LandscapeOrientation | Qt::InvertedPortraitOrientation | Qt::InvertedLandscapeOrientation);
    QObject::connect(screen, &QScreen::orientationChanged, qApp, [this](Qt::ScreenOrientation) {
        applyPanelColors();
    });
    QObject::connect(screen, &QScreen::availableGeometryChanged, qApp, [this](const QRect &) {
        applyPanelColors();
    });
    QObject::connect(qApp, &QGuiApplication::focusWindowChanged, this, [this](QWindow *) {
        QTimer::singleShot(0, this, &PlatformHelperIOS::applyPanelColors);
    });
    QObject::connect(qApp, &QGuiApplication::applicationStateChanged, this, [this](Qt::ApplicationState state) {
        if (state == Qt::ApplicationActive) {
            QTimer::singleShot(0, this, &PlatformHelperIOS::applyPanelColors);
        }
    });
    QTimer::singleShot(0, this, &PlatformHelperIOS::applyPanelColors);
}

void PlatformHelperIOS::hideSplashScreen()
{
    // Nothing to be done
}

QString PlatformHelperIOS::machineHostname() const
{
    const QString hostName = QSysInfo::machineHostName();
    if (!hostName.isEmpty() && hostName != "localhost") {
        return hostName;
    }


    // Fall back to something user visible when the OS only reports "localhost".
    const QString model = deviceModel();
    const QString manufacturer = deviceManufacturer();
    if (model.isEmpty()) {
        return manufacturer;
    }
    if (manufacturer.isEmpty() || model.startsWith(manufacturer)) {
        return model;
    }

    return manufacturer + " " + model;
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
    struct utsname systemInfo;
    if (uname(&systemInfo) == 0) {
        const QString machine = QString::fromUtf8(systemInfo.machine);
        if (!machine.isEmpty()) {
            if (machine == "i386" || machine == "x86_64" || machine == "arm64") {
                const QByteArray simulatorIdentifier = qgetenv("SIMULATOR_MODEL_IDENTIFIER");
                if (!simulatorIdentifier.isEmpty()) {
                    const QString simulatorMachine = QString::fromUtf8(simulatorIdentifier);
                    const QString simulatorModel = deviceModelForMachineIdentifier(simulatorMachine);
                    if (!simulatorModel.isEmpty()) {
                        return simulatorModel;
                    }
                    return simulatorMachine;
                }
                return QStringLiteral("Simulator");
            }

            const QString model = deviceModelForMachineIdentifier(machine);
            if (!model.isEmpty()) {
                return model;
            }
            return machine;
        }
    }

    return QSysInfo::prettyProductName();
}

QString PlatformHelperIOS::deviceManufacturer() const
{
    return QStringLiteral("Apple");
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

void PlatformHelperIOS::applyPanelColors()
{
    setTopPanelColor(topPanelColor());
    setBottomPanelColor(bottomPanelColor());
    updateSafeAreaPadding();
}
