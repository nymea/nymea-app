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

#include "serverdebugmanager.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcServerDebug, "ServerDebug")

ServerDebugManager::ServerDebugManager(QObject *parent)
    : QObject{parent},
    m_categories{new ServerLoggingCategories(this)}
{
    qRegisterMetaType<ServerLoggingCategory*>("ServerLoggingCategory");
}

ServerDebugManager::~ServerDebugManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

Engine *ServerDebugManager::engine() const
{
    return m_engine;
}

void ServerDebugManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {

        if (m_engine)
            m_engine->jsonRpcClient()->unregisterNotificationHandler(this);

        m_engine = engine;
        emit engineChanged();

        init();
    }
}

ServerLoggingCategories *ServerDebugManager::categories() const
{
    return m_categories;
}

bool ServerDebugManager::fetchingData() const
{
    return m_fetchingData;
}

void ServerDebugManager::getLoggingCategories()
{
    if (!m_engine)
        return;

    m_engine->jsonRpcClient()->sendCommand("Debug.GetLoggingCategories", this, "getLoggingCategoriesResponse");
}

void ServerDebugManager::setLoggingLevel(const QString &name, int level)
{
    if (!m_engine)
        return;

    QVariantMap params;
    params.insert("name", name);
    switch (level) {
    case ServerLoggingCategory::LevelCritical:
        params.insert("level", "LoggingLevelCritical");
        break;
    case ServerLoggingCategory::LevelWarning:
        params.insert("level", "LoggingLevelWarning");
        break;
    case ServerLoggingCategory::LevelInfo:
        params.insert("level", "LoggingLevelInfo");
        break;
    case ServerLoggingCategory::LevelDebug:
        params.insert("level", "LoggingLevelDebug");
        break;
    }

    m_engine->jsonRpcClient()->sendCommand("Debug.SetLoggingCategoryLevel", params, this, "setLoggingCategoryLevelResponse");
}

void ServerDebugManager::notificationReceived(const QVariantMap &notification)
{
    qCDebug(dcServerDebug()) << "Notification received" << notification;
}

void ServerDebugManager::init()
{
    m_fetchingData = true;
    emit fetchingDataChanged();

    if (m_engine)
        m_engine->jsonRpcClient()->registerNotificationHandler(this, "Debug", "notificationReceived");

    getLoggingCategories();
}

void ServerDebugManager::getLoggingCategoriesResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    QVariantList categories = params.value("loggingCategories").toList();
    m_categories->createFromVariantList(categories);

    // foreach (const QVariant &categoryVariant, categories) {
    //     QVariantMap categoryMap = categoryVariant.toMap();
    //     qCDebug(dcServerDebug()) << categoryMap.value("name").toString() << categoryMap.value("level").toString() << categoryMap.value("type").toString();
    // }

    m_fetchingData = false;
    emit fetchingDataChanged();
}

void ServerDebugManager::setLoggingCategoryLevelResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcServerDebug()) << "Response for setting logging level" << params;
}
