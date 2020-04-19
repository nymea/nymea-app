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

#include "deviceclasses.h"

#include <QDebug>

DeviceClasses::DeviceClasses(QObject *parent) :
    QAbstractListModel(parent)
{
}

QList<DeviceClass *> DeviceClasses::deviceClasses()
{
    return m_deviceClasses;
}

int DeviceClasses::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_deviceClasses.count();
}

QVariant DeviceClasses::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_deviceClasses.count())
        return QVariant();

    DeviceClass *deviceClass = m_deviceClasses.at(index.row());
    switch (role) {
    case RoleId:
        return deviceClass->id().toString();
    case RoleName:
        return deviceClass->name();
    case RoleDisplayName:
        return deviceClass->displayName();
    case RolePluginId:
        return deviceClass->pluginId().toString();
    case RoleVendorId:
        return deviceClass->vendorId().toString();
    case RoleInterfaces:
        return deviceClass->interfaces();
    case RoleBaseInterface:
        return deviceClass->baseInterface();
    }
    return QVariant();
}

int DeviceClasses::count() const
{
    return m_deviceClasses.count();
}

DeviceClass *DeviceClasses::get(int index) const
{
    if (index < 0 || index >= m_deviceClasses.count()) {
        return nullptr;
    }
    return m_deviceClasses.at(index);
}

DeviceClass *DeviceClasses::getDeviceClass(QUuid deviceClassId) const
{
    foreach (DeviceClass *deviceClass, m_deviceClasses) {
        if (deviceClass->id() == deviceClassId) {
            return deviceClass;
        }
    }
    return nullptr;
}

void DeviceClasses::addDeviceClass(DeviceClass *deviceClass)
{
    beginInsertRows(QModelIndex(), m_deviceClasses.count(), m_deviceClasses.count());
    //qDebug() << "DeviceClasses: loaded deviceClass" << deviceClass->name();
    m_deviceClasses.append(deviceClass);
    endInsertRows();
    emit countChanged();
}

void DeviceClasses::clearModel()
{
    beginResetModel();
    qDeleteAll(m_deviceClasses);
    m_deviceClasses.clear();
    endResetModel();
    emit countChanged();
}

QHash<int, QByteArray> DeviceClasses::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleId] = "id";
    roles[RoleName] = "name";
    roles[RoleDisplayName] = "displayName";
    roles[RolePluginId] = "pluginId";
    roles[RoleVendorId] = "vendorId";
    roles[RoleInterfaces] = "interfaces";
    roles[RoleBaseInterface] = "baseInterface";
    return roles;
}
