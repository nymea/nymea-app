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

#include "dynamicloadmanagermanager.h"

#include <QMetaEnum>

#include <logging.h>

NYMEA_LOGGING_CATEGORY(dcDynamicLoadManagerExperience, "DynamicLoadManagerExperience")

DynamicLoadManagerManager::DynamicLoadManagerManager(QObject *parent)
    : QObject{parent},
    m_nodes{new DynamicLoadManagerNodes(this)}
{

}

DynamicLoadManagerManager::~DynamicLoadManagerManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

Engine *DynamicLoadManagerManager::engine() const
{
    return m_engine;
}

void DynamicLoadManagerManager::setEngine(Engine *engine)
{
    if (m_engine == engine)
        return;

    if (m_engine)
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);

    m_engine = engine;
    emit engineChanged();

    if (m_engine) {
        connect(engine, &Engine::destroyed, this, [engine, this]{ if (m_engine == engine) m_engine = nullptr; });

        m_engine->jsonRpcClient()->registerNotificationHandler(this, "DynamicLoadManager", "notificationReceived");
        m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.GetConfiguration", QVariantMap(), this, "getConfigurationResponse");
        m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.GetStatus", QVariantMap(), this, "getStatusResponse");
    }
}

bool DynamicLoadManagerManager::enabled() const
{
    return m_enabled;
}

int DynamicLoadManagerManager::setEnabled(bool enabled)
{
    QVariantMap params;
    params.insert("enabled", enabled);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.SetEnabled", params, this, "setEnabledResponse");
}

int DynamicLoadManagerManager::revision() const
{
    return m_revision;
}

QVariantMap DynamicLoadManagerManager::configuration() const
{
    return m_configuration;
}

QVariantMap DynamicLoadManagerManager::status() const
{
    return m_status;
}

DynamicLoadManagerNodes *DynamicLoadManagerManager::nodes() const
{
    return m_nodes;
}

int DynamicLoadManagerManager::setConfiguration(const QVariantMap &configuration)
{
    QVariantMap params;
    params.insert("configuration", configuration);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.SetConfiguration", params, this, "setConfigurationResponse");
}

int DynamicLoadManagerManager::addNode(const QVariantMap &node, const QString &parentNodeId, int childIndex)
{
    QVariantMap params;
    params.insert("node", node);
    if (!parentNodeId.isEmpty())
        params.insert("parentNodeId", parentNodeId);
    if (childIndex >= 0)
        params.insert("childIndex", childIndex);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.AddNode", params, this, "addNodeResponse");
}

int DynamicLoadManagerManager::updateNode(const QString &nodeId, const QVariantMap &patch)
{
    QVariantMap params;
    params.insert("nodeId", nodeId);
    params.insert("patch", patch);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.UpdateNode", params, this, "updateNodeResponse");
}

int DynamicLoadManagerManager::moveNode(const QString &nodeId, const QString &parentNodeId, int childIndex)
{
    QVariantMap params;
    params.insert("nodeId", nodeId);
    params.insert("parentNodeId", parentNodeId);
    if (childIndex >= 0)
        params.insert("childIndex", childIndex);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.MoveNode", params, this, "moveNodeResponse");
}

int DynamicLoadManagerManager::removeNode(const QString &nodeId)
{
    QVariantMap params;
    params.insert("nodeId", nodeId);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.RemoveNode", params, this, "removeNodeResponse");
}

int DynamicLoadManagerManager::setFuseLimitOverride(const QString &nodeId, const QVariantMap &limit, int ttlSeconds)
{
    QVariantMap params;
    params.insert("nodeId", nodeId);
    params.insert("limit", limit);
    params.insert("ttlSeconds", ttlSeconds);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.SetFuseLimitOverride", params, this, "setFuseLimitOverrideResponse");
}

int DynamicLoadManagerManager::clearFuseLimitOverride(const QString &nodeId)
{
    QVariantMap params;
    params.insert("nodeId", nodeId);
    addExpectedRevision(params);
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.ClearFuseLimitOverride", params, this, "clearFuseLimitOverrideResponse");
}

int DynamicLoadManagerManager::resetFaults()
{
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.ResetFaults", QVariantMap(), this, "resetFaultsResponse");
}

int DynamicLoadManagerManager::triggerRecalculation()
{
    return m_engine->jsonRpcClient()->sendCommand("DynamicLoadManager.TriggerRecalculation", QVariantMap(), this, "triggerRecalculationResponse");
}

void DynamicLoadManagerManager::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();

    if (notification == "DynamicLoadManager.ConfigurationChanged") {
        setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
    } else if (notification == "DynamicLoadManager.StatusChanged") {
        setStatusInternal(params.value("status").toMap());
    } else if (notification == "DynamicLoadManager.NodeFaultChanged") {
        QString nodeId = params.value("nodeId").toString();
        bool faulted = params.value("fault").toMap().value("faulted").toBool();
        m_nodes->setFaulted(nodeId, faulted);
    } else {
        qCDebug(dcDynamicLoadManagerExperience()) << "Unhandled notification received" << data;
    }
}

void DynamicLoadManagerManager::getConfigurationResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for GetConfiguration request" << commandId << params;
    setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
}

void DynamicLoadManagerManager::getStatusResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for GetStatus request" << commandId << params;
    setStatusInternal(params.value("status").toMap());
}

void DynamicLoadManagerManager::setConfigurationResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for SetConfiguration request" << commandId << params;
    if (params.contains("configuration"))
        setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
    emit setConfigurationReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::setEnabledResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for SetEnabled request" << commandId << params;
    if (params.contains("configuration"))
        setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
    emit setEnabledReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::addNodeResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for AddNode request" << commandId << params;
    if (params.contains("configuration"))
        setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
    emit addNodeReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::updateNodeResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for UpdateNode request" << commandId << params;
    if (params.contains("configuration"))
        setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
    emit updateNodeReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::moveNodeResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for MoveNode request" << commandId << params;
    if (params.contains("configuration"))
        setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
    emit moveNodeReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::removeNodeResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for RemoveNode request" << commandId << params;
    if (params.contains("configuration"))
        setConfigurationInternal(params.value("configuration").toMap(), params.value("revision").toInt());
    emit removeNodeReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::setFuseLimitOverrideResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for SetFuseLimitOverride request" << commandId << params;
    emit setFuseLimitOverrideReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::clearFuseLimitOverrideResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for ClearFuseLimitOverride request" << commandId << params;
    emit clearFuseLimitOverrideReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::resetFaultsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for ResetFaults request" << commandId << params;
    emit resetFaultsReply(commandId, parseError(params), params.value("issues").toList());
}

void DynamicLoadManagerManager::triggerRecalculationResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcDynamicLoadManagerExperience()) << "Response for TriggerRecalculation request" << commandId << params;
    emit triggerRecalculationReply(commandId, parseError(params), params.value("issues").toList());
}

DynamicLoadManagerManager::DynamicLoadManagerError DynamicLoadManagerManager::parseError(const QVariantMap &params)
{
    QMetaEnum metaEnum = QMetaEnum::fromType<DynamicLoadManagerError>();
    return static_cast<DynamicLoadManagerError>(metaEnum.keyToValue(params.value("dynamicLoadManagerError").toByteArray().data()));
}

void DynamicLoadManagerManager::addExpectedRevision(QVariantMap &params) const
{
    if (m_revision >= 0)
        params.insert("expectedRevision", m_revision);
}

void DynamicLoadManagerManager::setConfigurationInternal(const QVariantMap &configuration, int revision)
{
    if (m_configuration != configuration) {
        m_configuration = configuration;
        emit configurationChanged();

        bool enabled = configuration.value("enabled").toBool();
        if (m_enabled != enabled) {
            m_enabled = enabled;
            emit enabledChanged();
        }

        rebuildNodesModel();
    }

    if (m_revision != revision) {
        m_revision = revision;
        emit revisionChanged();
    }
}

void DynamicLoadManagerManager::setStatusInternal(const QVariantMap &status)
{
    if (m_status == status)
        return;

    m_status = status;
    emit statusChanged();
    rebuildNodesModel();
}

void DynamicLoadManagerManager::rebuildNodesModel()
{
    QHash<QString, QString> names;
    QVariantMap root = m_configuration.value("root").toMap();
    if (!root.isEmpty())
        collectNames(root, names);

    m_nodes->update(m_status.value("nodes").toMap(), names);
}

void DynamicLoadManagerManager::collectNames(const QVariantMap &node, QHash<QString, QString> &names)
{
    QString id = node.value("id").toString();
    if (!id.isEmpty())
        names.insert(id, node.value("displayName").toString());

    const QVariantList children = node.value("children").toList();
    for (const QVariant &child : children)
        collectNames(child.toMap(), names);
}
