// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "appdata.h"

#include "engine.h"

#include <QMetaProperty>

#include "config.h"
#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcAppData, "AppData")

AppData::AppData(QObject *parent) : QObject(parent)
{
    m_syncTimer.setSingleShot(true);
    connect(&m_syncTimer, &QTimer::timeout, this, &AppData::store);
}

AppData::~AppData()
{
    if (m_engine && m_syncTimer.isActive()) {
        store();
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

void AppData::classBegin()
{
    for (int i = 0; i < metaObject()->propertyCount(); i++) {
        qCDebug(dcAppData) << "ClassBegin property:" << metaObject()->property(i).name();
    }
}

void AppData::componentComplete()
{
    // setup change notifications
    for (int i = metaObject()->propertyOffset(); i < metaObject()->propertyCount(); i++) {
        QMetaProperty prop = metaObject()->property(i);
        if (prop.hasNotifySignal()) {
            static const int propertyChangedIndex = metaObject()->indexOfSlot("onPropertyChanged()");
            QMetaObject::connect(this, prop.notifySignalIndex(), this, propertyChangedIndex);
        }
    }

    load();
}

Engine *AppData::engine() const
{
    return m_engine;
}

void AppData::setEngine(Engine *engine)
{
    if (m_engine == engine) {
        return;
    }

    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }

    m_engine = engine;

    if (m_engine) {
        m_engine->jsonRpcClient()->registerNotificationHandler(this, "AppData", "notificationReceived");
    }
    emit engineChanged();
}

QString AppData::group() const
{
    return m_group;
}

void AppData::setGroup(const QString &group)
{
    if (m_group != group) {
        if (m_syncTimer.isActive()) {
            m_syncTimer.stop();
            store();
        }
        m_group = group;
        load();
    }
}

void AppData::load()
{
    if (!m_engine) {
        return;
    }

    for (int i = metaObject()->propertyOffset(); i < metaObject()->propertyCount(); i++) {
        QMetaProperty prop = metaObject()->property(i);
        qCDebug(dcAppData) << "ComponentComplete property:" << prop.name() << prop.isUser() << prop.type() << prop.isScriptable();
        QVariantMap params;
        params.insert("appId", APPLICATION_NAME);
        if (!m_group.isEmpty()) {
            params.insert("group", m_group);
        }
        params.insert("key", prop.name());
        int id = m_engine->jsonRpcClient()->sendCommand("AppData.Load", params, this, "appDataReceived");
        m_readRequests.insert(id, prop.name());

    }
}

void AppData::store()
{
    if (!m_engine) {
        return;
    }

    for (int i = metaObject()->propertyOffset(); i < metaObject()->propertyCount(); i++) {
        QMetaProperty prop = metaObject()->property(i);
        QVariantMap params;
        params.insert("appId", APPLICATION_NAME);
        params.insert("key", prop.name());
        if (!m_group.isEmpty()) {
            params.insert("group", m_group);
        }
        params.insert("value", prop.read(this));
        m_engine->jsonRpcClient()->sendCommand("AppData.Store", params, this, "appDataWritten");
    }

}

void AppData::onPropertyChanged()
{
    if (!m_loopLock) {
        m_syncTimer.start(500);
    }
}

void AppData::appDataReceived(int commandId, const QVariantMap &params)
{
    if (m_readRequests.contains(commandId)) {
        QString propName = m_readRequests.take(commandId);
        for (int i = metaObject()->propertyOffset(); i < metaObject()->propertyCount(); i++) {
            QMetaProperty prop = metaObject()->property(i);
            if (prop.name() == propName) {
                m_loopLock = true;
                prop.write(this, params.value("value").toString());
                m_loopLock = false;
                return;
            }
        }
        qCWarning(dcAppData()) << "Retrieved app data property does not exist" << propName;
    }
}

void AppData::appDataWritten(int commandId, const QVariantMap &params)
{
    qCDebug(dcAppData()) << "App data written:" << commandId << params;
}

void AppData::notificationReceived(const QVariantMap &notification)
{
    qCDebug(dcAppData()) << "AppData notification" << notification;
}
