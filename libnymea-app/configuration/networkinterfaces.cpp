// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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

#include "networkinterfaces.h"

#include <QSet>

#include <algorithm>

NetworkInterfaces::NetworkInterfaces(QObject *parent):
    QAbstractListModel(parent)
{
}

int NetworkInterfaces::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_interfaces.count());
}

QVariant NetworkInterfaces::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_interfaces.count()) {
        return QVariant();
    }

    const QVariantMap &entry = m_interfaces.at(index.row());
    switch (role) {
    case RoleIndex:
        return entry.value("index");
    case RoleName:
        return entry.value("name");
    case RoleKind:
        return entry.value("kind");
    case RoleMacAddress:
        return entry.value("macAddress");
    case RoleAdministrativeState:
        return entry.value("administrativeState");
    case RoleOperationalState:
        return entry.value("operationalState");
    case RoleManagementStatus:
        return entry.value("managementStatus");
    case RoleIpv4Addresses:
        return entry.value("ipv4Addresses");
    case RoleIpv6Addresses:
        return entry.value("ipv6Addresses");
    }
    return QVariant();
}

QHash<int, QByteArray> NetworkInterfaces::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndex, "interfaceIndex");
    roles.insert(RoleName, "name");
    roles.insert(RoleKind, "kind");
    roles.insert(RoleMacAddress, "macAddress");
    roles.insert(RoleAdministrativeState, "administrativeState");
    roles.insert(RoleOperationalState, "operationalState");
    roles.insert(RoleManagementStatus, "managementStatus");
    roles.insert(RoleIpv4Addresses, "ipv4Addresses");
    roles.insert(RoleIpv6Addresses, "ipv6Addresses");
    return roles;
}

QVariantMap NetworkInterfaces::get(int row) const
{
    if (row < 0 || row >= m_interfaces.count()) {
        return QVariantMap();
    }

    return m_interfaces.at(row);
}

void NetworkInterfaces::applySnapshot(const QVariantList &interfaces)
{
    QList<QVariantMap> next;
    QSet<QString> nextKeys;
    foreach (const QVariant &interfaceVariant, interfaces) {
        QVariantMap entry = normalize(interfaceVariant.toMap());
        if (entry.value("name").toString().isEmpty() || nextKeys.contains(key(entry))) {
            continue;
        }

        nextKeys.insert(key(entry));
        next.append(entry);
    }

    std::stable_sort(next.begin(), next.end(), [](const QVariantMap &left, const QVariantMap &right) {
        const int leftIndex = left.value("index").toInt();
        const int rightIndex = right.value("index").toInt();
        if (leftIndex != rightIndex) {
            return leftIndex < rightIndex;
        }

        return left.value("name").toString() < right.value("name").toString();
    });

    const int previousCount = rowCount();

    for (int i = rowCount() - 1; i >= 0; i--) {
        if (!nextKeys.contains(key(m_interfaces.at(i)))) {
            beginRemoveRows(QModelIndex(), i, i);
            m_interfaces.removeAt(i);
            endRemoveRows();
        }
    }

    // Both lists are sorted the same way, so remaining rows line up with their position in the snapshot
    for (int i = 0; i < next.count(); i++) {
        if (i < m_interfaces.count() && key(m_interfaces.at(i)) == key(next.at(i))) {
            if (m_interfaces.at(i) != next.at(i)) {
                m_interfaces[i] = next.at(i);
                emit dataChanged(index(i), index(i));
            }
        } else {
            beginInsertRows(QModelIndex(), i, i);
            m_interfaces.insert(i, next.at(i));
            endInsertRows();
        }
    }

    if (m_interfaces.count() > next.count()) {
        beginRemoveRows(QModelIndex(), static_cast<int>(next.count()), static_cast<int>(m_interfaces.count()) - 1);
        m_interfaces.erase(m_interfaces.begin() + next.count(), m_interfaces.end());
        endRemoveRows();
    }

    if (rowCount() != previousCount) {
        emit countChanged();
    }
}

void NetworkInterfaces::clear()
{
    if (m_interfaces.isEmpty()) {
        return;
    }

    beginResetModel();
    m_interfaces.clear();
    endResetModel();
    emit countChanged();
}

QVariantMap NetworkInterfaces::normalize(const QVariantMap &entry) const
{
    QVariantMap result;
    result.insert("index", entry.value("index").toInt());
    result.insert("name", entry.value("name").toString());
    result.insert("macAddress", entry.value("macAddress").toString());

    const QStringList textFields = {"kind", "administrativeState", "operationalState", "managementStatus"};
    foreach (const QString &field, textFields) {
        const QString value = entry.value(field).toString();
        result.insert(field, value.isEmpty() ? QStringLiteral("unknown") : value);
    }

    const QStringList addressFields = {"ipv4Addresses", "ipv6Addresses"};
    foreach (const QString &field, addressFields) {
        QVariantList addresses;
        foreach (const QVariant &addressVariant, entry.value(field).toList()) {
            const QVariantMap address = addressVariant.toMap();
            if (address.value("address").toString().isEmpty()) {
                continue;
            }

            QVariantMap item;
            item.insert("address", address.value("address").toString());
            item.insert("prefixLength", address.value("prefixLength").toInt());
            addresses.append(item);
        }
        result.insert(field, addresses);
    }
    return result;
}

QString NetworkInterfaces::key(const QVariantMap &entry) const
{
    // The kernel ifindex survives renames; fall back to the name if the server did not supply one
    const int interfaceIndex = entry.value("index").toInt();
    if (interfaceIndex > 0) {
        return QString::number(interfaceIndex);
    }

    return QStringLiteral("name:") + entry.value("name").toString();
}
