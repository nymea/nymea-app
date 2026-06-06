// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "thingdiscovery.h"

#include "engine.h"

#include <QMetaEnum>
#include <QJsonDocument>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(dcThingManager)

ThingDiscovery::ThingDiscovery(QObject *parent) :
    QAbstractListModel(parent)
{
}

ThingDiscovery::~ThingDiscovery()
{
    unregisterNotifications();
}

int ThingDiscovery::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_foundThings.count());
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
        if (thingClass->discoveryType() == ThingClass::DiscoveryTypeWeak) {
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
        unregisterNotifications();
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
    qCInfo(dcThingManager()) << "Starting thing discovery for thing class" << m_engine->thingManager()->thingClasses()->getThingClass(thingClassId)->name() << thingClassId;
    if (m_engine->jsonRpcClient()->ensureServerVersion("10.0")) {
        registerNotifications();
    }

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
    qCInfo(dcThingManager) << "Discovery response received for command" << commandId;
    qCDebug(dcThingManager()) << "Discovery response data:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());

    if (m_engine->jsonRpcClient()->ensureServerVersion("10.0") && params.contains("discoveryId")) {
        QUuid discoveryId = params.value("discoveryId").toUuid();
        if (!discoveryId.isNull()) {
            m_pendingDiscoveryIdsByCommandId.insert(commandId, discoveryId);
            m_pendingCommandIdsByDiscoveryId.insert(discoveryId, commandId);
            return;
        }
    }

    QVariantList descriptors = params.value("thingDescriptors").toList();
    foreach (const QVariant &descriptorVariant, descriptors) {
        addThingDescriptor(descriptorVariant.toMap());
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

void ThingDiscovery::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();
    QUuid discoveryId = params.value("discoveryId").toUuid();
    if (!m_pendingCommandIdsByDiscoveryId.contains(discoveryId)) {
        return;
    }

    if (notification == "Integrations.ThingDiscovered") {
        addThingDescriptor(params.value("thingDescriptor").toMap());
        return;
    }

    if (notification == "Integrations.DiscoveryFinished") {
        int commandId = m_pendingCommandIdsByDiscoveryId.take(discoveryId);
        m_pendingDiscoveryIdsByCommandId.remove(commandId);

        m_displayMessage = params.value("displayMessage").toString();

        QMetaEnum metaEnum = QMetaEnum::fromType<Thing::ThingError>();
        Thing::ThingError thingError = static_cast<Thing::ThingError>(metaEnum.keyToValue(params.value("thingError").toByteArray()));
        emit discoverThingsReply(commandId, thingError, m_displayMessage);

        m_pendingRequests.removeAll(commandId);
        if (m_pendingRequests.isEmpty()) {
            emit busyChanged();
        }
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

void ThingDiscovery::addThingDescriptor(const QVariantMap &descriptorMap)
{
    if (contains(descriptorMap.value("id").toUuid())) {
        return;
    }

    beginInsertRows(QModelIndex(), static_cast<int>(m_foundThings.count()), static_cast<int>(m_foundThings.count()));
    ThingDescriptor *descriptor = new ThingDescriptor(descriptorMap.value("id").toUuid(),
                                                      descriptorMap.value("thingClassId").toUuid(), // Note: This will only be provided as of nymea 0.28!
                                                      descriptorMap.value("thingId").toUuid(),
                                                      descriptorMap.value("title").toString(),
                                                      descriptorMap.value("description").toString(), this);
    // Work around a bug in nymea:core which didn't properly update deviceParams in the device->things transition
    QVariantList paramList;
    if (descriptorMap.contains("params")) {
        paramList = descriptorMap.value("params").toList();
    } else {
        paramList = descriptorMap.value("deviceParams").toList();
    }
    foreach (const QVariant &paramVariant, paramList) {
        qDebug() << "Adding param:" << paramVariant.toMap().value("paramTypeId").toString() << paramVariant.toMap().value("value");
        Param* p = new Param(paramVariant.toMap().value("paramTypeId").toUuid(), paramVariant.toMap().value("value"));
        descriptor->params()->addParam(p);
    }
    qCInfo(dcThingManager()) << "Found thing. Descriptor:" << descriptor->name() << descriptor->id();
    m_foundThings.append(descriptor);
    endInsertRows();
    emit countChanged();
}

void ThingDiscovery::registerNotifications()
{
    if (!m_engine || m_notificationsRegistered) {
        return;
    }

    m_engine->jsonRpcClient()->registerNotificationHandler(this, "Integrations", "notificationReceived");
    m_notificationsRegistered = true;
}

void ThingDiscovery::unregisterNotifications()
{
    if (!m_engine || !m_notificationsRegistered) {
        return;
    }

    m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    m_notificationsRegistered = false;
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
