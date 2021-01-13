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

#include "thingdiscovery.h"

#include "engine.h"

ThingDiscovery::ThingDiscovery(QObject *parent) :
    QAbstractListModel(parent)
{
}

int ThingDiscovery::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_foundDevices.count();
}

QVariant ThingDiscovery::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_foundDevices.at(index.row())->id();
    case RoleName:
        return m_foundDevices.at(index.row())->name();
    case RoleDescription:
        return m_foundDevices.at(index.row())->description();
    case RoleDeviceId:
        return m_foundDevices.at(index.row())->deviceId();
    }

    return QVariant();
}

QHash<int, QByteArray> ThingDiscovery::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleDeviceId, "deviceId");
    roles.insert(RoleName, "name");
    roles.insert(RoleDescription, "description");
    return roles;
}

void ThingDiscovery::discoverThings(const QUuid &deviceClassId, const QVariantList &discoveryParams)
{
    if (m_busy) {
        qWarning() << "Busy... not restarting discovery";
        return;
    }
    beginResetModel();
    m_foundDevices.clear();
    endResetModel();
    emit countChanged();

    if (!m_engine) {
        qWarning() << "Cannot discover devices. No Engine set";
        return;
    }
    if (!m_engine->jsonRpcClient()->connected()) {
        qWarning() << "Cannot discover devices. Not connected.";
        return;
    }

    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    if (!discoveryParams.isEmpty()) {
        params.insert("discoveryParams", discoveryParams);
    }
    m_engine->jsonRpcClient()->sendCommand("Devices.GetDiscoveredDevices", params, this, "discoverThingsResponse");
    m_busy = true;
    m_displayMessage.clear();
    emit busyChanged();
}

DeviceDescriptor *ThingDiscovery::get(int index) const
{
    if (index < 0 || index >= m_foundDevices.count()) {
        return nullptr;
    }
    return m_foundDevices.at(index);
}

Engine *ThingDiscovery::engine() const
{
    return m_engine;
}

void ThingDiscovery::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit engineChanged();
    }
}

bool ThingDiscovery::busy() const
{
    return m_busy;
}

QString ThingDiscovery::displayMessage() const
{
    return m_displayMessage;
}

void ThingDiscovery::discoverThingsResponse(int /*commandId*/, const QVariantMap &params)
{
    qDebug() << "response received" << params;
    QVariantList descriptors = params.value("deviceDescriptors").toList();
    foreach (const QVariant &descriptorVariant, descriptors) {
        qDebug() << "Found device. Descriptor:" << descriptorVariant;
        if (!contains(descriptorVariant.toMap().value("id").toUuid())) {
            beginInsertRows(QModelIndex(), m_foundDevices.count(), m_foundDevices.count());
            DeviceDescriptor *descriptor = new DeviceDescriptor(descriptorVariant.toMap().value("id").toUuid(),
                                                   descriptorVariant.toMap().value("deviceId").toString(),
                                                   descriptorVariant.toMap().value("title").toString(),
                                                   descriptorVariant.toMap().value("description").toString());
            foreach (const QVariant &paramVariant, descriptorVariant.toMap().value("deviceParams").toList()) {
                qDebug() << "Adding param:" << paramVariant.toMap().value("paramTypeId").toString() << paramVariant.toMap().value("value");
                Param* p = new Param(paramVariant.toMap().value("paramTypeId").toString(), paramVariant.toMap().value("value"));
                descriptor->params()->addParam(p);
            }
            m_foundDevices.append(descriptor);
            endInsertRows();
            emit countChanged();
        }
    }

    m_displayMessage = params.value("displayMessage").toString();
    m_busy = false;
    emit busyChanged();
}

bool ThingDiscovery::contains(const QUuid &deviceDescriptorId) const
{
    foreach (DeviceDescriptor *descriptor, m_foundDevices) {
        if (descriptor->id() == deviceDescriptorId) {
            return true;
        }
    }
    return false;
}

DeviceDescriptor::DeviceDescriptor(const QUuid &id, const QUuid &deviceId, const QString &name, const QString &description, QObject *parent):
    QObject(parent),
    m_id(id),
    m_deviceId(deviceId),
    m_name(name),
    m_description(description),
    m_params(new Params(this))
{

}

QUuid DeviceDescriptor::id() const
{
    return m_id;
}

QUuid DeviceDescriptor::deviceId() const
{
    return m_deviceId;
}

QString DeviceDescriptor::name() const
{
    return m_name;
}

QString DeviceDescriptor::description() const
{
    return m_description;
}

Params* DeviceDescriptor::params() const
{
    return m_params;
}

DeviceDiscoveryProxy::DeviceDiscoveryProxy(QObject *parent):
    QSortFilterProxyModel (parent)
{

}

ThingDiscovery *DeviceDiscoveryProxy::deviceDiscovery() const
{
    return m_deviceDiscovery;
}

void DeviceDiscoveryProxy::setDeviceDiscovery(ThingDiscovery *deviceDiscovery)
{
    if (m_deviceDiscovery != deviceDiscovery) {
        m_deviceDiscovery = deviceDiscovery;
        setSourceModel(deviceDiscovery);
        emit deviceDiscoveryChanged();
        emit countChanged();
        connect(m_deviceDiscovery, &ThingDiscovery::countChanged, this, &DeviceDiscoveryProxy::countChanged);
        invalidateFilter();
    }
}

bool DeviceDiscoveryProxy::showAlreadyAdded() const
{
    return m_showAlreadyAdded;
}

void DeviceDiscoveryProxy::setShowAlreadyAdded(bool showAlreadyAdded)
{
    if (m_showAlreadyAdded != showAlreadyAdded) {
        m_showAlreadyAdded = showAlreadyAdded;
        emit showAlreadyAddedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DeviceDiscoveryProxy::showNew() const
{
    return m_showNew;
}

void DeviceDiscoveryProxy::setShowNew(bool showNew)
{
    if (m_showNew != showNew) {
        m_showNew = showNew;
        emit showNewChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QUuid DeviceDiscoveryProxy::filterDeviceId() const
{
    return m_filterDeviceId;
}

void DeviceDiscoveryProxy::setFilterDeviceId(const QUuid &filterDeviceId)
{
    if (m_filterDeviceId != filterDeviceId) {
        m_filterDeviceId = filterDeviceId;
        emit filterDeviceIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

DeviceDescriptor *DeviceDiscoveryProxy::get(int index) const
{
    return m_deviceDiscovery->get(mapToSource(this->index(index, 0)).row());
}

bool DeviceDiscoveryProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    DeviceDescriptor* dev = m_deviceDiscovery->get(sourceRow);
    if (!m_showAlreadyAdded && !dev->deviceId().isNull()) {
        return false;
    }
    if (!m_showNew && dev->deviceId().isNull()) {
        return false;
    }
    if (!m_filterDeviceId.isNull() && dev->deviceId() != m_filterDeviceId) {
        return false;
    }
    return true;
}
