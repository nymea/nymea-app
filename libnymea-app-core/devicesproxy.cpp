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

#include "devicesproxy.h"
#include "engine.h"
#include "tagsmanager.h"

DevicesProxy::DevicesProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{
}

Engine *DevicesProxy::engine() const
{
    return m_engine;
}

void DevicesProxy::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        connect(m_engine->tagsManager()->tags(), &Tags::countChanged, this, &DevicesProxy::invalidateFilter);
        emit engineChanged();

        if (!sourceModel()) {
            setSourceModel(m_engine->deviceManager()->devices());

            setSortRole(Devices::RoleName);
            sort(0);
            connect(sourceModel(), SIGNAL(countChanged()), this, SIGNAL(countChanged()));
            connect(sourceModel(), &QAbstractItemModel::dataChanged, this, [this]() {
                invalidateFilter();
                emit countChanged();
            });

        }
    }
}

DevicesProxy *DevicesProxy::parentProxy() const
{
    return m_parentProxy;
}

void DevicesProxy::setParentProxy(DevicesProxy *parentProxy)
{
    if (m_parentProxy != parentProxy) {
        m_parentProxy = parentProxy;
        setSourceModel(parentProxy);

        setSortRole(Devices::RoleName);
        sort(0);
        connect(m_parentProxy, SIGNAL(countChanged()), this, SIGNAL(countChanged()));
        connect(m_parentProxy, &QAbstractItemModel::dataChanged, this, [this]() {
            if (m_engine) {
                invalidateFilter();
                emit countChanged();
            }
        });

        if (m_engine) {
            invalidateFilter();
        }

        emit parentProxyChanged();
        emit countChanged();
    }
}

QString DevicesProxy::filterTagId() const
{
    return m_filterTagId;
}

void DevicesProxy::setFilterTagId(const QString &filterTag)
{
    if (m_filterTagId != filterTagId()) {
        m_filterTagId = filterTag;
        emit filterTagIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::filterDeviceClassId() const
{
    return m_filterDeviceClassId;
}

void DevicesProxy::setFilterDeviceClassId(const QString &filterDeviceClassId)
{
    if (m_filterDeviceClassId != filterDeviceClassId) {
        m_filterDeviceClassId = filterDeviceClassId;
        emit filterDeviceClassIdChanged();
        invalidateFilter();
    }
}

QStringList DevicesProxy::shownInterfaces() const
{
    return m_shownInterfaces;
}

void DevicesProxy::setShownInterfaces(const QStringList &shownInterfaces)
{
    if (m_shownInterfaces != shownInterfaces) {
        m_shownInterfaces = shownInterfaces;
        emit shownInterfacesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QStringList DevicesProxy::hiddenInterfaces() const
{
    return m_hiddenInterfaces;
}

void DevicesProxy::setHiddenInterfaces(const QStringList &hiddenInterfaces)
{
    if (m_hiddenInterfaces != hiddenInterfaces) {
        m_hiddenInterfaces = hiddenInterfaces;
        emit hiddenInterfacesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::nameFilter() const
{
    return m_nameFilter;
}

void DevicesProxy::setNameFilter(const QString &nameFilter)
{
    if (m_nameFilter != nameFilter) {
        m_nameFilter = nameFilter;
        emit nameFilterChanged();
        invalidateFilter();
        countChanged();
    }
}

bool DevicesProxy::filterBatteryCritical() const
{
    return m_filterBatteryCritical;
}

void DevicesProxy::setFilterBatteryCritical(bool filterBatteryCritical)
{
    if (m_filterBatteryCritical != filterBatteryCritical) {
        m_filterBatteryCritical = filterBatteryCritical;
        emit filterBatteryCriticalChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::filterDisconnected() const
{
    return m_filterDisconnected;
}

void DevicesProxy::setFilterDisconnected(bool filterDisconnected)
{
    if (m_filterDisconnected != filterDisconnected) {
        m_filterDisconnected = filterDisconnected;
        emit filterDisconnectedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::groupByInterface() const
{
    return m_groupByInterface;
}

void DevicesProxy::setGroupByInterface(bool groupByInterface)
{
    if (m_groupByInterface != groupByInterface) {
        m_groupByInterface = groupByInterface;
        emit groupByInterfaceChanged();
        invalidate();
    }
}

Device *DevicesProxy::get(int index) const
{
    return getInternal(mapToSource(this->index(index, 0)).row());
}

Device *DevicesProxy::getInternal(int source_index) const
{
    Devices* d = qobject_cast<Devices*>(sourceModel());
    if (d) {
        return d->get(source_index);
    }
    DevicesProxy *dp = qobject_cast<DevicesProxy*>(sourceModel());
    if (dp) {
        return dp->get(source_index);
    }
    return nullptr;
}

bool DevicesProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_groupByInterface) {
        QString leftBaseInterface = sourceModel()->data(left, Devices::RoleBaseInterface).toString();
        QString rightBaseInterface = sourceModel()->data(right, Devices::RoleBaseInterface).toString();
        if (leftBaseInterface != rightBaseInterface) {
            return QString::localeAwareCompare(leftBaseInterface, rightBaseInterface) < 0;
        }
    }
    QString leftName = sourceModel()->data(left, Devices::RoleName).toString();
    QString rightName = sourceModel()->data(right, Devices::RoleName).toString();

    return QString::localeAwareCompare(leftName, rightName) < 0;
}

bool DevicesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Device *device = getInternal(source_row);
    if (!m_filterTagId.isEmpty()) {
        if (!m_engine->tagsManager()->tags()->findDeviceTag(device->id().toString(), m_filterTagId)) {
            return false;
        }
    }
    if (!m_filterDeviceClassId.isEmpty()) {
        if (device->deviceClassId() != m_filterDeviceClassId) {
            return false;
        }
    }
    DeviceClass *deviceClass = m_engine->deviceManager()->deviceClasses()->getDeviceClass(device->deviceClassId());
//    qDebug() << "Checking device" << deviceClass->name() << deviceClass->interfaces();
    if (!m_shownInterfaces.isEmpty()) {
        bool foundMatch = false;
        foreach (const QString &filterInterface, m_shownInterfaces) {
            if (deviceClass->interfaces().contains(filterInterface)) {
                foundMatch = true;
                continue;
            }
        }
        if (!foundMatch) {
            return false;
        }
    }

    if (!m_hiddenInterfaces.isEmpty()) {
        foreach (const QString &filterInterface, m_hiddenInterfaces) {
            if (deviceClass->interfaces().contains(filterInterface)) {
                return false;
            }
        }
    }

    if (m_filterBatteryCritical) {
        if (!deviceClass->interfaces().contains("battery") || device->stateValue(deviceClass->stateTypes()->findByName("batteryCritical")->id()).toBool() == false) {
            return false;
        }
    }

    if (m_filterDisconnected) {
        if (!deviceClass->interfaces().contains("connectable") || device->stateValue(deviceClass->stateTypes()->findByName("connected")->id()).toBool() == true) {
            return false;
        }
    }

    if (!m_nameFilter.isEmpty()) {
        if (!device->name().toLower().contains(m_nameFilter.toLower().trimmed())) {
            return false;
        }
    }
    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}
