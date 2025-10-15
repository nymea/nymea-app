/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2025, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
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
    return 0;
}

int PlatformHelper::bottomPadding() const
{
    return 0;
}

int PlatformHelper::leftPadding() const
{
    return 0;
}

int PlatformHelper::rightPadding() const
{
    return 0;
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
