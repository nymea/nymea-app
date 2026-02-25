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

#include "platformhelper.h"

#include <QApplication>
#include <QClipboard>
#include <QDesktopServices>
#include <QUrl>
#include <QUrlQuery>
#include <QJsonDocument>

#if defined Q_OS_ANDROID
#include "platformintegration/android/platformhelperandroid.h"
#elif defined Q_OS_IOS
#include "platformintegration/ios/platformhelperios.h"
#elif defined UBPORTS
#include "platformintegration/ubports/platformhelperubports.h"
#else
#include "platformintegration/generic/platformhelpergeneric.h"
#endif

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcPlatformIntegration, "PlatformIntegration")

PlatformHelper* PlatformHelper::s_instance = nullptr;

PlatformHelper::PlatformHelper(QObject *parent) : QObject(parent)
{

}

void PlatformHelper::notificationActionReceived(const QString &nymeaData)
{
    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(nymeaData.toUtf8(), &error);
    if (error.error != QJsonParseError::NoError) {
        qCWarning(dcPlatformIntegration()) << "Received a notification action but cannot parse it:" << error.errorString() << nymeaData;
        return;
    }

    qCDebug(dcPlatformIntegration()) << "Received notification action data" << nymeaData;
    QVariantMap map = jsonDoc.toVariant().toMap();
    QUuid id = QUuid::createUuid();
    map.insert("id", id);

    // transforming data from a url query to a map for easier processing in QML
    QUrlQuery query(map.value("data").toString());
    QVariantMap dataMap;
    for (int i = 0; i < query.queryItems().count(); i++) {
        QPair<QString, QString> item = query.queryItems().at(i);
        dataMap.insert(item.first, item.second);
    }
    map.insert("dataMap", dataMap);

    m_pendingNotificationActions.insert(id, map);
    emit pendingNotificationActionsChanged();
}

PlatformHelper *PlatformHelper::instance(bool create)
{
    if (!s_instance && create) {
#ifdef Q_OS_ANDROID
        s_instance = new PlatformHelperAndroid();
#elif defined(Q_OS_IOS)
        s_instance = new PlatformHelperIOS();
#elif defined UBPORTS
        s_instance = new PlatformHelperUBPorts();
#else
        s_instance = new PlatformHelperGeneric();
#endif
    }
    return s_instance;
}

void PlatformHelper::hideSplashScreen()
{
    setSplashVisible(false);
}


QString PlatformHelper::platform() const
{
    return QSysInfo::productType();
}

QString PlatformHelper::machineHostname() const
{
    return QSysInfo::machineHostName();
}

QString PlatformHelper::device() const
{
    return QSysInfo::prettyProductName();
}

QString PlatformHelper::deviceSerial() const
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 11, 0)
    return QSysInfo::machineUniqueId();
#else
    return "1234567890";
#endif
}

QString PlatformHelper::deviceModel() const
{
    return QSysInfo::prettyProductName();
}

QString PlatformHelper::deviceManufacturer() const
{
    return QSysInfo::productType();
}

bool PlatformHelper::canControlScreen() const
{
    return false;
}

int PlatformHelper::screenTimeout() const
{
    return 0;
}

void PlatformHelper::setScreenTimeout(int screenTimeout)
{
    Q_UNUSED(screenTimeout)
}

int PlatformHelper::screenBrightness() const
{
    return 0;
}

void PlatformHelper::setScreenBrightness(int percent)
{
    Q_UNUSED(percent)
}

QColor PlatformHelper::topPanelColor() const
{
    return m_topPanelColor;
}

void PlatformHelper::setTopPanelColor(const QColor &color)
{
    if (m_topPanelColor != color) {
        m_topPanelColor = color;
        emit topPanelColorChanged();
    }
}

QColor PlatformHelper::bottomPanelColor() const
{
    return m_bottomPanelColor;
}

void PlatformHelper::setBottomPanelColor(const QColor &color)
{
    if (m_bottomPanelColor != color) {
        m_bottomPanelColor = color;
        emit bottomPanelColorChanged();
    }
}

int PlatformHelper::topPadding() const
{
    return m_topPadding;
}

int PlatformHelper::bottomPadding() const
{
    return m_bottomPadding;
}

int PlatformHelper::leftPadding() const
{
    return m_leftPadding;
}

int PlatformHelper::rightPadding() const
{
    return m_rightPadding;
}

bool PlatformHelper::darkModeEnabled() const
{
    return false;
}

QVariantList PlatformHelper::pendingNotificationActions() const
{
    return m_pendingNotificationActions.values();
}

void PlatformHelper::notificationActionHandled(const QUuid &id)
{
    m_pendingNotificationActions.remove(id);
    emit pendingNotificationActionsChanged();
}

bool PlatformHelper::splashVisible() const
{
    return m_splashVisible;
}

void PlatformHelper::setSplashVisible(bool splashVisible)
{
    if (m_splashVisible != splashVisible) {
        m_splashVisible = splashVisible;
        emit splashVisibleChanged();
    }
}

void PlatformHelper::vibrate(PlatformHelper::HapticsFeedback feedbackType)
{
    Q_UNUSED(feedbackType)
}

void PlatformHelper::setSafeAreaPadding(int top, int right, int bottom, int left)
{
    bool changed = false;
    if (m_topPadding != top) {
        m_topPadding = top;
        changed = true;
        emit topPaddingChanged();
    }
    if (m_rightPadding != right) {
        m_rightPadding = right;
        changed = true;
        emit rightPaddingChanged();
    }
    if (m_bottomPadding != bottom) {
        m_bottomPadding = bottom;
        changed = true;
        emit bottomPaddingChanged();
    }
    if (m_leftPadding != left) {
        m_leftPadding = left;
        changed = true;
        emit leftPaddingChanged();
    }
    Q_UNUSED(changed)
}

void PlatformHelper::toClipBoard(const QString &text)
{
    QApplication::clipboard()->setText(text);
}

QString PlatformHelper::fromClipBoard()
{
    return QApplication::clipboard()->text();
}

void PlatformHelper::shareFile(const QString &fileName)
{
    QDesktopServices::openUrl(QUrl(fileName));
}

bool PlatformHelper::locationServicesEnabled() const
{
    return true;
}

QObject *PlatformHelper::platformHelperProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return instance();
}
