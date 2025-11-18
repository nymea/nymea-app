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

#include "platformhelperubports.h"


#include <QSettings>
#include <QUuid>
#include <QUrl>
#include <QUrlQuery>
#include <QDBusConnection>
#include <QDebug>
#include <QCoreApplication>


PlatformHelperUBPorts::PlatformHelperUBPorts(QObject *parent):
    PlatformHelper(parent),
    m_uriHandlerObject(this)
{
    setupUriHandler();
}

QString PlatformHelperUBPorts::platform() const
{
    return "ubports";
}

QString PlatformHelperUBPorts::deviceSerial() const
{
    QSettings s;
    if (!s.contains("deviceSerial")) {
        s.setValue("deviceSerial", QUuid::createUuid());
    }
    return s.value("deviceSerial").toString();
}

void PlatformHelperUBPorts::setupUriHandler()
{
    QString objectPath = QStringLiteral("/");

    if (!QDBusConnection::sessionBus().isConnected()) {
        qWarning() << "UCUriHandler: D-Bus session bus is not connected, ignoring.";
        return;
    }

    // Get the object path based on the "APP_ID" environment variable.
    QByteArray applicationId = qgetenv("APP_ID");
    if (applicationId.isEmpty()) {
        qWarning() << "UCUriHandler: Empty \"APP_ID\" environment variable, ignoring.";
        return;
    }

    // Convert applicationID into usable dbus object path
    for (int i = 0; i < applicationId.size(); ++i) {
        QChar ch = applicationId.at(i);
        if (ch.isLetterOrNumber()) {
            objectPath += ch;
        } else {
            objectPath += QString::asprintf("_%02x", ch.toLatin1());
        }
    }

    // Ensure handler is running on the main thread.
    QCoreApplication* instance = QCoreApplication::instance();
    if (instance) {
        moveToThread(instance->thread());
    } else {
        qWarning() << "UCUriHandler: Created before QCoreApplication, application may misbehave.";
    }

    QDBusConnection::sessionBus().registerObject(
        objectPath, &m_uriHandlerObject, QDBusConnection::ExportAllSlots);
}

UriHandlerObject::UriHandlerObject(PlatformHelper *platformHelper):
    m_platformHelper(platformHelper)
{
}

void UriHandlerObject::Open(const QStringList& uris, const QHash<QString, QVariant>& platformData)
{
    Q_UNUSED(platformData);
    foreach (const QString &uri, uris) {
        if (uri.startsWith("nymea://notification")) {
            m_platformHelper->notificationActionReceived(QUrlQuery(QUrl(uri)).queryItemValue("nymeaData"));
        }
    }
}
