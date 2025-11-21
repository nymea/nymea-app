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
#include <QUuid>
#include <QScreen>
#include <QApplication>
#include <QTimer>
#include <QWindow>
#include <QtWebView>

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

void PlatformHelperIOS::applyPanelColors()
{
    setTopPanelColor(topPanelColor());
    setBottomPanelColor(bottomPanelColor());
    updateSafeAreaPadding();
}
