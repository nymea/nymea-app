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
    connect(Engine::instance()->tagsManager()->tags(), &Tags::countChanged, this, &DevicesProxy::invalidateFilter);
}

Devices *DevicesProxy::devices() const
{
    return m_devices;
}

void DevicesProxy::setDevices(Devices *devices)
{
    if (m_devices != devices) {
        m_devices = devices;
        setSourceModel(devices);
        setSortRole(Devices::RoleName);
        sort(0);
        connect(devices, &Devices::countChanged, this, &DevicesProxy::countChanged);
        emit devicesChanged();
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

Device *DevicesProxy::get(int index) const
{
    return m_devices->get(mapToSource(this->index(index, 0)).row());
}

bool DevicesProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    QVariant leftName = sourceModel()->data(left, Devices::RoleName);
    QVariant rightName = sourceModel()->data(right, Devices::RoleName);

    return QString::localeAwareCompare(leftName.toString(), rightName.toString()) < 0;
}

bool DevicesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Device *device = m_devices->get(source_row);
    if (!m_filterTagId.isEmpty()) {
        if (!Engine::instance()->tagsManager()->tags()->findDeviceTag(device->id().toString(), m_filterTagId)) {
            return false;
        }
    }
    if (!m_shownInterfaces.isEmpty()) {
        QStringList interfaces = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(m_devices->get(source_row)->deviceClassId())->interfaces();
        bool foundMatch = false;
        foreach (const QString &filterInterface, m_shownInterfaces) {
            if (interfaces.contains(filterInterface)) {
                foundMatch = true;
                continue;
            }
        }
        if (!foundMatch) {
            return false;
        }
    }

    if (!m_hiddenInterfaces.isEmpty()) {
        QStringList interfaces = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(m_devices->get(source_row)->deviceClassId())->interfaces();
        foreach (const QString &filterInterface, m_hiddenInterfaces) {
            if (interfaces.contains(filterInterface)) {
                return false;
            }
        }
    }
    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}
