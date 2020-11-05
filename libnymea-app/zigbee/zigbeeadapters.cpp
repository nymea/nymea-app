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
    case RoleBackendType:
        return m_adapters.at(index.row())->backendType();
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
    roles.insert(RoleBackendType, "backendType");
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

    connect(adapter, &ZigbeeAdapter::backendTypeChanged, this, [this, adapter]() {
        QModelIndex idx = index(m_adapters.indexOf(adapter), 0);
        emit dataChanged(idx, idx, {RoleBackendType});
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
    if (index < 0 || index > m_adapters.count() - 1) {
        return nullptr;
    }

    return m_adapters.at(index);
}
