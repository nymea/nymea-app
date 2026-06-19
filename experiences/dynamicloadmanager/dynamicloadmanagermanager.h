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

#ifndef DYNAMICLOADMANAGERMANAGER_H
#define DYNAMICLOADMANAGERMANAGER_H

#include <QObject>
#include <QVariantMap>
#include <engine.h>

#include "dynamicloadmanagernodes.h"

class DynamicLoadManagerManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int revision READ revision NOTIFY revisionChanged)
    Q_PROPERTY(QVariantMap configuration READ configuration NOTIFY configurationChanged)
    Q_PROPERTY(QVariantMap status READ status NOTIFY statusChanged)
    Q_PROPERTY(DynamicLoadManagerNodes *nodes READ nodes CONSTANT FINAL)

public:
    enum DynamicLoadManagerError {
        DynamicLoadManagerErrorNoError,
        DynamicLoadManagerErrorInvalidParameter,
        DynamicLoadManagerErrorValidationFailed,
        DynamicLoadManagerErrorRevisionConflict,
        DynamicLoadManagerErrorPersistenceFailed,
        DynamicLoadManagerErrorNodeNotFound,
        DynamicLoadManagerErrorInvalidOperation,
        DynamicLoadManagerErrorNotImplemented
    };
    Q_ENUM(DynamicLoadManagerError)

    explicit DynamicLoadManagerManager(QObject *parent = nullptr);
    ~DynamicLoadManagerManager();

    Engine* engine() const;
    void setEngine(Engine *engine);

    bool enabled() const;
    int setEnabled(bool enabled);

    int revision() const;
    QVariantMap configuration() const;
    QVariantMap status() const;
    DynamicLoadManagerNodes *nodes() const;

    Q_INVOKABLE int setConfiguration(const QVariantMap &configuration);
    Q_INVOKABLE int addNode(const QVariantMap &node, const QString &parentNodeId = QString(), int childIndex = -1);
    Q_INVOKABLE int updateNode(const QString &nodeId, const QVariantMap &patch);
    Q_INVOKABLE int moveNode(const QString &nodeId, const QString &parentNodeId, int childIndex = -1);
    Q_INVOKABLE int removeNode(const QString &nodeId);
    Q_INVOKABLE int setFuseLimitOverride(const QString &nodeId, const QVariantMap &limit, int ttlSeconds);
    Q_INVOKABLE int clearFuseLimitOverride(const QString &nodeId);
    Q_INVOKABLE int resetFaults();
    Q_INVOKABLE int triggerRecalculation();

signals:
    void engineChanged();
    void enabledChanged();
    void revisionChanged();
    void configurationChanged();
    void statusChanged();

    void setConfigurationReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void setEnabledReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void addNodeReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void updateNodeReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void moveNodeReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void removeNodeReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void setFuseLimitOverrideReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void clearFuseLimitOverrideReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void resetFaultsReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);
    void triggerRecalculationReply(int commandId, DynamicLoadManagerManager::DynamicLoadManagerError error, const QVariantList &issues);

private slots:
    void notificationReceived(const QVariantMap &data);

    void getConfigurationResponse(int commandId, const QVariantMap &params);
    void getStatusResponse(int commandId, const QVariantMap &params);

    void setConfigurationResponse(int commandId, const QVariantMap &params);
    void setEnabledResponse(int commandId, const QVariantMap &params);
    void addNodeResponse(int commandId, const QVariantMap &params);
    void updateNodeResponse(int commandId, const QVariantMap &params);
    void moveNodeResponse(int commandId, const QVariantMap &params);
    void removeNodeResponse(int commandId, const QVariantMap &params);
    void setFuseLimitOverrideResponse(int commandId, const QVariantMap &params);
    void clearFuseLimitOverrideResponse(int commandId, const QVariantMap &params);
    void resetFaultsResponse(int commandId, const QVariantMap &params);
    void triggerRecalculationResponse(int commandId, const QVariantMap &params);

private:
    static DynamicLoadManagerError parseError(const QVariantMap &params);
    void addExpectedRevision(QVariantMap &params) const;

    void setConfigurationInternal(const QVariantMap &configuration, int revision);
    void setStatusInternal(const QVariantMap &status);
    void rebuildNodesModel();
    static void collectNames(const QVariantMap &node, QHash<QString, QString> &names);

    Engine *m_engine = nullptr;
    bool m_enabled = false;
    int m_revision = -1;
    QVariantMap m_configuration;
    QVariantMap m_status;
    DynamicLoadManagerNodes *m_nodes = nullptr;
};

#endif // DYNAMICLOADMANAGERMANAGER_H
