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

#include "zigbeeadapters.h"

ZigbeeAdapters::ZigbeeAdapters(QObject *parent) : QAbstractListModel(parent)
{

}

int ZigbeeAdapters::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_adapters.count();
}

QVariant ZigbeeAdapters::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_adapters.at(index.row())->name();
    case RoleDescription:
        return m_adapters.at(index.row())->description();
    case RoleSerialPort:
        return m_adapters.at(index.row())->serialPort();
    case RoleHardwareRecognized:
        return m_adapters.at(index.row())->hardwareRecognized();
    case RoleBackend:
        return m_adapters.at(index.row())->backend();
    case RoleBaudRate:
        return m_adapters.at(index.row())->baudRate();
    }
    return QVariant();
}

QHash<int, QByteArray> ZigbeeAdapters::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleDescription, "description");
    roles.insert(RoleSerialPort, "serialPort");
    roles.insert(RoleHardwareRecognized, "hardwareRecognized");
    roles.insert(RoleBackend, "backend");
    roles.insert(RoleBaudRate, "baudRate");
    return roles;
}

void ZigbeeAdapters::addAdapter(ZigbeeAdapter *adapter)
{
    adapter->setParent(this);

    beginInsertRows(QModelIndex(), m_adapters.count(), m_adapters.count());
    m_adapters.append(adapter);

    connect(adapter, &ZigbeeAdapter::nameChanged, this, [this, adapter]() {
        QModelIndex idx = index(m_adapters.indexOf(adapter), 0);
        emit dataChanged(idx, idx, {RoleName});
    });

    connect(adapter, &ZigbeeAdapter::descriptionChanged, this, [this, adapter]() {
        QModelIndex idx = index(m_adapters.indexOf(adapter), 0);
        emit dataChanged(idx, idx, {RoleDescription});
    });

    connect(adapter, &ZigbeeAdapter::serialPortChanged, this, [this, adapter]() {
        QModelIndex idx = index(m_adapters.indexOf(adapter), 0);
        emit dataChanged(idx, idx, {RoleSerialPort});
    });

    connect(adapter, &ZigbeeAdapter::hardwareRecognizedChanged, this, [this, adapter]() {
        QModelIndex idx = index(m_adapters.indexOf(adapter), 0);
        emit dataChanged(idx, idx, {RoleHardwareRecognized});
    });

    connect(adapter, &ZigbeeAdapter::backendChanged, this, [this, adapter]() {
        QModelIndex idx = index(m_adapters.indexOf(adapter), 0);
        emit dataChanged(idx, idx, {RoleBackend});
    });

    connect(adapter, &ZigbeeAdapter::baudRateChanged, this, [this, adapter]() {
        QModelIndex idx = index(m_adapters.indexOf(adapter), 0);
        emit dataChanged(idx, idx, {RoleBaudRate});
    });

    endInsertRows();

    emit countChanged();
}

void ZigbeeAdapters::removeAdapter(const QString &serialPort)
{
    for (int i = 0; i < m_adapters.count(); i++) {
        if (m_adapters.at(i)->serialPort() == serialPort) {
            beginRemoveRows(QModelIndex(), i, i);
            m_adapters.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

void ZigbeeAdapters::clear()
{
    beginResetModel();
    qDeleteAll(m_adapters);
    m_adapters.clear();
    endResetModel();
    emit countChanged();
}

ZigbeeAdapter *ZigbeeAdapters::get(int index) const
{
    if (index < 0 || index >= m_adapters.count()) {
        return nullptr;
    }

    return m_adapters.at(index);
}
