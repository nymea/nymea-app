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

Engine *DeviceClassesProxy::engine() const
{
    return m_engine;
}

void DeviceClassesProxy::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        setSourceModel(engine->deviceManager()->deviceClasses());
        emit engineChanged();
        emit countChanged();
        sort(0);
    }
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
        emit countChanged();
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
        emit countChanged();
    }
}

QUuid DeviceClassesProxy::filterVendorId() const
{
    return m_filterVendorId;
}

void DeviceClassesProxy::setFilterVendorId(const QUuid &filterVendorId)
{
    if (m_filterVendorId != filterVendorId) {
        m_filterVendorId = filterVendorId;
        emit filterVendorIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DeviceClassesProxy::filterVendorName() const
{
    return m_filterVendorName;
}

void DeviceClassesProxy::setFilterVendorName(const QString &filterVendorName)
{
    if (m_filterVendorName != filterVendorName) {
        m_filterVendorName = filterVendorName;
        emit filterVendorNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DeviceClassesProxy::filterString() const
{
    return m_filterString;
}

void DeviceClassesProxy::setFilterString(const QString &filterString)
{
    if (m_filterString != filterString) {
        m_filterString = filterString;
        emit filterStringChanged();
        invalidateFilter();
        emit countChanged();
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
    return m_engine->deviceManager()->deviceClasses()->get(mapToSource(this->index(index, 0)).row());
}


void DeviceClassesProxy::resetFilter()
{
    m_filterVendorId = QUuid();
    m_filterInterface.clear();
    m_filterVendorName.clear();
    m_filterDisplayName.clear();
    invalidateFilter();
    emit countChanged();
}

bool DeviceClassesProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)

    DeviceClass *deviceClass = m_engine->deviceManager()->deviceClasses()->get(sourceRow);

    // filter auto devices
    if (deviceClass->createMethods().count() == 1 && deviceClass->createMethods().contains("CreateMethodAuto"))
        return false;

    if (!m_filterVendorId.isNull() && deviceClass->vendorId() != m_filterVendorId)
        return false;

    if (!m_filterInterface.isEmpty() && !deviceClass->interfaces().contains(m_filterInterface)) {
        return false;
    }

    if (!m_filterDisplayName.isEmpty() && !deviceClass->displayName().toLower().contains(m_filterDisplayName.toLower())) {
        return false;
    }

    if (!m_filterVendorName.isEmpty()) {
        Vendor *vendor = m_engine->deviceManager()->vendors()->getVendor(deviceClass->vendorId());
        if (!vendor) {
            qWarning() << "Invalid vendor for deviceClass:" << deviceClass->name() << deviceClass->vendorId();
            return false;
        }
        if (!vendor->displayName().toLower().contains(m_filterVendorName.toLower())) {
            return false;
        }
    }

    if (!m_filterString.isEmpty()) {
        Vendor *vendor = m_engine->deviceManager()->vendors()->getVendor(deviceClass->vendorId());
        if (!vendor) {
            qWarning() << "Invalid vendor for deviceClass:" << deviceClass->name() << deviceClass->vendorId();
            return false;
        }
        if (!vendor->displayName().toLower().contains(m_filterString.toLower()) && !deviceClass->displayName().toLower().contains(m_filterString.toLower())) {
            return false;
        }
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
