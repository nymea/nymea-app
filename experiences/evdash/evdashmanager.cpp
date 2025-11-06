// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "evdashmanager.h"

#include <QMetaEnum>

#include <logging.h>

NYMEA_LOGGING_CATEGORY(dcEvDashExperience, "EvDashExperience")

EvDashManager::EvDashManager(QObject *parent)
    :QObject{parent},
    m_users{new EvDashUsers(this)}
{

}

EvDashManager::~EvDashManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

EvDashUsers *EvDashManager::users() const
{
    return m_users;
}

Engine *EvDashManager::engine() const
{
    return m_engine;
}

void EvDashManager::setEngine(Engine *engine)
{
    if (m_engine == engine)
        return;

    if (m_engine)
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);

    m_engine = engine;
    emit engineChanged();

    if (m_engine) {
        connect(engine, &Engine::destroyed, this, [engine, this]{ if (m_engine == engine) m_engine = nullptr; });

        m_engine->jsonRpcClient()->registerNotificationHandler(this, "EvDash", "notificationReceived");
        m_engine->jsonRpcClient()->sendCommand("EvDash.GetEnabled", QVariantMap(), this, "getEnabledResponse");
        m_engine->jsonRpcClient()->sendCommand("EvDash.GetUsers", QVariantMap(), this, "getUsersResponse");
    }
}

bool EvDashManager::enabled() const
{
    return m_enabled;
}

int EvDashManager::setEnabled(bool enabled)
{
    QVariantMap params;
    params.insert("enabled", enabled);
    return m_engine->jsonRpcClient()->sendCommand("EvDash.SetEnabled", params, this, "setEnabledResponse");
}

int EvDashManager::addUser(const QString &username, const QString &password)
{
    QVariantMap params;
    params.insert("username", username);
    params.insert("password", password);
    return m_engine->jsonRpcClient()->sendCommand("EvDash.AddUser", params, this, "addUserResponse");
}

int EvDashManager::removeUser(const QString &username)
{
    QVariantMap params;
    params.insert("username", username);
    return m_engine->jsonRpcClient()->sendCommand("EvDash.RemoveUser", params, this, "removeUserResponse");
}

void EvDashManager::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();

    if (notification == "EvDash.EnabledChanged") {
        bool enabled = params.value("enabled").toBool();
        if (m_enabled != enabled) {
            m_enabled = enabled;
            emit enabledChanged();
        }
    } else if (notification == "EvDash.UserAdded") {
        m_users->addUser(params.value("username").toString());
    } else if (notification == "EvDash.UserRemoved") {
        m_users->removeUser(params.value("username").toString());
    } else {
        qCDebug(dcEvDashExperience()) << "Unhandled notification received" << data;
    }
}

void EvDashManager::getEnabledResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcEvDashExperience()) << "Response for GetEnabled request" << commandId << params;

    bool enabled = params.value("enabled").toBool();
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
    }
}

void EvDashManager::setEnabledResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcEvDashExperience()) << "Response for SetEnabled request" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<EvDashError>();
    EvDashError error = static_cast<EvDashError>(metaEnum.keyToValue(params.value("evDashError").toByteArray().data()));
    emit setEnabledReply(commandId, error);
}

void EvDashManager::getUsersResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcEvDashExperience()) << "Response for GetEnabled request" << commandId << params;
    m_users->setUsers(params.value("usernames").toStringList());
}

void EvDashManager::addUserResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcEvDashExperience()) << "Response for AddUser request" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<EvDashError>();
    EvDashError error = static_cast<EvDashError>(metaEnum.keyToValue(params.value("evDashError").toByteArray().data()));
    emit addUserReply(commandId, error);
}

void EvDashManager::removeUserResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcEvDashExperience()) << "Response for RemoveUser request" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<EvDashError>();
    EvDashError error = static_cast<EvDashError>(metaEnum.keyToValue(params.value("evDashError").toByteArray().data()));
    emit removeUserReply(commandId, error);
}


