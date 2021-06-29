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

#include "thingmanager.h"
#include "engine.h"
#include "types/browseritems.h"
#include "types/browseritem.h"
#include "thinggroup.h"
#include "types/interface.h"
#include "types/ioconnections.h"

#include <QMetaEnum>
#include <QFile>
#include <QStandardPaths>
#include <QJsonDocument>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcThingManager, "ThingManager")

ThingManager::ThingManager(JsonRpcClient* jsonclient, QObject *parent) :
    QObject(parent),
    m_vendors(new Vendors(this)),
    m_plugins(new Plugins(this)),
    m_things(new Things(this)),
    m_thingClasses(new ThingClasses(this)),
    m_ioConnections(new IOConnections(this)),
    m_jsonClient(jsonclient)
{
    m_jsonClient->registerNotificationHandler(this, "Integrations", "notificationReceived");
}

void ThingManager::clear()
{
    m_things->clearModel();
    m_thingClasses->clearModel();
    m_vendors->clearModel();
    m_plugins->clearModel();
    m_ioConnections->clearModel();
}

void ThingManager::init()
{
    m_connectionBenchmark = QDateTime::currentDateTime();

    m_fetchingData = true;
    emit fetchingDataChanged();

    m_jsonClient->sendCommand("Integrations.GetThingClasses", this, "getThingClassesResponse");
}

Vendors *ThingManager::vendors() const
{
    return m_vendors;
}

Plugins *ThingManager::plugins() const
{
    return m_plugins;
}

Things *ThingManager::things() const
{
    return m_things;
}

ThingClasses *ThingManager::thingClasses() const
{
    return m_thingClasses;
}

IOConnections *ThingManager::ioConnections() const
{
    return m_ioConnections;
}

bool ThingManager::fetchingData() const
{
    return m_fetchingData;
}

int ThingManager::addThing(const QUuid &thingClassId, const QString &name, const QVariantList &thingParams)
{
    QVariantMap params;
    params.insert("thingClassId", thingClassId.toString());
    params.insert("name", name);
    params.insert("thingParams", thingParams);
    return m_jsonClient->sendCommand("Integrations.AddThing", params, this, "addThingResponse");
}

void ThingManager::notificationReceived(const QVariantMap &data)
{
    qCDebug(dcThingManager()) << "ThingManager notifications received:" << qUtf8Printable(QJsonDocument::fromVariant(data).toJson());
    QString notification = data.value("notification").toString();
    if (notification == "Integrations.StateChanged") {
        Thing *thing = m_things->getThing(data.value("params").toMap().value("thingId").toUuid());
        if (!thing) {
            if (!m_fetchingData) {
                qCWarning(dcThingManager()) << "Thing state change notification received for an unknown thing";
            }
            return;
        }
        QUuid stateTypeId = data.value("params").toMap().value("stateTypeId").toUuid();
        QVariant value = data.value("params").toMap().value("value");
//        qDebug() << "Thing state changed for:" << dev->name() << "State name:" << dev->thingClass()->stateTypes()->getStateType(stateTypeId) << "value:" << value;
        thing->setStateValue(stateTypeId, value);
        emit thingStateChanged(thing->id(), stateTypeId, value);
    } else if (notification == "Integrations.ThingAdded") {
        Thing *thing = unpackThing(this, data.value("params").toMap().value("thing").toMap(), m_thingClasses);
        if (!thing) {
            qWarning() << "Cannot parse thing json:" << data;
            return;
        }
        ThingClass *thingClass = thingClasses()->getThingClass(thing->thingClassId());
        if (!thingClass) {
            qCWarning(dcThingManager()) << "Skipping invalid thing. Don't have a thing class for it";
            delete thing;
            return;
        }
        qCInfo(dcThingManager()) << "A new thing has been added" << thing->name() << thing->id().toString();
        m_things->addThing(thing);
        emit thingAdded(thing);
    } else if (notification == "Integrations.ThingRemoved") {
        QUuid thingId = data.value("params").toMap().value("thingId").toUuid();
//        qDebug() << "JsonRpc: Notification: Thing removed" << thingId.toString();
        Thing *thing = m_things->getThing(thingId);
        if (!thing) {
            qWarning() << "Received a ThingRemoved notification for a thing we don't know!";
            return;
        }
        m_things->removeThing(thing);
        emit thingRemoved(thing);
        thing->deleteLater();
    } else if (notification == "Integrations.ThingChanged") {
        QUuid thingId = data.value("params").toMap().value("thing").toMap().value("id").toUuid();
        qCDebug(dcThingManager()) << "Thing changed notification" << thingId << data.value("params").toMap();
        Thing *oldThing = m_things->getThing(thingId);
        if (!oldThing) {
            qWarning() << "Received a thing changed notification for a thing we don't know";
            return;
        }
        if (!unpackThing(this, data.value("params").toMap().value("thing").toMap(), m_thingClasses, oldThing)) {
            qWarning() << "Error parsing thing changed notification" << data;
            return;
        }
    } else if (notification == "Integrations.ThingSettingChanged") {
        QUuid thingId = data.value("params").toMap().value("thingId").toUuid();
        QString paramTypeId = data.value("params").toMap().value("paramTypeId").toString();
        QVariant value = data.value("params").toMap().value("value");
//        qDebug() << "Thing settings changed notification for thing" << thingId << data.value("params").toMap().value("settings").toList();
        Thing *thing = m_things->getThing(thingId);
        if (!thing) {
            qWarning() << "Thing settings changed notification for a thing we don't know" << thingId.toString();
            return;
        }
        Param *p = thing->settings()->getParam(paramTypeId);
        if (!p) {
            qWarning() << "Thing" << thing->name() << thing->id().toString() << "does not have a setting of id" << paramTypeId;
            return;
        }
        p->setValue(value);
    } else if (notification == "Integrations.EventTriggered") {
        QVariantMap event = data.value("params").toMap().value("event").toMap();
        QUuid thingId = event.value("thingId").toUuid();
        QUuid eventTypeId = event.value("eventTypeId").toUuid();

        Thing *thing = m_things->getThing(thingId);
        if (!thing) {
            if (!m_fetchingData) {
                qCWarning(dcThingManager()) << "received an event from a thing we don't know..." << thingId << qUtf8Printable(QJsonDocument::fromVariant(data).toJson());
            }
            return;
        }
        qCDebug(dcThingManager) << "Event received" << thingId.toString() << eventTypeId.toString() << qUtf8Printable(QJsonDocument::fromVariant(event).toJson());
        thing->eventTriggered(eventTypeId.toString(), event.value("params").toList());
    } else if (notification == "Integrations.IOConnectionAdded") {
        QVariantMap connectionMap = data.value("params").toMap().value("ioConnection").toMap();
        QUuid id = connectionMap.value("id").toUuid();
        QUuid inputThingId = connectionMap.value("inputThingId").toUuid();
        QUuid inputStateTypeId = connectionMap.value("inputStateTypeId").toUuid();
        QUuid outputThingId = connectionMap.value("outputThingId").toUuid();
        QUuid outputStateTypeId = connectionMap.value("outputStateTypeId").toUuid();
        bool inverted = connectionMap.value("inverted").toBool();
        IOConnection *ioConnection = new IOConnection(id, inputThingId, inputStateTypeId, outputThingId, outputStateTypeId, inverted);
        m_ioConnections->addIOConnection(ioConnection);
    } else if (notification == "Integrations.IOConnectionRemoved") {
        QUuid connectionId = data.value("params").toMap().value("ioConnectionId").toUuid();
        if (!m_ioConnections->getIOConnection(connectionId)) {
            qWarning() << "Received an IO connection removed event for an IO connection we don't know.";
            return;
        }
        m_ioConnections->removeIOConnection(connectionId);
    } else {
        qWarning() << "ThingManager unhandled thing notification received" << notification;
    }
}

void ThingManager::getVendorsResponse(int /*commandId*/, const QVariantMap &params)
{
//    qDebug() << "Got GetSupportedVendors response" << params;
    if (params.keys().contains("vendors")) {
        QVariantList vendorList = params.value("vendors").toList();
        foreach (QVariant vendorVariant, vendorList) {
            Vendor *vendor = unpackVendor(vendorVariant.toMap());
            m_vendors->addVendor(vendor);
//            qDebug() << "Added Vendor:" << vendor->name();
        }
    }
}

void ThingManager::getThingClassesResponse(int /*commandId*/, const QVariantMap &params)
{
    if (params.keys().contains("thingClasses")) {
        QVariantList thingClassList = params.value("thingClasses").toList();
        foreach (QVariant thingClassVariant, thingClassList) {
            ThingClass *thingClass = unpackThingClass(thingClassVariant.toMap());
            m_thingClasses->addThingClass(thingClass);
        }
    }
    m_jsonClient->sendCommand("Integrations.GetThings", this, "getThingsResponse");
}

void ThingManager::getPluginsResponse(int /*commandId*/, const QVariantMap &params)
{
//    qDebug() << "received plugins";
    if (params.keys().contains("plugins")) {
        QVariantList pluginList = params.value("plugins").toList();
        foreach (QVariant pluginVariant, pluginList) {
            Plugin *plugin = unpackPlugin(pluginVariant.toMap(), plugins());
            m_plugins->addPlugin(plugin);
        }
    }
    m_jsonClient->sendCommand("Integrations.GetVendors", this, "getVendorsResponse");

    if (m_plugins->count() > 0) {
        m_currentGetConfigIndex = 0;
        QVariantMap configRequestParams;
        configRequestParams.insert("pluginId", m_plugins->get(m_currentGetConfigIndex)->pluginId());
        m_jsonClient->sendCommand("Integrations.GetPluginConfiguration", configRequestParams, this, "getPluginConfigResponse");
    }
}

void ThingManager::getPluginConfigResponse(int /*commandId*/, const QVariantMap &params)
{
//    qDebug() << "plugin config response" << params;
    Plugin *p = m_plugins->get(m_currentGetConfigIndex);
    if (!p) {
        qDebug() << "Received a plugin config for a plugin we don't know";
        return;
    }
    QVariantList pluginParams = params.value("configuration").toList();
    foreach (const QVariant &paramVariant, pluginParams) {
        Param* param = new Param();
        unpackParam(paramVariant.toMap(), param);
        p->params()->addParam(param);
    }

    m_currentGetConfigIndex++;
    if (m_plugins->count() > m_currentGetConfigIndex) {
        QVariantMap configRequestParams;
        configRequestParams.insert("pluginId", m_plugins->get(m_currentGetConfigIndex)->pluginId());
        m_jsonClient->sendCommand("Integrations.GetPluginConfiguration", configRequestParams, this, "getPluginConfigResponse");
    }
}

void ThingManager::getThingsResponse(int /*commandId*/, const QVariantMap &params)
{
//    qDebug() << "Things received:" << params;
    if (params.keys().contains("things")) {
        QVariantList thingsList = params.value("things").toList();
        foreach (QVariant thingVariant, thingsList) {
            Thing *thing = unpackThing(this, thingVariant.toMap(), m_thingClasses);
            if (!thing) {
                qWarning() << "Error unpacking thing" << thingVariant.toMap().value("name").toString();
                continue;
            }

            // set initial state values
            QVariantList stateVariantList = thingVariant.toMap().value("states").toList();
            foreach (const QVariant &stateMap, stateVariantList) {
                QString stateTypeId = stateMap.toMap().value("stateTypeId").toString();
                StateType *st = thing->thingClass()->stateTypes()->getStateType(stateTypeId);
                if (!st) {
                    qWarning() << "Can't find a statetype for this state";
                    continue;
                }
                QVariant value = stateMap.toMap().value("value");
                if (st->type() == "Bool") {
                    value.convert(QVariant::Bool);
                } else if (st->type() == "Double") {
                    value.convert(QVariant::Double);
                } else if (st->type() == "Int") {
                    value.convert(QVariant::Int);
                }
                thing->setStateValue(stateTypeId, value);
//                qDebug() << "Set thing state value:" << thing->stateValue(stateTypeId) << value;
            }
            things()->addThing(thing);
        }
    }
    qDebug() << "Initializing thing manager took" << m_connectionBenchmark.msecsTo(QDateTime::currentDateTime()) << "ms";
    m_fetchingData = false;
    emit fetchingDataChanged();

    m_jsonClient->sendCommand("Integrations.GetIOConnections", this, "getIOConnectionsResponse");

    m_jsonClient->sendCommand("Integrations.GetPlugins", this, "getPluginsResponse");
}

void ThingManager::addThingResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Error from string:" << errorFromString(params.value("thingError").toByteArray()) << params.value("thingError");
    emit addThingReply(commandId, errorFromString(params.value("thingError").toByteArray()), params.value("thingId").toUuid(), params.value("displayMessage").toString());

    if (params.value("thingError").toString() != "ThingErrorNoError") {
        qWarning() << "Failed to add thing:" << params.value("thingError").toString();
    } else if (params.keys().contains("thing")) {
        QVariantMap thingVariant = params.value("thing").toMap();
        Thing *thing = unpackThing(this, thingVariant, m_thingClasses);
        if (!thing) {
            qWarning() << "Couldn't parse json in addThingResponse";
            return;
        }

        qCInfo(dcThingManager()) << "Thing successfully added" << thing->name() << thing->id().toString();
        m_things->addThing(thing);
    }
}

void ThingManager::removeThingResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Thing removed response" << params;
    emit removeThingReply(commandId, errorFromString(params.value("thingError").toByteArray()), params.value("ruleIds").toStringList());
}

void ThingManager::pairThingResponse(int commandId, const QVariantMap &params)
{
    emit pairThingReply(commandId,
                        errorFromString(params.value("thingError").toByteArray()),
                        params.value("pairingTransactionId").toUuid(),
                        params.value("setupMethod").toString(),
                        params.value("displayMessage").toString(),
                        params.value("oAuthUrl").toString());
}

void ThingManager::confirmPairingResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "ConfirmPairingResponse" << params;
    emit confirmPairingReply(commandId, errorFromString(params.value("thingError").toByteArray()), params.value("thingId").toUuid(), params.value("displayMessage").toString());
}

void ThingManager::setPluginConfigResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "set plugin config response" << params;
    emit savePluginConfigReply(commandId, errorFromString(params.value("thingError").toByteArray()));
}

void ThingManager::editThingResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Edit thing response" << params;
    emit editThingReply(commandId, errorFromString(params.value("thingError").toByteArray()));
}

void ThingManager::executeActionResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcThingManager()) << "Execute Action response" << params;
    emit executeActionReply(commandId, errorFromString(params.value("thingError").toByteArray()), params.value("displayMessage").toString());
}

void ThingManager::reconfigureThingResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Reconfigure device response" << params;
    emit reconfigureThingReply(commandId, errorFromString(params.value("thingError").toByteArray()), params.value("displayMessage").toString());
}

int ThingManager::savePluginConfig(const QUuid &pluginId)
{
    Plugin *p = m_plugins->getPlugin(pluginId);
    if (!p) {
        qWarning()<< "Error: can't find plugin with id" << pluginId;
        return -1;
    }
    QVariantMap params;
    params.insert("pluginId", pluginId);
    QVariantList pluginParams;
    for (int i = 0; i < p->params()->rowCount(); i++) {
        pluginParams.append(packParam(p->params()->get(i)));
    }
    params.insert("configuration", pluginParams);
    return m_jsonClient->sendCommand("Integrations.SetPluginConfiguration", params, this, "setPluginConfigResponse");
}

ThingGroup *ThingManager::createGroup(Interface *interface, ThingsProxy *things)
{
    ThingGroup* group = new ThingGroup(this, interface->createThingClass(), things, this);
    group->setSetupStatus(Thing::ThingSetupStatusComplete, QString());
    return group;
}

int ThingManager::addDiscoveredThing(const QUuid &thingClassId, const QUuid &thingDescriptorId, const QString &name, const QVariantList &thingParams)
{
    QVariantMap params;
    params.insert("name", name);
    params.insert("thingClassId", thingClassId);
    params.insert("thingDescriptorId", thingDescriptorId.toString());
    params.insert("thingParams", thingParams);
    return m_jsonClient->sendCommand("Integrations.AddThing", params, this, "addThingResponse");
}

int ThingManager::pairDiscoveredThing(const QUuid &thingDescriptorId, const QVariantList &thingParams, const QString &name)
{
    QVariantMap params;
    params.insert("thingDescriptorId", thingDescriptorId.toString());
    params.insert("thingParams", thingParams);
    params.insert("name", name);

    return m_jsonClient->sendCommand("Integrations.PairThing", params, this, "pairThingResponse");
}

int ThingManager::pairThing(const QUuid &thingClassId, const QVariantList &thingParams, const QString &name)
{
    QVariantMap params;
    params.insert("thingClassId", thingClassId.toString());
    params.insert("thingParams", thingParams);
    params.insert("name", name);
    return m_jsonClient->sendCommand("Integrations.PairThing", params, this, "pairThingResponse");
}

int ThingManager::rePairThing(const QUuid &thingId, const QVariantList &thingParams, const QString &name)
{
    qDebug() << "JsonRpc: pair thing (reconfigure)" << thingId;
    QVariantMap params;
    params.insert("thingId", thingId.toString());
    params.insert("thingParams", thingParams);
    if (!name.isEmpty()) {
        params.insert("name", name);
    }
    return m_jsonClient->sendCommand("Things.PairThing", params, this, "pairThingResponse");
}

int ThingManager::confirmPairing(const QUuid &pairingTransactionId, const QString &secret, const QString &username)
{
    qDebug() << "JsonRpc: confirm pairing" << pairingTransactionId.toString();
    QVariantMap params;
    params.insert("pairingTransactionId", pairingTransactionId.toString());
    params.insert("secret", secret);
    if (!username.isEmpty()) {
        params.insert("username", username);
    }
    return m_jsonClient->sendCommand("Integrations.ConfirmPairing", params, this, "confirmPairingResponse");
}

int ThingManager::removeThing(const QUuid &thingId, ThingManager::RemovePolicy policy)
{
    qDebug() << "JsonRpc: remove thing" << thingId.toString();
    QVariantMap params;
    params.insert("thingId", thingId.toString());
    if (policy != RemovePolicyNone) {
        QMetaEnum policyEnum = QMetaEnum::fromType<ThingManager::RemovePolicy>();
        params.insert("removePolicy", policyEnum.valueToKey(policy));
    }
    return m_jsonClient->sendCommand("Integrations.RemoveThing", params, this, "removeThingResponse");
}

int ThingManager::editThing(const QUuid &thingId, const QString &name)
{
    QVariantMap params;
    params.insert("thingId", thingId.toString());
    params.insert("name", name);
    return m_jsonClient->sendCommand("Integrations.EditThing", params, this, "editThingResponse");
}

int ThingManager::setThingSettings(const QUuid &thingId, const QVariantList &settings)
{
    QVariantMap params;
    params.insert("thingId", thingId);
    params.insert("settings", settings);
    return m_jsonClient->sendCommand("Integrations.SetThingSettings", params);
}

int ThingManager::reconfigureThing(const QUuid &thingId, const QVariantList &thingParams)
{
    QVariantMap params;
    params.insert("thingId", thingId.toString());
    params.insert("thingParams", thingParams);
    return m_jsonClient->sendCommand("Integrations.ReconfigureThing", params, this, "reconfigureThingResponse");
}

int ThingManager::reconfigureDiscoveredThing(const QUuid &thingDescriptorId, const QVariantList &paramOverride)
{
    QVariantMap params;
    params.insert("thingDescriptorId", thingDescriptorId);
    if (!paramOverride.isEmpty()) {
        params.insert("thingParams", paramOverride);
    }
    return m_jsonClient->sendCommand("Integrations.ReconfigureThing", params, this, "reconfigureThingResponse");
}

int ThingManager::executeAction(const QUuid &thingId, const QUuid &actionTypeId, const QVariantList &params)
{
    QVariantMap p;
    p.insert("thingId", thingId.toString());
    p.insert("actionTypeId", actionTypeId.toString());
    if (!params.isEmpty()) {
        p.insert("params", params);
    }

    qCDebug(dcThingManager()) << "Executing action" << thingId << actionTypeId;
    return m_jsonClient->sendCommand("Integrations.ExecuteAction", p, this, "executeActionResponse");
}

BrowserItems *ThingManager::browseThing(const QUuid &thingId, const QString &itemId)
{
    QVariantMap params;
    params.insert("thingId", thingId.toString());
    params.insert("itemId", itemId);
    int id = m_jsonClient->sendCommand("Integrations.BrowseThing", params, this, "browseThingResponse");

    // Intentionally not parented. The caller takes ownership and needs to destroy when not needed any more.
    BrowserItems *itemModel = new BrowserItems(thingId, itemId);
    itemModel->setBusy(true);
    QPointer<BrowserItems> itemModelPtr(itemModel);
    m_browsingRequests.insert(id, itemModelPtr);

    return itemModel;
}

void ThingManager::refreshBrowserItems(BrowserItems *browserItems)
{
    QVariantMap params;
    params.insert("thingId", browserItems->thingId().toString());
    params.insert("itemId", browserItems->itemId());
    int id = m_jsonClient->sendCommand("Integrations.BrowseThing", params, this, "browseThingResponse");

    // Intentionally not parented. The caller takes ownership and needs to destroy when not needed any more.
    browserItems->setBusy(true);
    QPointer<BrowserItems> itemModelPtr(browserItems);
    m_browsingRequests.insert(id, browserItems);
}

BrowserItem *ThingManager::browserItem(const QUuid &thingId, const QString &itemId)
{
    QVariantMap params;
    params.insert("thingId", thingId.toString());
    params.insert("itemId", itemId);
    int id = m_jsonClient->sendCommand("Integrations.GetBrowserItem", params, this, "browserItemResponse");

    // Intentionally not parented. The caller takes ownership and needs to destroy when not needed any more.
    BrowserItem *item = new BrowserItem(itemId);
    QPointer<BrowserItem> itemPtr(item);
    m_browserDetailsRequests.insert(id, itemPtr);

    return item;
}

void ThingManager::browseThingResponse(int commandId, const QVariantMap &params)
{
//    qDebug() << "Browsing response:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    if (!m_browsingRequests.contains(commandId)) {
        qWarning() << "Received a browsing reply for an id we don't know.";
        return;
    }

    QPointer<BrowserItems> itemModel = m_browsingRequests.take(commandId);
    if (!itemModel) {
        qDebug() << "BrowserItems model seems to have disappeared. Discarding browsing result.";
        return;
    }

    QList<BrowserItem*> itemsToRemove = itemModel->list();

    foreach (const QVariant &itemVariant, params.value("items").toList()) {
        QVariantMap itemMap = itemVariant.toMap();
        QString itemId = itemMap.value("id").toString();
        BrowserItem *item = itemModel->getBrowserItem(itemId);
        if (!item) {
            item = new BrowserItem(itemId, this);
            itemModel->addBrowserItem(item);
        }
        item->setDisplayName(itemMap.value("displayName").toString());
        item->setDescription(itemMap.value("description").toString());
        item->setIcon(itemMap.value("icon").toString());
        item->setThumbnail(itemMap.value("thumbnail").toString());
        item->setExecutable(itemMap.value("executable").toBool());
        item->setBrowsable(itemMap.value("browsable").toBool());
        item->setDisabled(itemMap.value("disabled").toBool());
        item->setActionTypeIds(itemMap.value("actionTypeIds").toStringList());

        item->setMediaIcon(itemMap.value("mediaIcon").toString());

        if (itemsToRemove.contains(item)) {
            itemsToRemove.removeAll(item);
        }
    }

    while (!itemsToRemove.isEmpty()) {
        BrowserItem *item = itemsToRemove.takeFirst();
        itemModel->removeItem(item);
    }

    itemModel->setBusy(false);
}

void ThingManager::browserItemResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Browser item details response:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    if (!m_browserDetailsRequests.contains(commandId)) {
        qWarning() << "Received a browser item details reply for an id we don't know.";
        return;
    }

    QPointer<BrowserItem> item = m_browserDetailsRequests.take(commandId);
    if (!item) {
        qDebug() << "BrowserItem seems to have disappeared. Discarding browser item details result.";
        return;
    }

    QVariantMap itemMap = params.value("item").toMap();
    item->setDisplayName(itemMap.value("displayName").toString());
    item->setDescription(itemMap.value("description").toString());
    item->setIcon(itemMap.value("icon").toString());
    item->setThumbnail(itemMap.value("thumbnail").toString());
    item->setExecutable(itemMap.value("executable").toBool());
    item->setBrowsable(itemMap.value("browsable").toBool());
    item->setDisabled(itemMap.value("disabled").toBool());
    item->setActionTypeIds(itemMap.value("actionTypeIds").toStringList());

    item->setMediaIcon(itemMap.value("mediaIcon").toString());
}

int ThingManager::executeBrowserItem(const QUuid &thingId, const QString &itemId)
{
    QVariantMap params;
    params.insert("thingId", thingId);
    params.insert("itemId", itemId);
    return m_jsonClient->sendCommand("Integrations.ExecuteBrowserItem", params, this, "executeBrowserItemResponse");
}

void ThingManager::executeBrowserItemResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Execute Browser Item finished" << params;
    emit executeBrowserItemReply(commandId, errorFromString(params.value("thingError").toByteArray()), params.value("displayMessage").toString());
}

int ThingManager::executeBrowserItemAction(const QUuid &thingId, const QString &itemId, const QUuid &actionTypeId, const QVariantList &params)
{
    QVariantMap data;
    data.insert("thingId", thingId);
    data.insert("itemId", itemId);
    data.insert("actionTypeId", actionTypeId);
    data.insert("params", params);
    qDebug() << "params:" << params;
    return m_jsonClient->sendCommand("Integrations.ExecuteBrowserItemAction", data, this, "executeBrowserItemActionResponse");
}

int ThingManager::connectIO(const QUuid &inputThingId, const QUuid &inputStateTypeId, const QUuid &outputThingId, const QUuid &outputStateTypeId, bool inverted)
{
    QVariantMap data;
    data.insert("inputThingId", inputThingId);
    data.insert("inputStateTypeId", inputStateTypeId);
    data.insert("outputThingId", outputThingId);
    data.insert("outputStateTypeId", outputStateTypeId);
    data.insert("inverted", inverted);
    return m_jsonClient->sendCommand("Integrations.ConnectIO", data, this, "connectIOResponse");
}

int ThingManager::disconnectIO(const QUuid &ioConnectionId)
{
    QVariantMap data;
    data.insert("ioConnectionId", ioConnectionId);
    return m_jsonClient->sendCommand("Integrations.DisconnectIO", data, this, "disconnectIOResponse");
}

void ThingManager::executeBrowserItemActionResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Execute Browser Item Action finished" << params;
    emit executeBrowserItemActionReply(commandId, errorFromString(params.value("thingError").toByteArray()), params.value("displayMessage").toString());
}

void ThingManager::getIOConnectionsResponse(int /*commandId*/, const QVariantMap &params)
{
//    qDebug() << "Get IO connections response" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());

    foreach (const QVariant &connectionVariant, params.value("ioConnections").toList()) {
        QVariantMap connectionMap = connectionVariant.toMap();
        QUuid id = connectionMap.value("id").toUuid();
        QUuid inputThingId = connectionMap.value("inputThingId").toUuid();
        QUuid inputStateTypeId = connectionMap.value("inputStateTypeId").toUuid();
        QUuid outputThingId = connectionMap.value("outputThingId").toUuid();
        QUuid outputStateTypeId = connectionMap.value("outputStateTypeId").toUuid();
        bool inverted = connectionMap.value("inverted").toBool();
        IOConnection *ioConnection = new IOConnection(id, inputThingId, inputStateTypeId, outputThingId, outputStateTypeId, inverted);
        m_ioConnections->addIOConnection(ioConnection);
    }
}

void ThingManager::connectIOResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "ConnectIO response" << commandId << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
}

void ThingManager::disconnectIOResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "DisconnectIO response" << commandId << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
}

Vendor *ThingManager::unpackVendor(const QVariantMap &vendorMap)
{
    Vendor *v = new Vendor(vendorMap.value("id").toString(), vendorMap.value("name").toString());
    v->setDisplayName(vendorMap.value("displayName").toString());
    return v;
}

Plugin *ThingManager::unpackPlugin(const QVariantMap &pluginMap, QObject *parent)
{
    Plugin *plugin = new Plugin(parent);
    plugin->setName(pluginMap.value("name").toString());
    plugin->setPluginId(pluginMap.value("id").toUuid());
    ParamTypes *paramTypes = new ParamTypes(plugin);
    foreach (QVariant paramType, pluginMap.value("paramTypes").toList()) {
        paramTypes->addParamType(unpackParamType(paramType.toMap(), paramTypes));
    }
    plugin->setParamTypes(paramTypes);
    return plugin;
}

ThingClass *ThingManager::unpackThingClass(const QVariantMap &thingClassMap)
{
    ThingClass *thingClass = new ThingClass();
    thingClass->setName(thingClassMap.value("name").toString());
    thingClass->setDisplayName(thingClassMap.value("displayName").toString());
    thingClass->setId(thingClassMap.value("id").toUuid());
    thingClass->setVendorId(thingClassMap.value("vendorId").toUuid());
    thingClass->setBrowsable(thingClassMap.value("browsable").toBool());
    QVariantList createMethodsList = thingClassMap.value("createMethods").toList();
    QStringList createMethods;
    foreach (QVariant method, createMethodsList) {
        createMethods.append(method.toString());
    }
    thingClass->setCreateMethods(createMethods);
    thingClass->setSetupMethod(stringToSetupMethod(thingClassMap.value("setupMethod").toString()));
    thingClass->setInterfaces(thingClassMap.value("interfaces").toStringList());

    // ParamTypes
    ParamTypes *paramTypes = new ParamTypes(thingClass);
    foreach (QVariant paramType, thingClassMap.value("paramTypes").toList()) {
        paramTypes->addParamType(unpackParamType(paramType.toMap(), paramTypes));
    }
    thingClass->setParamTypes(paramTypes);

    // SettingsTypes
    ParamTypes *settingsTypes = new ParamTypes(thingClass);
    foreach (QVariant settingsType, thingClassMap.value("settingsTypes").toList()) {
        settingsTypes->addParamType(unpackParamType(settingsType.toMap(), settingsTypes));
    }
    thingClass->setSettingsTypes(settingsTypes);

    // discovery ParamTypes
    ParamTypes *discoveryParamTypes = new ParamTypes(thingClass);
    foreach (QVariant paramType, thingClassMap.value("discoveryParamTypes").toList()) {
        discoveryParamTypes->addParamType(unpackParamType(paramType.toMap(), discoveryParamTypes));
    }
    thingClass->setDiscoveryParamTypes(discoveryParamTypes);

    // StateTypes
    StateTypes *stateTypes = new StateTypes(thingClass);
    foreach (QVariant stateType, thingClassMap.value("stateTypes").toList()) {
        stateTypes->addStateType(unpackStateType(stateType.toMap(), stateTypes));
    }
    thingClass->setStateTypes(stateTypes);

    // EventTypes
    EventTypes *eventTypes = new EventTypes(thingClass);
    foreach (QVariant eventType, thingClassMap.value("eventTypes").toList()) {
        eventTypes->addEventType(unpackEventType(eventType.toMap(), eventTypes));
    }
    thingClass->setEventTypes(eventTypes);

    // ActionTypes
    ActionTypes *actionTypes = new ActionTypes(thingClass);
    foreach (QVariant actionType, thingClassMap.value("actionTypes").toList()) {
        actionTypes->addActionType(unpackActionType(actionType.toMap(), actionTypes));
    }
    thingClass->setActionTypes(actionTypes);

    // BrowserItemActionTypes
    ActionTypes *browserItemActionTypes = new ActionTypes(thingClass);
    foreach (QVariant actionType, thingClassMap.value("browserItemActionTypes").toList()) {
        browserItemActionTypes->addActionType(unpackActionType(actionType.toMap(), actionTypes));
    }
    thingClass->setBrowserItemActionTypes(browserItemActionTypes);

    return thingClass;
}

void ThingManager::unpackParam(const QVariantMap &paramMap, Param *param)
{
    param->setParamTypeId(paramMap.value("paramTypeId").toString());
    param->setValue(paramMap.value("value"));
}

ParamType *ThingManager::unpackParamType(const QVariantMap &paramTypeMap, QObject *parent)
{
    ParamType *paramType = new ParamType(parent);
    paramType->setId(paramTypeMap.value("id").toString());
    paramType->setName(paramTypeMap.value("name").toString());
    paramType->setDisplayName(paramTypeMap.value("displayName").toString());
    paramType->setType(paramTypeMap.value("type").toString());
    paramType->setIndex(paramTypeMap.value("index").toInt());
    paramType->setDefaultValue(paramTypeMap.value("defaultValue"));
    paramType->setMinValue(paramTypeMap.value("minValue"));
    paramType->setMaxValue(paramTypeMap.value("maxValue"));
    paramType->setAllowedValues(paramTypeMap.value("allowedValues").toList());
    paramType->setInputType(stringToInputType(paramTypeMap.value("inputType").toString()));
    paramType->setReadOnly(paramTypeMap.value("readOnly").toBool());
    QPair<Types::Unit, QString> unit = stringToUnit(paramTypeMap.value("unit").toString());
    paramType->setUnit(unit.first);
    paramType->setUnitString(unit.second);
    return paramType;
}

StateType *ThingManager::unpackStateType(const QVariantMap &stateTypeMap, QObject *parent)
{
    StateType *stateType = new StateType(parent);
    stateType->setId(stateTypeMap.value("id").toString());
    stateType->setName(stateTypeMap.value("name").toString());
    stateType->setDisplayName(stateTypeMap.value("displayName").toString());
    stateType->setIndex(stateTypeMap.value("index").toInt());
    stateType->setDefaultValue(stateTypeMap.value("defaultValue"));
    stateType->setAllowedValues(stateTypeMap.value("possibleValues").toList());
    stateType->setType(stateTypeMap.value("type").toString());
    stateType->setMinValue(stateTypeMap.value("minValue"));
    stateType->setMaxValue(stateTypeMap.value("maxValue"));

    QPair<Types::Unit, QString> unit = stringToUnit(stateTypeMap.value("unit").toString());
    stateType->setUnit(unit.first);
    stateType->setUnitString(unit.second);

    QMetaEnum metaEnum = QMetaEnum::fromType<Types::IOType>();
    Types::IOType ioType = static_cast<Types::IOType>(metaEnum.keyToValue(stateTypeMap.value("ioType").toByteArray()));
    stateType->setIOType(ioType);

    return stateType;
}

EventType *ThingManager::unpackEventType(const QVariantMap &eventTypeMap, QObject *parent)
{
    EventType *eventType = new EventType(parent);
    eventType->setId(eventTypeMap.value("id").toString());
    eventType->setName(eventTypeMap.value("name").toString());
    eventType->setDisplayName(eventTypeMap.value("displayName").toString());
    eventType->setIndex(eventTypeMap.value("index").toInt());
    ParamTypes *paramTypes = new ParamTypes(eventType);
    foreach (QVariant paramType, eventTypeMap.value("paramTypes").toList()) {
        paramTypes->addParamType(unpackParamType(paramType.toMap(), paramTypes));
    }
    eventType->setParamTypes(paramTypes);
    return eventType;
}

ActionType *ThingManager::unpackActionType(const QVariantMap &actionTypeMap, QObject *parent)
{
    ActionType *actionType = new ActionType(parent);
    actionType->setId(actionTypeMap.value("id").toString());
    actionType->setName(actionTypeMap.value("name").toString());
    actionType->setDisplayName(actionTypeMap.value("displayName").toString());
    actionType->setIndex(actionTypeMap.value("index").toInt());
    ParamTypes *paramTypes = new ParamTypes(actionType);
    foreach (QVariant paramType, actionTypeMap.value("paramTypes").toList()) {
        paramTypes->addParamType(unpackParamType(paramType.toMap(), paramTypes));
    }
    actionType->setParamTypes(paramTypes);
    return actionType;
}

Thing* ThingManager::unpackThing(ThingManager *thingManager, const QVariantMap &thingMap, ThingClasses *thingClasses, Thing *oldThing)
{
    QUuid thingClassId = thingMap.value("thingClassId").toUuid();
    ThingClass *thingClass = thingClasses->getThingClass(thingClassId);
    if (!thingClass) {
        qWarning() << "Cannot find a thing class for this thing";
        return nullptr;
    }

    QUuid parentId = thingMap.value("parentId").toUuid();
    Thing *thing = nullptr;
    if (oldThing) {
        thing = oldThing;
    } else {
        thing = new Thing(thingManager, thingClass, parentId);
    }
    thing->setName(thingMap.value("name").toString());
    thing->setId(thingMap.value("id").toUuid());
    // As of JSONRPC 4.2 setupComplete is deprecated and setupStatus is new
    if (thingMap.contains("setupStatus")) {
        QString setupStatus = thingMap.value("setupStatus").toString();
        QString setupDisplayMessage = thingMap.value("setupDisplayMessage").toString();
        if (setupStatus == "ThingSetupStatusNone") {
            thing->setSetupStatus(Thing::ThingSetupStatusNone, setupDisplayMessage);
        } else if (setupStatus == "ThingSetupStatusInProgress") {
            thing->setSetupStatus(Thing::ThingSetupStatusInProgress, setupDisplayMessage);
        } else if (setupStatus == "ThingSetupStatusComplete") {
            thing->setSetupStatus(Thing::ThingSetupStatusComplete, setupDisplayMessage);
        } else if (setupStatus == "ThingSetupStatusFailed") {
            thing->setSetupStatus(Thing::ThingSetupStatusFailed, setupDisplayMessage);
        }
    } else {
        thing->setSetupStatus(thingMap.value("setupComplete").toBool() ? Thing::ThingSetupStatusComplete : Thing::ThingSetupStatusNone, QString());
    }

    Params *params = thing->params();
    if (!params) {
        params = new Params(thing);
    }
    foreach (QVariant param, thingMap.value("params").toList()) {
        Param *p = params->getParam(param.toMap().value("paramTypeId").toString());
        if (!p) {
            p = new Param();
            params->addParam(p);
        }
        unpackParam(param.toMap(), p);
    }
    thing->setParams(params);

    Params *settings = thing->settings();
    if (!settings) {
        settings = new Params(thing);
    }
    foreach (QVariant setting, thingMap.value("settings").toList()) {
        Param *p = settings->getParam(setting.toMap().value("paramTypeId").toString());
        if (!p) {
            p = new Param();
            settings->addParam(p);
        }
        unpackParam(setting.toMap(), p);
    }
    thing->setSettings(settings);

    States *states = thing->states();
    if (!states) {
        states = new States(thing);
    }
    foreach (const QVariant &stateVariant, thingMap.value("states").toList()) {
        State *state = states->getState(stateVariant.toMap().value("stateTypeId").toUuid());
        if (!state) {
            state = new State(thing->id(), stateVariant.toMap().value("stateTypeId").toUuid(), stateVariant.toMap().value("value"), states);
            states->addState(state);
        } else {
            state->setValue(stateVariant.toMap().value("value"));
        }
    }
    thing->setStates(states);

    return thing;
}




QVariantMap ThingManager::packParam(Param *param)
{
    QVariantMap ret;
    ret.insert("paramTypeId", param->paramTypeId());
    ret.insert("value", param->value());
    return ret;
}

Thing::ThingError ThingManager::errorFromString(const QByteArray &thingErrorString)
{
    QMetaEnum metaEnum = QMetaEnum::fromType<Thing::ThingError>();
    return static_cast<Thing::ThingError>(metaEnum.keyToValue(thingErrorString));
}

ThingClass::SetupMethod ThingManager::stringToSetupMethod(const QString &setupMethodString)
{
    if (setupMethodString == "SetupMethodJustAdd") {
        return ThingClass::SetupMethodJustAdd;
    } else if (setupMethodString == "SetupMethodDisplayPin") {
        return ThingClass::SetupMethodDisplayPin;
    } else if (setupMethodString == "SetupMethodEnterPin") {
        return ThingClass::SetupMethodEnterPin;
    } else if (setupMethodString == "SetupMethodPushButton") {
        return ThingClass::SetupMethodPushButton;
    } else if (setupMethodString == "SetupMethodOAuth") {
        return ThingClass::SetupMethodOAuth;
    } else if (setupMethodString == "SetupMethodUserAndPassword") {
        return ThingClass::SetupMethodUserAndPassword;
    }
    return ThingClass::SetupMethodJustAdd;
}

QPair<Types::Unit, QString> ThingManager::stringToUnit(const QString &unitString)
{
    if (unitString == "UnitNone") {
        return QPair<Types::Unit, QString>(Types::UnitNone, "");
    } else if (unitString == "UnitSeconds") {
        return QPair<Types::Unit, QString>(Types::UnitSeconds, "s");
    } else if (unitString == "UnitMinutes") {
        return QPair<Types::Unit, QString>(Types::UnitMinutes, "m");
    } else if (unitString == "UnitHours") {
        return QPair<Types::Unit, QString>(Types::UnitHours, "h");
    } else if (unitString == "UnitUnixTime") {
        return QPair<Types::Unit, QString>(Types::UnitUnixTime, "datetime");
    } else if (unitString == "UnitMeterPerSecond") {
        return QPair<Types::Unit, QString>(Types::UnitMeterPerSecond, "m/s");
    } else if (unitString == "UnitKiloMeterPerHour") {
        return QPair<Types::Unit, QString>(Types::UnitKiloMeterPerHour, "km/h");
    } else if (unitString == "UnitDegree") {
        return QPair<Types::Unit, QString>(Types::UnitDegree, "°");
    } else if (unitString == "UnitRadiant") {
        return QPair<Types::Unit, QString>(Types::UnitRadiant, "rad");
    } else if (unitString == "UnitDegreeCelsius") {
        return QPair<Types::Unit, QString>(Types::UnitDegreeCelsius, "°C");
    } else if (unitString == "UnitDegreeKelvin") {
        return QPair<Types::Unit, QString>(Types::UnitDegreeKelvin, "°K");
    } else if (unitString == "UnitMired") {
        return QPair<Types::Unit, QString>(Types::UnitMired, "mir");
    } else if (unitString == "UnitMilliBar") {
        return QPair<Types::Unit, QString>(Types::UnitMilliBar, "mbar");
    } else if (unitString == "UnitBar") {
        return QPair<Types::Unit, QString>(Types::UnitBar, "bar");
    } else if (unitString == "UnitPascal") {
        return QPair<Types::Unit, QString>(Types::UnitPascal, "Pa");
    } else if (unitString == "UnitHectoPascal") {
        return QPair<Types::Unit, QString>(Types::UnitHectoPascal, "hPa");
    } else if (unitString == "UnitAtmosphere") {
        return QPair<Types::Unit, QString>(Types::UnitAtmosphere, "atm");
    } else if (unitString == "UnitLumen") {
        return QPair<Types::Unit, QString>(Types::UnitLumen, "lm");
    } else if (unitString == "UnitLux") {
        return QPair<Types::Unit, QString>(Types::UnitLux, "lx");
    } else if (unitString == "UnitCandela") {
        return QPair<Types::Unit, QString>(Types::UnitCandela, "cd");
    } else if (unitString == "UnitMilliMeter") {
        return QPair<Types::Unit, QString>(Types::UnitMilliMeter, "mm");
    } else if (unitString == "UnitCentiMeter") {
        return QPair<Types::Unit, QString>(Types::UnitCentiMeter, "cm");
    } else if (unitString == "UnitMeter") {
        return QPair<Types::Unit, QString>(Types::UnitMeter, "m");
    } else if (unitString == "UnitKiloMeter") {
        return QPair<Types::Unit, QString>(Types::UnitKiloMeter, "km");
    } else if (unitString == "UnitGram") {
        return QPair<Types::Unit, QString>(Types::UnitGram, "g");
    } else if (unitString == "UnitKiloGram") {
        return QPair<Types::Unit, QString>(Types::UnitKiloGram, "kg");
    } else if (unitString == "UnitDezibel") {
        return QPair<Types::Unit, QString>(Types::UnitDezibel, "db");
    } else if (unitString == "UnitBpm") {
        return QPair<Types::Unit, QString>(Types::UnitBpm, "bpm");
    } else if (unitString == "UnitKiloByte") {
        return QPair<Types::Unit, QString>(Types::UnitKiloByte, "kB");
    } else if (unitString == "UnitMegaByte") {
        return QPair<Types::Unit, QString>(Types::UnitMegaByte, "MB");
    } else if (unitString == "UnitGigaByte") {
        return QPair<Types::Unit, QString>(Types::UnitGigaByte, "GB");
    } else if (unitString == "UnitTeraByte") {
        return QPair<Types::Unit, QString>(Types::UnitTeraByte, "TB");
    } else if (unitString == "UnitMilliWatt") {
        return QPair<Types::Unit, QString>(Types::UnitMilliWatt, "mW");
    } else if (unitString == "UnitWatt") {
        return QPair<Types::Unit, QString>(Types::UnitWatt, "W");
    } else if (unitString == "UnitKiloWatt") {
        return QPair<Types::Unit, QString>(Types::UnitKiloWatt, "kW");
    } else if (unitString == "UnitKiloWattHour") {
        return QPair<Types::Unit, QString>(Types::UnitKiloWattHour, "kWh");
    } else if (unitString == "UnitEuroPerMegaWattHour") {
        return QPair<Types::Unit, QString>(Types::UnitEuroPerMegaWattHour, "€/MWh");
    } else if (unitString == "UnitEuroCentPerKiloWattHour") {
        return QPair<Types::Unit, QString>(Types::UnitEuroCentPerKiloWattHour, "ct/kWh");
    } else if (unitString == "UnitPercentage") {
        return QPair<Types::Unit, QString>(Types::UnitPercentage, "%");
    } else if (unitString == "UnitPartsPerMillion") {
        return QPair<Types::Unit, QString>(Types::UnitPartsPerMillion, "ppm");
    } else if (unitString == "UnitEuro") {
        return QPair<Types::Unit, QString>(Types::UnitEuro, "€");
    } else if (unitString == "UnitDollar") {
        return QPair<Types::Unit, QString>(Types::UnitDollar, "$");
    } else if (unitString == "UnitHerz") { // legacy
        return QPair<Types::Unit, QString>(Types::UnitHertz, "Hz");
    } else if (unitString == "UnitHertz") {
        return QPair<Types::Unit, QString>(Types::UnitHertz, "Hz");
    } else if (unitString == "UnitAmpere") {
        return QPair<Types::Unit, QString>(Types::UnitAmpere, "A");
    } else if (unitString == "UnitMilliAmpere") {
        return QPair<Types::Unit, QString>(Types::UnitMilliAmpere, "mA");
    } else if (unitString == "UnitVolt") {
        return QPair<Types::Unit, QString>(Types::UnitVolt, "V");
    } else if (unitString == "UnitMilliVolt") {
        return QPair<Types::Unit, QString>(Types::UnitMilliVolt, "mV");
    } else if (unitString == "UnitVoltAmpere") {
        return QPair<Types::Unit, QString>(Types::UnitVoltAmpere, "VA");
    } else if (unitString == "UnitVoltAmpereReactive") {
        return QPair<Types::Unit, QString>(Types::UnitVoltAmpereReactive, "VAR");
    } else if (unitString == "UnitAmpereHour") {
        return QPair<Types::Unit, QString>(Types::UnitAmpereHour, "Ah");
    } else if (unitString == "UnitMicroSiemensPerCentimeter") {
        return QPair<Types::Unit, QString>(Types::UnitMicroSiemensPerCentimeter, "µS/cm");
    } else if (unitString == "UnitDuration") {
        return QPair<Types::Unit, QString>(Types::UnitDuration, "s");
    }

    return QPair<Types::Unit, QString>(Types::UnitNone, "");
}

Types::InputType ThingManager::stringToInputType(const QString &inputTypeString)
{
    if (inputTypeString == "InputTypeNone") {
        return Types::InputTypeNone;
    } else if (inputTypeString == "InputTypeTextLine") {
        return Types::InputTypeTextLine;
    } else if (inputTypeString == "InputTypeTextArea") {
        return Types::InputTypeTextArea;
    } else if (inputTypeString == "InputTypePassword") {
        return Types::InputTypePassword;
    } else if (inputTypeString == "InputTypeSearch") {
        return Types::InputTypeSearch;
    } else if (inputTypeString == "InputTypeMail") {
        return Types::InputTypeMail;
    } else if (inputTypeString == "InputTypeIPv4Address") {
        return Types::InputTypeIPv4Address;
    } else if (inputTypeString == "InputTypeIPv6Address") {
        return Types::InputTypeIPv6Address;
    } else if (inputTypeString == "InputTypeUrl") {
        return Types::InputTypeUrl;
    } else if (inputTypeString == "InputTypeMacAddress") {
        return Types::InputTypeMacAddress;
    }
    return Types::InputTypeNone;
}
