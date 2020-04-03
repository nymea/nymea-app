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

#include "devicemanager.h"
#include "engine.h"
#include "jsonrpc/jsontypes.h"
#include "types/browseritems.h"
#include "types/browseritem.h"
#include "thinggroup.h"
#include "types/interface.h"
#include <QMetaEnum>

DeviceManager::DeviceManager(JsonRpcClient* jsonclient, QObject *parent) :
    JsonHandler(parent),
    m_vendors(new Vendors(this)),
    m_plugins(new Plugins(this)),
    m_devices(new Devices(this)),
    m_deviceClasses(new DeviceClasses(this)),
    m_jsonClient(jsonclient)
{
    m_jsonClient->registerNotificationHandler(this, "notificationReceived");
}

void DeviceManager::clear()
{
    m_devices->clearModel();
    m_deviceClasses->clearModel();
    m_vendors->clearModel();
    m_plugins->clearModel();
}

void DeviceManager::init()
{
    // For old nymea setups we need to register to Events.Notifications.
    // Deprecated since JSONRPC 4.0/nymea 0.17
    if (!m_jsonClient->ensureServerVersion("4.0")) {
        if (!m_eventHandler) {
            m_eventHandler = new EventHandler(this);
            m_jsonClient->registerNotificationHandler(m_eventHandler, "notificationReceived");
            connect(m_eventHandler, &EventHandler::eventReceived, this, [this](const QVariantMap event) {
                QUuid deviceId = event.value("deviceId").toUuid();
                QUuid eventTypeId = event.value("eventTypeId").toUuid();

                Device *dev = m_devices->getDevice(deviceId);
                if (!dev) {
                    qWarning() << "received an event from a device we don't know..." << deviceId << event;
                    return;
                }
//                qDebug() << "Event received" << deviceId.toString() << eventTypeId.toString();
                dev->eventTriggered(eventTypeId.toString(), event.value("params").toMap());
                emit eventTriggered(deviceId.toString(), eventTypeId.toString(), event.value("params").toMap());
            });
        }
    } else {
        if (m_eventHandler) {
            m_jsonClient->unregisterNotificationHandler(m_eventHandler);
            m_eventHandler->deleteLater();
            m_eventHandler = nullptr;
        }
    }


    m_fetchingData = true;
    emit fetchingDataChanged();
    m_jsonClient->sendCommand("Devices.GetPlugins", this, "getPluginsResponse");
}

QString DeviceManager::nameSpace() const
{
    return "Devices";
}

Vendors *DeviceManager::vendors() const
{
    return m_vendors;
}

Plugins *DeviceManager::plugins() const
{
    return m_plugins;
}

Devices *DeviceManager::devices() const
{
    return m_devices;
}

DeviceClasses *DeviceManager::deviceClasses() const
{
    return m_deviceClasses;
}

bool DeviceManager::fetchingData() const
{
    return m_fetchingData;
}

void DeviceManager::addDevice(const QUuid &deviceClassId, const QString &name, const QVariantList &deviceParams)
{
    qDebug() << "add device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("name", name);
    params.insert("deviceParams", deviceParams);
    m_jsonClient->sendCommand("Devices.AddConfiguredDevice", params, this, "addDeviceResponse");
}

void DeviceManager::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    if (notification == "Devices.StateChanged") {
//        qDebug() << "Device state changed" << data.value("params");
        Device *dev = m_devices->getDevice(data.value("params").toMap().value("deviceId").toUuid());
        if (!dev) {
            qWarning() << "Device state change notification received for an unknown device";
            return;
        }
        dev->setStateValue(data.value("params").toMap().value("stateTypeId").toUuid(), data.value("params").toMap().value("value"));
    } else if (notification == "Devices.DeviceAdded") {
        Device *dev = JsonTypes::unpackDevice(this, data.value("params").toMap().value("device").toMap(), m_deviceClasses);
        if (!dev) {
            qWarning() << "Cannot parse json device:" << data;
            return;
        }
        DeviceClass *dc = deviceClasses()->getDeviceClass(dev->deviceClassId());
        if (!dc) {
            qWarning() << "Skipping invalid device. Don't have a device class for it";
            delete dev;
            return;
        }
        m_devices->addDevice(dev);
    } else if (notification == "Devices.DeviceRemoved") {
        QUuid deviceId = data.value("params").toMap().value("deviceId").toUuid();
        qDebug() << "JsonRpc: Notification: Device removed" << deviceId.toString();
        Device *device = m_devices->getDevice(deviceId);
        if (!device) {
            qWarning() << "Received a DeviceRemoved notification for a device we don't know!";
            return;
        }
        m_devices->removeDevice(device);
        device->deleteLater();
    } else if (notification == "Devices.DeviceChanged") {
        QUuid deviceId = data.value("params").toMap().value("device").toMap().value("id").toUuid();
        qDebug() << "Device changed notification" << deviceId << data.value("params").toMap();
        Device *oldDevice = m_devices->getDevice(deviceId);
        if (!oldDevice) {
            qWarning() << "Received a device changed notification for a device we don't know";
            return;
        }
        if (!JsonTypes::unpackDevice(this, data.value("params").toMap().value("device").toMap(), m_deviceClasses, oldDevice)) {
            qWarning() << "Error parsing device changed notification";
            return;
        }
        qDebug() << "*** device unpacked" << oldDevice->stateValue("98e4476f-e745-4a7f-b795-19269cb70c40");
    } else if (notification == "Devices.DeviceSettingChanged") {
        QUuid deviceId = data.value("params").toMap().value("deviceId").toUuid();
        QString paramTypeId = data.value("params").toMap().value("paramTypeId").toString();
        QVariant value = data.value("params").toMap().value("value");
        qDebug() << "Device settings changed notification for device" << deviceId << data.value("params").toMap().value("settings").toList();
        Device *dev = m_devices->getDevice(deviceId);
        if (!dev) {
            qWarning() << "Device settings changed notification for a device we don't know" << deviceId.toString();
            return;
        }
        Param *p = dev->settings()->getParam(paramTypeId);
        if (!p) {
            qWarning() << "Device" << dev->name() << dev->id().toString() << "does not have a setting of id" << paramTypeId;
            return;
        }
        p->setValue(value);
    } else if (notification == "Devices.EventTriggered") {
        QVariantMap event = data.value("params").toMap().value("event").toMap();
        QUuid deviceId = event.value("deviceId").toUuid();
        QUuid eventTypeId = event.value("eventTypeId").toUuid();

        Device *dev = m_devices->getDevice(deviceId);
        if (!dev) {
            qWarning() << "received an event from a device we don't know..." << deviceId << qUtf8Printable(QJsonDocument::fromVariant(data).toJson());
            return;
        }
//        qDebug() << "Event received" << deviceId.toString() << eventTypeId.toString();
        dev->eventTriggered(eventTypeId.toString(), event.value("params").toMap());
    } else {
        qWarning() << "DeviceManager unhandled device notification received" << notification;
    }
}

void DeviceManager::getVendorsResponse(const QVariantMap &params)
{
//    qDebug() << "Got GetSupportedVendors response" << params;
    if (params.value("params").toMap().keys().contains("vendors")) {
        QVariantList vendorList = params.value("params").toMap().value("vendors").toList();
        foreach (QVariant vendorVariant, vendorList) {
            Vendor *vendor = JsonTypes::unpackVendor(vendorVariant.toMap());
            m_vendors->addVendor(vendor);
//            qDebug() << "Added Vendor:" << vendor->name();
        }
    }

    m_jsonClient->sendCommand("Devices.GetSupportedDevices", this, "getSupportedDevicesResponse");
}

void DeviceManager::getSupportedDevicesResponse(const QVariantMap &params)
{
//    qDebug() << "DeviceClass received:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    if (params.value("params").toMap().keys().contains("deviceClasses")) {
        QVariantList deviceClassList = params.value("params").toMap().value("deviceClasses").toList();
        foreach (QVariant deviceClassVariant, deviceClassList) {
            DeviceClass *deviceClass = JsonTypes::unpackDeviceClass(deviceClassVariant.toMap(), deviceClasses());
            m_deviceClasses->addDeviceClass(deviceClass);
        }
    }
    m_jsonClient->sendCommand("Devices.GetConfiguredDevices", this, "getConfiguredDevicesResponse");
}

void DeviceManager::getPluginsResponse(const QVariantMap &params)
{
//    qDebug() << "received plugins";
    if (params.value("params").toMap().keys().contains("plugins")) {
        QVariantList pluginList = params.value("params").toMap().value("plugins").toList();
        foreach (QVariant pluginVariant, pluginList) {
            Plugin *plugin = JsonTypes::unpackPlugin(pluginVariant.toMap(), plugins());
            m_plugins->addPlugin(plugin);
        }
    }
    m_jsonClient->sendCommand("Devices.GetSupportedVendors", this, "getVendorsResponse");

    if (m_plugins->count() > 0) {
        m_currentGetConfigIndex = 0;
        QVariantMap configRequestParams;
        configRequestParams.insert("pluginId", m_plugins->get(m_currentGetConfigIndex)->pluginId());
        m_jsonClient->sendCommand("Devices.GetPluginConfiguration", configRequestParams, this, "getPluginConfigResponse");
    }
}

void DeviceManager::getPluginConfigResponse(const QVariantMap &params)
{
//    qDebug() << "plugin config response" << params;
    Plugin *p = m_plugins->get(m_currentGetConfigIndex);
    if (!p) {
        qDebug() << "Received a plugin config for a plugin we don't know";
        return;
    }
    QVariantList pluginParams = params.value("params").toMap().value("configuration").toList();
    foreach (const QVariant &paramVariant, pluginParams) {
        Param* param = new Param();
        JsonTypes::unpackParam(paramVariant.toMap(), param);
        p->params()->addParam(param);
    }

    m_currentGetConfigIndex++;
    if (m_plugins->count() > m_currentGetConfigIndex) {
        QVariantMap configRequestParams;
        configRequestParams.insert("pluginId", m_plugins->get(m_currentGetConfigIndex)->pluginId());
        m_jsonClient->sendCommand("Devices.GetPluginConfiguration", configRequestParams, this, "getPluginConfigResponse");
    }
}

void DeviceManager::getConfiguredDevicesResponse(const QVariantMap &params)
{
    if (params.value("params").toMap().keys().contains("devices")) {
        QVariantList deviceList = params.value("params").toMap().value("devices").toList();
        foreach (QVariant deviceVariant, deviceList) {
            Device *device = JsonTypes::unpackDevice(this, deviceVariant.toMap(), m_deviceClasses);
            if (!device) {
                qWarning() << "Error unpacking device" << deviceVariant.toMap().value("name").toString();
                continue;
            }

            // set initial state values
            QVariantList stateVariantList = deviceVariant.toMap().value("states").toList();
            foreach (const QVariant &stateMap, stateVariantList) {
                QString stateTypeId = stateMap.toMap().value("stateTypeId").toString();
                StateType *st = device->deviceClass()->stateTypes()->getStateType(stateTypeId);
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
                device->setStateValue(stateTypeId, value);
//                qDebug() << "Set device state value:" << device->stateValue(stateTypeId) << value;
            }
//            qDebug() << "Configured Device JSON:" << qUtf8Printable(QJsonDocument::fromVariant(deviceVariant).toJson(QJsonDocument::Indented));
            devices()->addDevice(device);
//            qDebug() << "*** Added device:" << endl << device;
        }
    }
    m_fetchingData = false;
    emit fetchingDataChanged();
}

void DeviceManager::addDeviceResponse(const QVariantMap &params)
{
    if (params.value("params").toMap().value("deviceError").toString() != "DeviceErrorNoError") {
        qWarning() << "Failed to add the device:" << params.value("params").toMap().value("deviceError").toString();
    } else if (params.value("params").toMap().keys().contains("device")) {
        QVariantMap deviceVariant = params.value("params").toMap().value("device").toMap();
        Device *device = JsonTypes::unpackDevice(this, deviceVariant, m_deviceClasses);
        if (!device) {
            qWarning() << "Couldn't parse json in addDeviceResponse";
            return;
        }

        qDebug() << "Device added" << device->id().toString();
        m_devices->addDevice(device);
    }
    emit addDeviceReply(params.value("params").toMap());
}

void DeviceManager::removeDeviceResponse(const QVariantMap &params)
{
    qDebug() << "Device removed response" << params;
    emit removeDeviceReply(params.value("params").toMap());
}

void DeviceManager::pairDeviceResponse(const QVariantMap &params)
{
    qDebug() << "Pair device response:" << params;
    emit pairDeviceReply(params.value("params").toMap());
}

void DeviceManager::confirmPairingResponse(const QVariantMap &params)
{
    qDebug() << "ConfirmPairingResponse" << params;
    emit confirmPairingReply(params.value("params").toMap());
}

void DeviceManager::setPluginConfigResponse(const QVariantMap &params)
{
    qDebug() << "set plugin config respionse" << params;
    emit savePluginConfigReply(params);
}

void DeviceManager::editDeviceResponse(const QVariantMap &params)
{
    qDebug() << "Edit device response" << params;
    emit editDeviceReply(params);
}

void DeviceManager::executeActionResponse(const QVariantMap &params)
{
    qDebug() << "Execute Action response" << params;
    emit executeActionReply(params);
}

void DeviceManager::reconfigureDeviceResponse(const QVariantMap &params)
{
    qDebug() << "Reconfigure device response" << params;
    emit reconfigureDeviceReply(params.value("params").toMap());
}

void DeviceManager::savePluginConfig(const QUuid &pluginId)
{
    Plugin *p = m_plugins->getPlugin(pluginId);
    if (!p) {
        qWarning()<< "Error: can't find plugin with id" << pluginId;
        return;
    }
    QVariantMap params;
    params.insert("pluginId", pluginId);
    QVariantList pluginParams;
    for (int i = 0; i < p->params()->rowCount(); i++) {
        pluginParams.append(JsonTypes::packParam(p->params()->get(i)));
    }
    params.insert("configuration", pluginParams);
    m_jsonClient->sendCommand("Devices.SetPluginConfiguration", params, this, "setPluginConfigResponse");
}

ThingGroup *DeviceManager::createGroup(Interface *interface, DevicesProxy *things)
{
    ThingGroup* group = new ThingGroup(this, interface->createDeviceClass(), things, this);
    group->setSetupStatus(Device::DeviceSetupStatusComplete, QString());
    return group;
}

void DeviceManager::addDiscoveredDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId, const QString &name, const QVariantList &deviceParams)
{
    qDebug() << "JsonRpc: add discovered device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("name", name);
    params.insert("deviceDescriptorId", deviceDescriptorId.toString());
    params.insert("deviceParams", deviceParams);
    m_jsonClient->sendCommand("Devices.AddConfiguredDevice", params, this, "addDeviceResponse");
}

void DeviceManager::pairDiscoveredDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId, const QVariantList &deviceParams, const QString &name)
{
    qDebug() << "JsonRpc: pair discovered device " << deviceDescriptorId.toString();
    QVariantMap params;
    params.insert("deviceDescriptorId", deviceDescriptorId.toString());
    params.insert("deviceParams", deviceParams);
    params.insert("name", name);

    if (!m_jsonClient->ensureServerVersion("3.2")) {
        params.insert("deviceClassId", deviceClassId);
    }

    m_jsonClient->sendCommand("Devices.PairDevice", params, this, "pairDeviceResponse");
}

void DeviceManager::pairDevice(const QUuid &deviceClassId, const QVariantList &deviceParams, const QString &name)
{
    qDebug() << "JsonRpc: pair device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("deviceParams", deviceParams);
    params.insert("name", name);
    m_jsonClient->sendCommand("Devices.PairDevice", params, this, "pairDeviceResponse");
}

void DeviceManager::rePairDevice(const QUuid &deviceId, const QVariantList &deviceParams, const QString &name)
{
    qDebug() << "JsonRpc: pair device (reconfigure)" << deviceId;
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    params.insert("deviceParams", deviceParams);
    if (!name.isEmpty()) {
        params.insert("name", name);
    }
    m_jsonClient->sendCommand("Devices.PairDevice", params, this, "pairDeviceResponse");
}

void DeviceManager::confirmPairing(const QUuid &pairingTransactionId, const QString &secret, const QString &username)
{
    qDebug() << "JsonRpc: confirm pairing" << pairingTransactionId.toString();
    QVariantMap params;
    params.insert("pairingTransactionId", pairingTransactionId.toString());
    params.insert("secret", secret);
    if (!username.isEmpty()) {
        params.insert("username", username);
    }
    m_jsonClient->sendCommand("Devices.ConfirmPairing", params, this, "confirmPairingResponse");
}

void DeviceManager::removeDevice(const QUuid &deviceId, RemovePolicy removePolicy)
{
    qDebug() << "JsonRpc: delete device" << deviceId.toString();
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    if (removePolicy != RemovePolicyNone) {
        QMetaEnum policyEnum = QMetaEnum::fromType<DeviceManager::RemovePolicy>();
        params.insert("removePolicy", policyEnum.valueToKey(removePolicy));
    }
    m_jsonClient->sendCommand("Devices.RemoveConfiguredDevice", params, this, "removeDeviceResponse");
}

void DeviceManager::editDevice(const QUuid &deviceId, const QString &name)
{
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    params.insert("name", name);
    m_jsonClient->sendCommand("Devices.EditDevice", params, this, "editDeviceResponse");
}

void DeviceManager::setDeviceSettings(const QUuid &deviceId, const QVariantList &settings)
{
    QVariantMap params;
    params.insert("deviceId", deviceId);
    params.insert("settings", settings);
    m_jsonClient->sendCommand("Devices.SetDeviceSettings", params);
}

void DeviceManager::reconfigureDevice(const QUuid &deviceId, const QVariantList &deviceParams)
{
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    params.insert("deviceParams", deviceParams);
    m_jsonClient->sendCommand("Devices.ReconfigureDevice", params, this, "reconfigureDeviceResponse");
}

void DeviceManager::reconfigureDiscoveredDevice(const QUuid &deviceId, const QUuid &deviceDescriptorId, const QVariantList &paramOverride)
{
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    params.insert("deviceDescriptorId", deviceDescriptorId);
    if (!paramOverride.isEmpty()) {
        params.insert("deviceParams", paramOverride);
    }
    qDebug() << "Calling ReconfigureDevice" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    m_jsonClient->sendCommand("Devices.ReconfigureDevice", params, this, "reconfigureDeviceResponse");
}

int DeviceManager::executeAction(const QUuid &deviceId, const QUuid &actionTypeId, const QVariantList &params)
{
//    qDebug() << "JsonRpc: execute action " << deviceId.toString() << actionTypeId.toString() << params;
    QVariantMap p;
    p.insert("deviceId", deviceId.toString());
    p.insert("actionTypeId", actionTypeId.toString());
    if (!params.isEmpty()) {
        p.insert("params", params);
    }
    QString method = m_jsonClient->ensureServerVersion("4.0") ? "Devices.ExecuteAction" : "Actions.ExecuteAction";

    return m_jsonClient->sendCommand(method, p, this, "executeActionResponse");
}

BrowserItems *DeviceManager::browseDevice(const QUuid &deviceId, const QString &itemId)
{
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    params.insert("itemId", itemId);
    int id = m_jsonClient->sendCommand("Devices.BrowseDevice", params, this, "browseDeviceResponse");

    // Intentionally not parented. The caller takes ownership and needs to destroy when not needed any more.
    BrowserItems *itemModel = new BrowserItems(deviceId, itemId);
    itemModel->setBusy(true);
    QPointer<BrowserItems> itemModelPtr(itemModel);
    m_browsingRequests.insert(id, itemModelPtr);

    return itemModel;
}

void DeviceManager::refreshBrowserItems(BrowserItems *browserItems)
{
    QVariantMap params;
    params.insert("deviceId", browserItems->deviceId().toString());
    params.insert("itemId", browserItems->itemId());
    int id = m_jsonClient->sendCommand("Devices.BrowseDevice", params, this, "browseDeviceResponse");

    // Intentionally not parented. The caller takes ownership and needs to destroy when not needed any more.
    browserItems->setBusy(true);
    QPointer<BrowserItems> itemModelPtr(browserItems);
    m_browsingRequests.insert(id, browserItems);
}

BrowserItem *DeviceManager::browserItem(const QUuid &deviceId, const QString &itemId)
{
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    params.insert("itemId", itemId);
    int id = m_jsonClient->sendCommand("Devices.GetBrowserItem", params, this, "browserItemResponse");

    // Intentionally not parented. The caller takes ownership and needs to destroy when not needed any more.
    BrowserItem *item = new BrowserItem(itemId);
    QPointer<BrowserItem> itemPtr(item);
    m_browserDetailsRequests.insert(id, itemPtr);

    return item;
}

void DeviceManager::browseDeviceResponse(const QVariantMap &params)
{
//    qDebug() << "Browsing response:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    int id = params.value("id").toInt();
    if (!m_browsingRequests.contains(id)) {
        qWarning() << "Received a browsing reply for an id we don't know.";
        return;
    }

    QPointer<BrowserItems> itemModel = m_browsingRequests.take(id);
    if (!itemModel) {
        qDebug() << "BrowserItems model seems to have disappeared. Discarding browsing result.";
        return;
    }

    QList<BrowserItem*> itemsToRemove = itemModel->list();

    foreach (const QVariant &itemVariant, params.value("params").toMap().value("items").toList()) {
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

void DeviceManager::browserItemResponse(const QVariantMap &params)
{
    qDebug() << "Browser item details response:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Indented));
    int id = params.value("id").toInt();
    if (!m_browserDetailsRequests.contains(id)) {
        qWarning() << "Received a browser item details reply for an id we don't know.";
        return;
    }

    QPointer<BrowserItem> item = m_browserDetailsRequests.take(id);
    if (!item) {
        qDebug() << "BrowserItem seems to have disappeared. Discarding browser item details result.";
        return;
    }

    QVariantMap itemMap = params.value("params").toMap().value("item").toMap();
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

int DeviceManager::executeBrowserItem(const QUuid &deviceId, const QString &itemId)
{
    QVariantMap params;
    params.insert("deviceId", deviceId);
    params.insert("itemId", itemId);
    return m_jsonClient->sendCommand("Actions.ExecuteBrowserItem", params, this, "executeBrowserItemResponse");
}

void DeviceManager::executeBrowserItemResponse(const QVariantMap &params)
{
    qDebug() << "Execute Browser Item finished" << params;
    emit executeBrowserItemReply(params);
}

int DeviceManager::executeBrowserItemAction(const QUuid &deviceId, const QString &itemId, const QUuid &actionTypeId, const QVariantList &params)
{
    QVariantMap data;
    data.insert("deviceId", deviceId);
    data.insert("itemId", itemId);
    data.insert("actionTypeId", actionTypeId);
    data.insert("params", params);
    qDebug() << "params:" << params;
    return m_jsonClient->sendCommand("Actions.ExecuteBrowserItemAction", data, this, "executeBrowserItemActionResponse");
}

void DeviceManager::executeBrowserItemActionResponse(const QVariantMap &params)
{
    qDebug() << "Execute Browser Item Action finished" << params;
    emit executeBrowserItemActionReply(params);
}

