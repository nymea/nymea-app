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

#include "pluginconfigmanager.h"

PluginConfigManager::PluginConfigManager(QObject *parent)
    : QObject{parent}
{
    m_params = new Params(this);
}

Engine *PluginConfigManager::engine() const
{
    return m_engine;
}

void PluginConfigManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        if (m_engine) {
            m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
        }

        m_engine = engine;
        emit engineChanged();

        if (m_engine) {
            m_engine->jsonRpcClient()->registerNotificationHandler(this, "ThingManager", "notificationReceived");

            if (m_plugin) {
                m_engine->jsonRpcClient()->sendCommand("Integrations.GetPluginConfiguration", {{"pluginId", m_plugin->pluginId()}}, this, "getPluginConfigResponse");
            }
        }
    }
}

Plugin *PluginConfigManager::plugin() const
{
    return m_plugin;
}

void PluginConfigManager::setPlugin(Plugin *plugin)
{
    if (m_plugin != plugin) {
        m_plugin = plugin;
        emit pluginChanged();

        if (m_plugin && m_engine) {
            m_engine->jsonRpcClient()->sendCommand("Integrations.GetPluginConfiguration", {{"pluginId", m_plugin->pluginId()}}, this, "getPluginConfigResponse");
        }
    }
}

Params *PluginConfigManager::params()
{
    return m_params;
}

void PluginConfigManager::getPluginConfigResponse(int /*commandId*/, const QVariantMap &params)
{
    qCWarning(dcThingManager) << "plugin config response" << params;
    m_params->clearModel();

    QVariantList pluginParams = params.value("configuration").toList();
    foreach (const QVariant &paramVariant, pluginParams) {
        Param* param = new Param();
        param->setParamTypeId(paramVariant.toMap().value("paramTypeId").toString());
        param->setValue(paramVariant.toMap().value("value"));
        m_params->addParam(param);
    }
}

int PluginConfigManager::savePluginConfig()
{
    QVariantMap params;
    params.insert("pluginId", m_plugin->pluginId());
    QVariantList pluginParams;
    for (int i = 0; i < m_params->rowCount(); i++) {
        pluginParams.append(QVariantMap{{"paramTypeId", m_params->get(i)->paramTypeId()}, {"value", m_params->get(i)->value()}});
    }
    params.insert("configuration", pluginParams);
    return m_engine->jsonRpcClient()->sendCommand("Integrations.SetPluginConfiguration", params, this, "setPluginConfigResponse");
}
