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

#include "dynamicloadmanagernodes.h"

#include <algorithm>

DynamicLoadManagerNodes::DynamicLoadManagerNodes(QObject *parent)
    : QAbstractListModel(parent)
{

}

int DynamicLoadManagerNodes::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_nodes.size();
}

QVariant DynamicLoadManagerNodes::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_nodes.size())
        return QVariant();

    const Node &node = m_nodes.at(index.row());
    switch (role) {
    case NodeIdRole:
        return node.nodeId;
    case Qt::DisplayRole:
    case DisplayNameRole:
        return node.displayName.isEmpty() ? node.nodeId : node.displayName;
    case AllocationL1Role:
        return node.allocationL1;
    case AllocationL2Role:
        return node.allocationL2;
    case AllocationL3Role:
        return node.allocationL3;
    case MeasuredLoadL1Role:
        return node.measuredLoadL1;
    case MeasuredLoadL2Role:
        return node.measuredLoadL2;
    case MeasuredLoadL3Role:
        return node.measuredLoadL3;
    case SumOfChildrenL1Role:
        return node.sumOfChildrenL1;
    case SumOfChildrenL2Role:
        return node.sumOfChildrenL2;
    case SumOfChildrenL3Role:
        return node.sumOfChildrenL3;
    case FaultedRole:
        return node.faulted;
    }

    return QVariant();
}

QHash<int, QByteArray> DynamicLoadManagerNodes::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NodeIdRole] = "nodeId";
    roles[DisplayNameRole] = "displayName";
    roles[AllocationL1Role] = "allocationL1";
    roles[AllocationL2Role] = "allocationL2";
    roles[AllocationL3Role] = "allocationL3";
    roles[MeasuredLoadL1Role] = "measuredLoadL1";
    roles[MeasuredLoadL2Role] = "measuredLoadL2";
    roles[MeasuredLoadL3Role] = "measuredLoadL3";
    roles[SumOfChildrenL1Role] = "sumOfChildrenL1";
    roles[SumOfChildrenL2Role] = "sumOfChildrenL2";
    roles[SumOfChildrenL3Role] = "sumOfChildrenL3";
    roles[FaultedRole] = "faulted";
    return roles;
}

void DynamicLoadManagerNodes::update(const QVariantMap &statusNodes, const QHash<QString, QString> &names)
{
    QVector<Node> nodes;
    nodes.reserve(statusNodes.size());

    for (auto it = statusNodes.constBegin(); it != statusNodes.constEnd(); ++it) {
        QVariantMap nodeMap = it.value().toMap();
        QVariantMap allocation = nodeMap.value("allocation").toMap();
        QVariantMap measuredLoad = nodeMap.value("measuredLoad").toMap();
        QVariantMap sumOfChildren = nodeMap.value("sumOfChildren").toMap();

        Node node;
        node.nodeId = nodeMap.value("nodeId", it.key()).toString();
        node.displayName = names.value(node.nodeId);
        node.allocationL1 = allocation.value("l1").toDouble();
        node.allocationL2 = allocation.value("l2").toDouble();
        node.allocationL3 = allocation.value("l3").toDouble();
        node.measuredLoadL1 = measuredLoad.value("l1").toDouble();
        node.measuredLoadL2 = measuredLoad.value("l2").toDouble();
        node.measuredLoadL3 = measuredLoad.value("l3").toDouble();
        node.sumOfChildrenL1 = sumOfChildren.value("l1").toDouble();
        node.sumOfChildrenL2 = sumOfChildren.value("l2").toDouble();
        node.sumOfChildrenL3 = sumOfChildren.value("l3").toDouble();
        node.faulted = nodeMap.value("faulted").toBool();
        nodes.append(node);
    }

    std::sort(nodes.begin(), nodes.end(), [](const Node &lhs, const Node &rhs) {
        int cmp = QString::localeAwareCompare(lhs.displayName, rhs.displayName);
        return cmp != 0 ? cmp < 0 : lhs.nodeId < rhs.nodeId;
    });

    beginResetModel();
    m_nodes = nodes;
    endResetModel();
}

void DynamicLoadManagerNodes::setFaulted(const QString &nodeId, bool faulted)
{
    for (int row = 0; row < m_nodes.size(); ++row) {
        if (m_nodes.at(row).nodeId != nodeId)
            continue;

        if (m_nodes.at(row).faulted == faulted)
            return;

        m_nodes[row].faulted = faulted;
        emit dataChanged(index(row), index(row), {FaultedRole});
        return;
    }
}
