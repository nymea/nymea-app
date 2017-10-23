/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "devicehandler.h"
#include "jsontypes.h"
#include "engine.h"
#include "types/states.h"
#include "types/deviceclass.h"

#include <QDateTime>

DeviceHandler::DeviceHandler(QObject *parent) :
    JsonHandler(parent)
{

}

QString DeviceHandler::nameSpace() const
{
    return QString("Devices");
}

void DeviceHandler::processGetSupportedVendors(const QVariantMap &params)
{
    qDebug() << "Got GetSupportedVendors response";
    if (params.value("params").toMap().keys().contains("vendors")) {
        QVariantList vendorList = params.value("params").toMap().value("vendors").toList();
        foreach (QVariant vendorVariant, vendorList) {
            Vendor *vendor = JsonTypes::unpackVendor(vendorVariant.toMap(), Engine::instance()->deviceManager()->vendors());
            Engine::instance()->deviceManager()->vendors()->addVendor(vendor);
        }
    }

    qDebug() << "start getting deviceClass at" << QDateTime::currentDateTime();

    Engine::instance()->jsonRpcClient()->getDeviceClasses();
    qDebug() << "call done at" << QDateTime::currentDateTime();
}

void DeviceHandler::processGetPlugins(const QVariantMap &params)
{
    if (params.value("params").toMap().keys().contains("plugins")) {
        QVariantList pluginList = params.value("params").toMap().value("plugins").toList();
        foreach (QVariant pluginVariant, pluginList) {
            Plugin *plugin = JsonTypes::unpackPlugin(pluginVariant.toMap(), Engine::instance()->deviceManager()->plugins());
            Engine::instance()->deviceManager()->plugins()->addPlugin(plugin);
        }
    }
    Engine::instance()->jsonRpcClient()->getDevices();

}

void DeviceHandler::processGetSupportedDevices(const QVariantMap &params)
{
    if (params.value("params").toMap().keys().contains("deviceClasses")) {
        QVariantList deviceClassList = params.value("params").toMap().value("deviceClasses").toList();
        foreach (QVariant deviceClassVariant, deviceClassList) {
            DeviceClass *deviceClass = JsonTypes::unpackDeviceClass(deviceClassVariant.toMap(), Engine::instance()->deviceManager()->deviceClasses());
            qDebug() << "Server has device class:" << deviceClass->name() << deviceClass->id();
            Engine::instance()->deviceManager()->deviceClasses()->addDeviceClass(deviceClass);
        }
    }
    Engine::instance()->jsonRpcClient()->getPlugins();
}

void DeviceHandler::processGetConfiguredDevices(const QVariantMap &params)
{
    if (params.value("params").toMap().keys().contains("devices")) {
        QVariantList deviceList = params.value("params").toMap().value("devices").toList();
        foreach (QVariant deviceVariant, deviceList) {
            Device *device = JsonTypes::unpackDevice(deviceVariant.toMap(), Engine::instance()->deviceManager()->devices());
            if (!device) continue;
            Engine::instance()->deviceManager()->devices()->addDevice(device);

            //qDebug() << QJsonDocument::fromVariant(deviceVariant).toJson();

            // set initial state values
            QVariantList stateVariantList = deviceVariant.toMap().value("states").toList();
            foreach (const QVariant &stateMap, stateVariantList) {
                QUuid stateTypeId = stateMap.toMap().value("stateTypeId").toUuid();
                QVariant value = stateMap.toMap().value("value");
                device->setStateValue(stateTypeId, value);
            }
        }
    }
}

void DeviceHandler::processRemoveConfiguredDevice(const QVariantMap &params)
{
    // response handled in the ui
    Q_UNUSED(params);
}

void DeviceHandler::processAddConfiguredDevice(const QVariantMap &params)
{
    // response handled in the ui
    Q_UNUSED(params);
}

void DeviceHandler::processGetDiscoveredDevices(const QVariantMap &params)
{
    // response handled in the ui
    Q_UNUSED(params);
}

void DeviceHandler::processPairDevice(const QVariantMap &params)
{
    // response handled in the ui
    Q_UNUSED(params);
}

void DeviceHandler::processConfirmPairing(const QVariantMap &params)
{
    // response handled in the ui
    Q_UNUSED(params);
}

void DeviceHandler::processDeviceRemoved(const QVariantMap &params)
{
    QUuid deviceId = params.value("params").toMap().value("deviceId").toUuid();
    qDebug() << "JsonRpc: Notification: Device removed" << deviceId.toString();
    Device *device = Engine::instance()->deviceManager()->devices()->getDevice(deviceId);
    Engine::instance()->deviceManager()->devices()->removeDevice(device);
    device->deleteLater();
}

void DeviceHandler::processDeviceAdded(const QVariantMap &params)
{
    if (params.value("params").toMap().keys().contains("device")) {
        QVariantMap deviceVariant = params.value("params").toMap().value("device").toMap();
        Device *device = JsonTypes::unpackDevice(deviceVariant, Engine::instance()->deviceManager()->devices());
        qDebug() << "JsonRpc: Notification: Device added" << device->id().toString();
        Engine::instance()->deviceManager()->devices()->addDevice(device);
    }
}

void DeviceHandler::processStateChanged(const QVariantMap &params)
{
    QVariantMap notification = params.value("params").toMap();
    QUuid deviceId = notification.value("deviceId").toUuid();

    Device *device = Engine::instance()->deviceManager()->devices()->getDevice(deviceId);

    if (!device) {
        qWarning() << "JsonRpc: ERROR: could not find device for state changed notification";
        return;
    }

    QUuid stateTypeId = notification.value("stateTypeId").toUuid();
    QVariant value = notification.value("value");

    device->setStateValue(stateTypeId, value);
}
