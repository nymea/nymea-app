/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app.                                      *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "devicemanager.h"
#include "engine.h"
#include "jsonrpc/jsontypes.h"
#include <QMetaEnum>
#include <QSettings>
#include <QStandardPaths>

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
        Device *dev = JsonTypes::unpackDevice(data.value("params").toMap().value("device").toMap(), m_deviceClasses);
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
        if (!JsonTypes::unpackDevice(data.value("params").toMap().value("device").toMap(), m_deviceClasses, oldDevice)) {
            qWarning() << "Error parsing device changed notification";
            return;
        }
        qDebug() << "*** device unpacked" << oldDevice->stateValue("98e4476f-e745-4a7f-b795-19269cb70c40");
    } else {
        qWarning() << "DeviceManager unhandled device notification received" << notification;
    }
}

void DeviceManager::getPluginsResponse(const QVariantMap &params)
{
//    qDebug() << "received plugins";
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/cache-" + m_jsonClient->serverUuid();
    QSettings cache(cachePath, QSettings::IniFormat);
    QString cachedServerVersion = cache.value("serverVersion").toString();
    QStringList cachedPluginList = cache.value("pluginList").toStringList();
    QStringList fetchedPluginList;

    if (params.value("params").toMap().keys().contains("plugins")) {
        QVariantList pluginList = params.value("params").toMap().value("plugins").toList();
        foreach (QVariant pluginVariant, pluginList) {
            Plugin *plugin = JsonTypes::unpackPlugin(pluginVariant.toMap(), plugins());
            m_plugins->addPlugin(plugin);
            fetchedPluginList.append(plugin->pluginId().toString());
        }
    }
    qSort(fetchedPluginList);
    if (cachedPluginList != fetchedPluginList || cachedServerVersion != m_jsonClient->serverVersion()) {
        qDebug() << "Plugin list changed. Invalidating cache";
        cache.clear();
    } else {
        qDebug() << "Plugin list on server did not change.";
    }
    cache.setValue("serverVersion", m_jsonClient->serverVersion());
    cache.setValue("pluginList", fetchedPluginList);

    if (cache.contains("vendors")) {
        qDebug() << "Loading vendors from cache";
        getVendorsResponse(cache.value("vendors").toMap());
    } else {
        qDebug() << "Loading vendors from server";
        m_jsonClient->sendCommand("Devices.GetSupportedVendors", this, "getVendorsResponse");
    }
}

void DeviceManager::getVendorsResponse(const QVariantMap &params)
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/cache-" + m_jsonClient->serverUuid();
    QSettings cache(cachePath, QSettings::IniFormat);
    cache.setValue("vendors", params);

//    qDebug() << "Got GetSupportedVendors response" << params;
    if (params.value("params").toMap().keys().contains("vendors")) {
        QVariantList vendorList = params.value("params").toMap().value("vendors").toList();
        foreach (QVariant vendorVariant, vendorList) {
            Vendor *vendor = JsonTypes::unpackVendor(vendorVariant.toMap());
            m_vendors->addVendor(vendor);
//            qDebug() << "Added Vendor:" << vendor->name();
        }
    }

    qDebug() << "start getting deviceClass at" << QDateTime::currentDateTime();

    if (cache.contains("supportedDevices")) {
        qDebug() << "Loading supported devices from cache";
        getSupportedDevicesResponse(cache.value("supportedDevices").toMap());
    } else {
        qDebug() << "Loading supported devices from server";
        m_jsonClient->sendCommand("Devices.GetSupportedDevices", this, "getSupportedDevicesResponse");
    }
}

void DeviceManager::getSupportedDevicesResponse(const QVariantMap &params)
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/cache-" + m_jsonClient->serverUuid();
    QSettings cache(cachePath, QSettings::IniFormat);

    cache.setValue("supportedDevices", params);

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
            Device *device = JsonTypes::unpackDevice(deviceVariant.toMap(), m_deviceClasses);
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
            devices()->addDevice(device);
        }
    }
    m_fetchingData = false;
    emit fetchingDataChanged();

    if (m_plugins->count() > 0) {
        m_currentGetConfigIndex = 0;
        QVariantMap configRequestParams;
        configRequestParams.insert("pluginId", m_plugins->get(m_currentGetConfigIndex)->pluginId());
        m_jsonClient->sendCommand("Devices.GetPluginConfiguration", configRequestParams, this, "getPluginConfigResponse");
    }

}

void DeviceManager::addDeviceResponse(const QVariantMap &params)
{
    if (params.value("params").toMap().value("deviceError").toString() != "DeviceErrorNoError") {
        qWarning() << "Failed to add the device:" << params.value("params").toMap().value("deviceError").toString();
    } else if (params.value("params").toMap().keys().contains("device")) {
        QVariantMap deviceVariant = params.value("params").toMap().value("device").toMap();
        Device *device = JsonTypes::unpackDevice(deviceVariant, m_deviceClasses);
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
    emit pairDeviceReply(params.value("params").toMap());
}

void DeviceManager::confirmPairingResponse(const QVariantMap &params)
{
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

void DeviceManager::addDiscoveredDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId, const QString &name)
{
    qDebug() << "JsonRpc: add discovered device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("name", name);
    params.insert("deviceDescriptorId", deviceDescriptorId.toString());
    m_jsonClient->sendCommand("Devices.AddConfiguredDevice", params, this, "addDeviceResponse");
}

void DeviceManager::pairDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId, const QString &name)
{
    qDebug() << "JsonRpc: pair device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("name", name);
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("deviceDescriptorId", deviceDescriptorId.toString());
    m_jsonClient->sendCommand("Devices.PairDevice", params, this, "pairDeviceResponse");
}

void DeviceManager::confirmPairing(const QUuid &pairingTransactionId, const QString &secret)
{
    qDebug() << "JsonRpc: confirm pairing" << pairingTransactionId.toString();
    QVariantMap params;
    params.insert("pairingTransactionId", pairingTransactionId.toString());
    params.insert("secret", secret);
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

int DeviceManager::executeAction(const QUuid &deviceId, const QUuid &actionTypeId, const QVariantList &params)
{
    qDebug() << "JsonRpc: execute action " << deviceId.toString() << actionTypeId.toString() << params;
    QVariantMap p;
    p.insert("deviceId", deviceId.toString());
    p.insert("actionTypeId", actionTypeId.toString());
    if (!params.isEmpty()) {
        p.insert("params", params);
    }

    qDebug() << "Params:" << p;
    return m_jsonClient->sendCommand("Actions.ExecuteAction", p, this, "executeActionResponse");
}
