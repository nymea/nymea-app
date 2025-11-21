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

#include "ioconnections.h"

IOConnections::IOConnections(QObject *parent) : QAbstractListModel(parent)
{

}

int IOConnections::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant IOConnections::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleInputThingId:
        return m_list.at(index.row())->inputThingId();
    case RoleInputStateTypeId:
        return m_list.at(index.row())->inputStateTypeId();
    case RoleOutputThingId:
        return m_list.at(index.row())->outputThingId();
    case RoleOutputStateTypeId:
        return m_list.at(index.row())->outputStateTypeId();
    case RoleInverted:
        return m_list.at(index.row())->inverted();
    }
    return QVariant();
}

QHash<int, QByteArray> IOConnections::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleInputThingId, "inputThingId");
    roles.insert(RoleInputStateTypeId, "inputStateTypeId");
    roles.insert(RoleOutputThingId, "outputThingId");
    roles.insert(RoleOutputStateTypeId, "outputStateTypeId");
    roles.insert(RoleInverted, "inverted");
    return roles;
}

void IOConnections::addIOConnection(IOConnection *ioConnection)
{
    ioConnection->setParent(this);
    beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
    m_list.append(ioConnection);
    endInsertRows();
    emit countChanged();
}

void IOConnections::removeIOConnection(const QUuid &ioConnectionId)
{
    int idx = -1;
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == ioConnectionId) {
            idx = i;
            break;
        }
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.takeAt(idx)->deleteLater();
    endRemoveRows();
    emit countChanged();
}

void IOConnections::clearModel()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
}

IOConnection *IOConnections::getIOConnection(const QUuid &ioConnectionId) const
{
    foreach (IOConnection* ioConnection, m_list) {
        if (ioConnection->id() == ioConnectionId) {
            return ioConnection;
        }
    }
    return nullptr;
}

IOConnection *IOConnections::findIOConnectionByInput(const QUuid &inputThingId, const QUuid &inputStateTypeId) const
{
    foreach (IOConnection* ioConnection, m_list) {
        if (ioConnection->inputThingId() == inputThingId && ioConnection->inputStateTypeId() == inputStateTypeId) {
            return ioConnection;
        }
    }
    return nullptr;
}

IOConnection *IOConnections::findIOConnectionByOutput(const QUuid &outputThingId, const QUuid &outputStateTypeId) const
{
    foreach (IOConnection* ioConnection, m_list) {
        if (ioConnection->outputThingId() == outputThingId && ioConnection->outputStateTypeId() == outputStateTypeId) {
            return ioConnection;
        }
    }
    return nullptr;
}
