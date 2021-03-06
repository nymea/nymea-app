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
    return m_foundThings.count();
}

QVariant ThingDiscovery::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_foundThings.at(index.row())->id();
    case RoleName:
        return m_foundThings.at(index.row())->name();
    case RoleDescription:
        return m_foundThings.at(index.row())->description();
    case RoleThingId:
        return m_foundThings.at(index.row())->thingId();
    }

    return QVariant();
}

QHash<int, QByteArray> ThingDiscovery::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleThingId, "thingId");
    roles.insert(RoleName, "name");
    roles.insert(RoleDescription, "description");
    return roles;
}

void ThingDiscovery::discoverThings(const QUuid &thingClassId, const QVariantList &discoveryParams)
{
    if (m_busy) {
        qWarning() << "Busy... not restarting discovery";
        return;
    }
    beginResetModel();
    m_foundThings.clear();
    endResetModel();
    emit countChanged();

    if (!m_engine) {
        qWarning() << "Cannot discover things. No Engine set";
        return;
    }
    if (!m_engine->jsonRpcClient()->connected()) {
        qWarning() << "Cannot discover things. Not connected.";
        return;
    }

    QVariantMap params;
    params.insert("thingClassId", thingClassId.toString());
    if (!discoveryParams.isEmpty()) {
        params.insert("discoveryParams", discoveryParams);
    }
    m_engine->jsonRpcClient()->sendCommand("Integrations.DiscoverThings", params, this, "discoverThingsResponse");
    m_busy = true;
    m_displayMessage.clear();
    emit busyChanged();
}

ThingDescriptor *ThingDiscovery::get(int index) const
{
    if (index < 0 || index >= m_foundThings.count()) {
        return nullptr;
    }
    return m_foundThings.at(index);
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
            beginInsertRows(QModelIndex(), m_foundThings.count(), m_foundThings.count());
            ThingDescriptor *descriptor = new ThingDescriptor(descriptorVariant.toMap().value("id").toUuid(),
                                                   descriptorVariant.toMap().value("thingId").toString(),
                                                   descriptorVariant.toMap().value("title").toString(),
                                                   descriptorVariant.toMap().value("description").toString());
            foreach (const QVariant &paramVariant, descriptorVariant.toMap().value("deviceParams").toList()) {
                qDebug() << "Adding param:" << paramVariant.toMap().value("paramTypeId").toString() << paramVariant.toMap().value("value");
                Param* p = new Param(paramVariant.toMap().value("paramTypeId").toString(), paramVariant.toMap().value("value"));
                descriptor->params()->addParam(p);
            }
            m_foundThings.append(descriptor);
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
    foreach (ThingDescriptor *descriptor, m_foundThings) {
        if (descriptor->id() == deviceDescriptorId) {
            return true;
        }
    }
    return false;
}

ThingDescriptor::ThingDescriptor(const QUuid &id, const QUuid &thingId, const QString &name, const QString &description, QObject *parent):
    QObject(parent),
    m_id(id),
    m_thingId(thingId),
    m_name(name),
    m_description(description),
    m_params(new Params(this))
{

}

QUuid ThingDescriptor::id() const
{
    return m_id;
}

QUuid ThingDescriptor::thingId() const
{
    return m_thingId;
}

QString ThingDescriptor::name() const
{
    return m_name;
}

QString ThingDescriptor::description() const
{
    return m_description;
}

Params* ThingDescriptor::params() const
{
    return m_params;
}

ThingDiscoveryProxy::ThingDiscoveryProxy(QObject *parent):
    QSortFilterProxyModel (parent)
{

}

ThingDiscovery *ThingDiscoveryProxy::thingDiscovery() const
{
    return m_thingDiscovery;
}

void ThingDiscoveryProxy::setThingDiscovery(ThingDiscovery *thingDiscovery)
{
    if (m_thingDiscovery != thingDiscovery) {
        m_thingDiscovery = thingDiscovery;
        setSourceModel(thingDiscovery);
        emit thingDiscoveryChanged();
        emit countChanged();
        connect(m_thingDiscovery, &ThingDiscovery::countChanged, this, &ThingDiscoveryProxy::countChanged);
        invalidateFilter();
    }
}

bool ThingDiscoveryProxy::showAlreadyAdded() const
{
    return m_showAlreadyAdded;
}

void ThingDiscoveryProxy::setShowAlreadyAdded(bool showAlreadyAdded)
{
    if (m_showAlreadyAdded != showAlreadyAdded) {
        m_showAlreadyAdded = showAlreadyAdded;
        emit showAlreadyAddedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingDiscoveryProxy::showNew() const
{
    return m_showNew;
}

void ThingDiscoveryProxy::setShowNew(bool showNew)
{
    if (m_showNew != showNew) {
        m_showNew = showNew;
        emit showNewChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QUuid ThingDiscoveryProxy::filterThingId() const
{
    return m_filterThingId;
}

void ThingDiscoveryProxy::setFilterThingId(const QUuid &filterThingId)
{
    if (m_filterThingId != filterThingId) {
        m_filterThingId = filterThingId;
        emit filterThingIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

ThingDescriptor *ThingDiscoveryProxy::get(int index) const
{
    return m_thingDiscovery->get(mapToSource(this->index(index, 0)).row());
}

bool ThingDiscoveryProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    ThingDescriptor* dev = m_thingDiscovery->get(sourceRow);
    if (!m_showAlreadyAdded && !dev->thingId().isNull()) {
        return false;
    }
    if (!m_showNew && dev->thingId().isNull()) {
        return false;
    }
    if (!m_filterThingId.isNull() && dev->thingId() != m_filterThingId) {
        return false;
    }
    return true;
}
