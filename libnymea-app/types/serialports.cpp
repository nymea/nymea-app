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

#include "serialports.h"

SerialPorts::SerialPorts(QObject *parent) : QAbstractListModel(parent)
{

}

int SerialPorts::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_serialPorts.count());
}

QVariant SerialPorts::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleSystemLocation:
        return m_serialPorts.at(index.row())->systemLocation();
    case RoleManufacturer:
        return m_serialPorts.at(index.row())->manufacturer();
    case RoleDescription:
        return m_serialPorts.at(index.row())->description();
    case RoleSerialNumber:
        return m_serialPorts.at(index.row())->serialNumber();
    }
    return QVariant();
}

QHash<int, QByteArray> SerialPorts::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleSystemLocation, "systemLocation");
    roles.insert(RoleManufacturer, "manufacturer");
    roles.insert(RoleDescription, "description");
    roles.insert(RoleSerialNumber, "serialNumber");
    return roles;
}

void SerialPorts::addSerialPort(SerialPort *serialPort)
{
    serialPort->setParent(this);

    beginInsertRows(QModelIndex(), static_cast<int>(m_serialPorts.count()), static_cast<int>(m_serialPorts.count()));
    m_serialPorts.append(serialPort);
    endInsertRows();

    emit countChanged();
}

void SerialPorts::removeSerialPort(const QString &systemLocation)
{
    for (int i = 0; i < m_serialPorts.count(); i++) {
        if (m_serialPorts.at(i)->systemLocation() == systemLocation) {
            beginRemoveRows(QModelIndex(), i, i);
            m_serialPorts.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}

void SerialPorts::clear()
{
    beginResetModel();
    qDeleteAll(m_serialPorts);
    m_serialPorts.clear();
    endResetModel();
    emit countChanged();
}

SerialPort *SerialPorts::find(const QString &systemLocation) const
{
    for (int i = 0; i < m_serialPorts.count(); i++) {
        if (m_serialPorts.at(i)->systemLocation() == systemLocation) {
            return m_serialPorts.at(i);
        }
    }
    return nullptr;
}

SerialPort *SerialPorts::get(int index) const
{
    if (index < 0 || index >= m_serialPorts.count()) {
        return nullptr;
    }

    return m_serialPorts.at(index);
}
