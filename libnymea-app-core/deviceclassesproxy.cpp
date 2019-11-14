/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "deviceclassesproxy.h"

#include <QDebug>

DeviceClassesProxy::DeviceClassesProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    setSortRole(DeviceClasses::RoleDisplayName);
}


QUuid DeviceClassesProxy::vendorId() const
{
    return m_vendorId;
}

void DeviceClassesProxy::setVendorId(const QUuid &vendorId)
{
    m_vendorId = vendorId;
    emit vendorIdChanged();

    qDebug() << "DeviceClassesProxy: set vendorId filter" << vendorId;

    invalidateFilter();
    sort(0);
}

DeviceClasses *DeviceClassesProxy::deviceClasses()
{
    return m_deviceClasses;
}

void DeviceClassesProxy::setDeviceClasses(DeviceClasses *deviceClasses)
{
    m_deviceClasses = deviceClasses;
    setSourceModel(deviceClasses);
    emit deviceClassesChanged();
    sort(0);
}

QString DeviceClassesProxy::filterInterface() const
{
    return m_filterInterface;
}

void DeviceClassesProxy::setFilterInterface(const QString &filterInterface)
{
    if (m_filterInterface != filterInterface) {
        m_filterInterface = filterInterface;
        emit filterInterfaceChanged();
        invalidateFilter();
    }
}

QString DeviceClassesProxy::filterDisplayName() const
{
    return m_filterDisplayName;
}

void DeviceClassesProxy::setFilterDisplayName(const QString &filter)
{
    if (m_filterDisplayName != filter) {
        m_filterDisplayName = filter;
        emit filterDisplayNameChanged();
        invalidateFilter();
    }
}

bool DeviceClassesProxy::groupByInterface() const
{
    return m_groupByInterface;
}

void DeviceClassesProxy::setGroupByInterface(bool groupByInterface)
{
    if (m_groupByInterface != groupByInterface) {
        m_groupByInterface = groupByInterface;
        emit groupByInterfaceChanged();
        invalidate();
    }
}

DeviceClass *DeviceClassesProxy::get(int index) const
{
    return m_deviceClasses->get(mapToSource(this->index(index, 0)).row());
}


void DeviceClassesProxy::resetFilter()
{
    qDebug() << "DeviceClassesProxy: reset filter";
    setVendorId(QUuid());
    invalidateFilter();
}

bool DeviceClassesProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)

    DeviceClass *deviceClass = m_deviceClasses->get(sourceRow);

    // filter auto devices
    if (deviceClass->createMethods().count() == 1 && deviceClass->createMethods().contains("CreateMethodAuto"))
        return false;

    if (!m_vendorId.isNull() && deviceClass->vendorId() != m_vendorId)
        return false;

    if (!m_filterInterface.isEmpty() && !deviceClass->interfaces().contains(m_filterInterface)) {
        return false;
    }

    if (!m_filterDisplayName.isEmpty() && !deviceClass->displayName().toLower().contains(m_filterDisplayName.toLower())) {
        return false;
    }

    return true;
}

bool DeviceClassesProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_groupByInterface) {
        QString leftBaseInterface = sourceModel()->data(left, DeviceClasses::RoleBaseInterface).toString();
        QString rightBaseInterface = sourceModel()->data(right, DeviceClasses::RoleBaseInterface).toString();
        if (leftBaseInterface != rightBaseInterface) {
            return QString::localeAwareCompare(leftBaseInterface, rightBaseInterface) < 0;
        }
    }
    QString leftName = sourceModel()->data(left, DeviceClasses::RoleDisplayName).toString();
    QString rightName = sourceModel()->data(right, DeviceClasses::RoleDisplayName).toString();

    return QString::localeAwareCompare(leftName, rightName) < 0;
}
