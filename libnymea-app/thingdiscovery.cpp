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

#include <QMetaEnum>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(dcThingManager)

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

int ThingDiscovery::discoverThings(const QUuid &thingClassId, const QVariantList &discoveryParams)
{
    beginResetModel();
    m_foundThings.clear();
    endResetModel();
    emit countChanged();

    if (!m_engine) {
        qCWarning(dcThingManager()) << "Cannot discover things. No Engine set";
        return -1;
    }
    if (!m_engine->jsonRpcClient()->connected()) {
        qCWarning(dcThingManager()) << "Cannot discover things. Not connected.";
        return -1;
    }

    int commandId = discoverThingsInternal(thingClassId, discoveryParams);
    m_displayMessage.clear();
    emit busyChanged();
    return commandId;
}

QList<int> ThingDiscovery::discoverThingsByInterface(const QString &interfaceName)
{
    beginResetModel();
    m_foundThings.clear();
    endResetModel();
    emit countChanged();

    QList<int> pendingCommands;

    if (!m_engine) {
        qCWarning(dcThingManager()) << "Cannot discover things. No Engine set";
        return pendingCommands;
    }
    if (!m_engine->jsonRpcClient()->connected()) {
        qCWarning(dcThingManager()) << "Cannot discover things. Not connected.";
        return pendingCommands;
    }

    for (int i = 0; i < m_engine->thingManager()->thingClasses()->rowCount(); i++) {
        ThingClass *thingClass = m_engine->thingManager()->thingClasses()->get(i);
        if (!thingClass->interfaces().contains(interfaceName) && !thingClass->providedInterfaces().contains(interfaceName)) {
            continue;
        }
        if (!thingClass->createMethods().contains("CreateMethodDiscovery")) {
            continue;
        }
        pendingCommands.append(discoverThingsInternal(thingClass->id()));
    }

    m_displayMessage.clear();
    emit busyChanged();
    return pendingCommands;
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
    return !m_pendingRequests.isEmpty();
}

QString ThingDiscovery::displayMessage() const
{
    return m_displayMessage;
}

int ThingDiscovery::discoverThingsInternal(const QUuid &thingClassId, const QVariantList &discoveryParams)
{
    qCDebug(dcThingManager()) << "Starting thing discovery for thing class" << m_engine->thingManager()->thingClasses()->getThingClass(thingClassId)->name() << thingClassId;
    QVariantMap params;
    params.insert("thingClassId", thingClassId.toString());
    if (!discoveryParams.isEmpty()) {
        params.insert("discoveryParams", discoveryParams);
    }
    int commandId = m_engine->jsonRpcClient()->sendCommand("Integrations.DiscoverThings", params, this, "discoverThingsResponse");
    m_pendingRequests.append(commandId);
    return commandId;
}

void ThingDiscovery::discoverThingsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcThingManager) << "Discovery response received" << params;
    QVariantList descriptors = params.value("thingDescriptors").toList();
    foreach (const QVariant &descriptorVariant, descriptors) {
        if (!contains(descriptorVariant.toMap().value("id").toUuid())) {
            beginInsertRows(QModelIndex(), m_foundThings.count(), m_foundThings.count());
            ThingDescriptor *descriptor = new ThingDescriptor(descriptorVariant.toMap().value("id").toUuid(),
                                                              descriptorVariant.toMap().value("thingClassId").toUuid(), // Note: This will only be provided as of nymea 0.28!
                                                   descriptorVariant.toMap().value("thingId").toString(),
                                                   descriptorVariant.toMap().value("title").toString(),
                                                   descriptorVariant.toMap().value("description").toString(), this);
            // Work around a bug in nymea:core which didn't properly update deviceParams in the device->things transition
            QVariantList paramList;
            if (descriptorVariant.toMap().contains("params")) {
                paramList = descriptorVariant.toMap().value("params").toList();
            } else {
                paramList = descriptorVariant.toMap().value("deviceParams").toList();
            }
            foreach (const QVariant &paramVariant, paramList) {
                qDebug() << "Adding param:" << paramVariant.toMap().value("paramTypeId").toString() << paramVariant.toMap().value("value");
                Param* p = new Param(paramVariant.toMap().value("paramTypeId").toString(), paramVariant.toMap().value("value"));
                descriptor->params()->addParam(p);
            }
            qCDebug(dcThingManager()) << "Found thing. Descriptor:" << descriptor->name() << descriptor->id();
            m_foundThings.append(descriptor);
            endInsertRows();
            emit countChanged();
        }
    }

    // Note: in case of multiple discoveries we'll just overwrite the message... Not ideal but multiple error messages from different plugins
    // wouldn't be of much use to the user anyways.
    m_displayMessage = params.value("displayMessage").toString();

    QMetaEnum metaEnum = QMetaEnum::fromType<Thing::ThingError>();
    Thing::ThingError thingError = static_cast<Thing::ThingError>(metaEnum.keyToValue(params.value("thingError").toByteArray()));
    emit discoverThingsReply(commandId, thingError, m_displayMessage);

    m_pendingRequests.removeAll(commandId);
    if (m_pendingRequests.isEmpty()) {
        emit busyChanged();
    }
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

ThingDescriptor::ThingDescriptor(const QUuid &id, const QUuid &thingClassId, const QUuid &thingId, const QString &name, const QString &description, QObject *parent):
    QObject(parent),
    m_id(id),
    m_thingClassId(thingClassId),
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

QUuid ThingDescriptor::thingClassId() const
{
    return m_thingClassId;
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
