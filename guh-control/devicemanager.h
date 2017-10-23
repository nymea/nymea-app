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

#ifndef DEVICEMANAGER_H
#define DEVICEMANAGER_H

#include <QObject>

#include "types/vendors.h"
#include "devices.h"
#include "deviceclasses.h"
#include "types/plugins.h"
#include "jsonrpc/jsonhandler.h"
#include "jsonrpc/jsonrpcclient.h"

class DeviceManager : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(Vendors *vendors READ vendors CONSTANT)
    Q_PROPERTY(Plugins *plugins READ plugins CONSTANT)
    Q_PROPERTY(Devices *devices READ devices CONSTANT)
    Q_PROPERTY(DeviceClasses *deviceClasses READ deviceClasses CONSTANT)

public:
    explicit DeviceManager(JsonRpcClient *jsonclient, QObject *parent = 0);

    void clear();
    void init();

    QString nameSpace() const override;

    Vendors *vendors() const;
    Plugins *plugins() const;
    Devices *devices() const;
    DeviceClasses *deviceClasses() const;

    Q_INVOKABLE void addDevice(const QUuid &deviceClassId, const QVariantList &deviceParams);
    Q_INVOKABLE void addDiscoveredDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId, const QString &name);
    Q_INVOKABLE void pairDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId);
    Q_INVOKABLE void confirmPairing(const QUuid &pairingTransactionId, const QString &secret = QString());
    Q_INVOKABLE void removeDevice(const QUuid &deviceId);
    Q_INVOKABLE void executeAction(const QUuid &deviceId, const QUuid &actionTypeId, const QVariantList &params = QVariantList());

private:
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);
    Q_INVOKABLE void getVendorsResponse(const QVariantMap &params);
    Q_INVOKABLE void getSupportedDevicesResponse(const QVariantMap &params);
    Q_INVOKABLE void getPluginsResponse(const QVariantMap &params);
    Q_INVOKABLE void getConfiguredDevicesResponse(const QVariantMap &params);
    Q_INVOKABLE void addDeviceResponse(const QVariantMap &params);
    Q_INVOKABLE void removeDeviceResponse(const QVariantMap &params);



private:
    Vendors *m_vendors;
    Plugins *m_plugins;
    Devices *m_devices;
    DeviceClasses *m_deviceClasses;

    JsonRpcClient *m_jsonClient = nullptr;

};

#endif // DEVICEMANAGER_H
