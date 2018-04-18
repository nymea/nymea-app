/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                               *
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

DevicesProxy::DevicesProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{

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
        sort(0);
        connect(devices, &Devices::countChanged, this, &DevicesProxy::countChanged);
        emit devicesChanged();
        emit countChanged();
    }
}

DeviceClass::BasicTag DevicesProxy::filterTag() const
{
    return m_filterTag;
}

void DevicesProxy::setFilterTag(DeviceClass::BasicTag filterTag)
{
    if (m_filterTag != filterTag) {
        m_filterTag = filterTag;
        emit filterTagChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::filterInterface() const
{
    return m_filterInterface;
}

void DevicesProxy::setFilterInterface(const QString &filterInterface)
{
    if (m_filterInterface != filterInterface) {
        m_filterInterface = filterInterface;
        emit filterInterfaceChanged();
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
    QVariant leftName = sourceModel()->data(left);
    QVariant rightName = sourceModel()->data(right);

    return QString::localeAwareCompare(leftName.toString(), rightName.toString()) < 0;
}

bool DevicesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_filterTag != DeviceClass::BasicTagNone) {
        QList<DeviceClass::BasicTag> tags = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(m_devices->get(source_row)->deviceClassId())->basicTags();
        if (!tags.contains(m_filterTag)) {
            return false;
        }
    }
    if (!m_filterInterface.isEmpty()) {
        QStringList interfaces = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(m_devices->get(source_row)->deviceClassId())->interfaces();
        if (!interfaces.contains(m_filterInterface)) {
            return false;
        }
    }
    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}
