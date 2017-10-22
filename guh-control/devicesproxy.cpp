/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control                                       *
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


DevicesBasicTagsModel::DevicesBasicTagsModel(QObject *parent):
    QAbstractListModel(parent)
{

}

int DevicesBasicTagsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_tags.count();
}

QVariant DevicesBasicTagsModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleTag:
        return m_tags.at(index.row());
    case RoleTagLabel:
        return DeviceClass::basicTagToString(m_tags.at(index.row()));
    }
    return QVariant();
}

QHash<int, QByteArray> DevicesBasicTagsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleTag, "tag");
    roles.insert(RoleTagLabel, "tagLabel");
    return roles;
}

Devices *DevicesBasicTagsModel::devices() const
{
    return m_devices;
}

void DevicesBasicTagsModel::setDevices(Devices *devices)
{
    if (m_devices != devices) {
        m_devices = devices;
        syncTags();

        connect(devices, &Devices::rowsInserted, this, &DevicesBasicTagsModel::rowsChanged);
        connect(devices, &Devices::rowsRemoved, this, &DevicesBasicTagsModel::rowsChanged);
    }
}

bool DevicesBasicTagsModel::hideSystemTags() const
{
    return m_hideSystemTags;
}

void DevicesBasicTagsModel::setHideSystemTags(bool hideSystemTags)
{
    if (m_hideSystemTags != hideSystemTags) {
        m_hideSystemTags = hideSystemTags;
        emit hideSystemTagsChanged();
        syncTags();
    }
}

QString DevicesBasicTagsModel::basicTagToString(DeviceClass::BasicTag basicTag) const
{
    return DeviceClass::basicTagToString(basicTag);
}

void DevicesBasicTagsModel::rowsChanged(const QModelIndex &index, int first, int last)
{
    Q_UNUSED(index)
    Q_UNUSED(first)
    Q_UNUSED(last)

    syncTags();
}

void DevicesBasicTagsModel::syncTags()
{
    if (!m_devices) {
        return;
    }

    QList<DeviceClass::BasicTag> tagsInSource;
    for (int i = 0; i < m_devices->count(); i++) {
        DeviceClass *dc = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(m_devices->get(i)->deviceClassId());
        foreach (DeviceClass::BasicTag tag, dc->basicTags()) {
            if (!tagsInSource.contains(tag)) {
                tagsInSource.append(tag);
            }
        }
    }
    QList<DeviceClass::BasicTag> tagsToAdd = tagsInSource;
    if (m_hideSystemTags) {
        tagsToAdd.removeAll(DeviceClass::BasicTagActuator);
        tagsToAdd.removeAll(DeviceClass::BasicTagDevice);
        tagsToAdd.removeAll(DeviceClass::BasicTagService);
    }

    for (QList<DeviceClass::BasicTag>::iterator i = m_tags.begin(); i != m_tags.end();) {
        if (!tagsInSource.contains(*i)) {
            int idx = m_tags.indexOf(*i);
            beginRemoveRows(QModelIndex(), idx, idx);
            m_tags.takeAt(idx);
            endRemoveRows();
            continue;
        }
        tagsToAdd.removeAll(*i);
        ++i;
    }
    if (!tagsToAdd.isEmpty()) {
        beginInsertRows(QModelIndex(), m_tags.count(), m_tags.count() + tagsToAdd.count() - 1);
        m_tags.append(tagsToAdd);
        endInsertRows();
    }
}
