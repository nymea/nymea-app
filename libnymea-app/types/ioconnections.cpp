/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "ioconnections.h"

IOConnections::IOConnections(QObject *parent) : QAbstractListModel(parent)
{

}

int IOConnections::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
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
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
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
