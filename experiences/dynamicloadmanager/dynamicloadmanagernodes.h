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

#ifndef DYNAMICLOADMANAGERNODES_H
#define DYNAMICLOADMANAGERNODES_H

#include <QHash>
#include <QString>
#include <QVector>
#include <QVariantMap>
#include <QAbstractListModel>

// Flat list of the status.nodes map, joined with the configuration tree for display names.
class DynamicLoadManagerNodes : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NodeIdRole = Qt::UserRole + 1,
        DisplayNameRole,
        AllocationL1Role,
        AllocationL2Role,
        AllocationL3Role,
        FaultedRole
    };
    Q_ENUM(Roles)

    explicit DynamicLoadManagerNodes(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // statusNodes: the status.nodes map keyed by nodeId. names: nodeId -> displayName from the config tree.
    void update(const QVariantMap &statusNodes, const QHash<QString, QString> &names);
    void setFaulted(const QString &nodeId, bool faulted);

private:
    struct Node {
        QString nodeId;
        QString displayName;
        double allocationL1 = 0;
        double allocationL2 = 0;
        double allocationL3 = 0;
        bool faulted = false;
    };

    QVector<Node> m_nodes;
};

#endif // DYNAMICLOADMANAGERNODES_H
