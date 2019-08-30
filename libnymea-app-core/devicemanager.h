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

#ifndef DEVICEMANAGER_H
#define DEVICEMANAGER_H

#include <QObject>

#include "types/vendors.h"
#include "devices.h"
#include "deviceclasses.h"
#include "interfacesmodel.h"
#include "types/plugins.h"
#include "jsonrpc/jsonhandler.h"
#include "jsonrpc/jsonrpcclient.h"

class BrowserItem;
class BrowserItems;

class DeviceManager : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(Vendors *vendors READ vendors CONSTANT)
    Q_PROPERTY(Plugins *plugins READ plugins CONSTANT)
    Q_PROPERTY(Devices *devices READ devices CONSTANT)
    Q_PROPERTY(DeviceClasses *deviceClasses READ deviceClasses CONSTANT)

    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

public:
    enum RemovePolicy {
        RemovePolicyNone,
        RemovePolicyCascade,
        RemovePolicyUpdate
    };
    Q_ENUM(RemovePolicy)

    explicit DeviceManager(JsonRpcClient *jsonclient, QObject *parent = nullptr);

    void clear();
    void init();

    QString nameSpace() const override;

    Vendors *vendors() const;
    Plugins *plugins() const;
    Devices *devices() const;
    DeviceClasses *deviceClasses() const;

    bool fetchingData() const;

    Q_INVOKABLE void addDevice(const QUuid &deviceClassId, const QString &name, const QVariantList &deviceParams);
    Q_INVOKABLE void addDiscoveredDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId, const QString &name, const QVariantList &deviceParams);
    Q_INVOKABLE void pairDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId, const QString &name);
    Q_INVOKABLE void pairDevice(const QUuid &deviceClassId, const QString &name, const QVariantList &deviceParams);
    Q_INVOKABLE void confirmPairing(const QUuid &pairingTransactionId, const QString &secret = QString(), const QString &username = QString());
    Q_INVOKABLE void removeDevice(const QUuid &deviceId, RemovePolicy policy = RemovePolicyNone);
    Q_INVOKABLE void editDevice(const QUuid &deviceId, const QString &name);
    Q_INVOKABLE void setDeviceSettings(const QUuid &deviceId, const QVariantList &settings);
    Q_INVOKABLE void reconfigureDevice(const QUuid &deviceId, const QVariantList &deviceParams);
    Q_INVOKABLE void reconfigureDiscoveredDevice(const QUuid &deviceId, const QUuid &deviceDescriptorId);
    Q_INVOKABLE int executeAction(const QUuid &deviceId, const QUuid &actionTypeId, const QVariantList &params = QVariantList());
    Q_INVOKABLE BrowserItems* browseDevice(const QUuid &deviceId, const QString &itemId = QString());
    Q_INVOKABLE void refreshBrowserItems(BrowserItems *browserItems);
    Q_INVOKABLE BrowserItem* browserItem(const QUuid &deviceId, const QString &itemId);
    Q_INVOKABLE int executeBrowserItem(const QUuid &deviceId, const QString &itemId);
    Q_INVOKABLE int executeBrowserItemAction(const QUuid &deviceId, const QString &itemId, const QUuid &actionTypeId, const QVariantList &params = QVariantList());

private:
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);
    Q_INVOKABLE void getVendorsResponse(const QVariantMap &params);
    Q_INVOKABLE void getSupportedDevicesResponse(const QVariantMap &params);
    Q_INVOKABLE void getPluginsResponse(const QVariantMap &params);
    Q_INVOKABLE void getPluginConfigResponse(const QVariantMap &params);
    Q_INVOKABLE void getConfiguredDevicesResponse(const QVariantMap &params);
    Q_INVOKABLE void addDeviceResponse(const QVariantMap &params);
    Q_INVOKABLE void removeDeviceResponse(const QVariantMap &params);
    Q_INVOKABLE void pairDeviceResponse(const QVariantMap &params);
    Q_INVOKABLE void confirmPairingResponse(const QVariantMap &params);
    Q_INVOKABLE void setPluginConfigResponse(const QVariantMap &params);
    Q_INVOKABLE void editDeviceResponse(const QVariantMap &params);
    Q_INVOKABLE void executeActionResponse(const QVariantMap &params);
    Q_INVOKABLE void reconfigureDeviceResponse(const QVariantMap &params);
    Q_INVOKABLE void browseDeviceResponse(const QVariantMap &params);
    Q_INVOKABLE void browserItemResponse(const QVariantMap &params);
    Q_INVOKABLE void executeBrowserItemResponse(const QVariantMap &params);
    Q_INVOKABLE void executeBrowserItemActionResponse(const QVariantMap &params);

public slots:
    void savePluginConfig(const QUuid &pluginId);

signals:
    void pairDeviceReply(const QVariantMap &params);
    void confirmPairingReply(const QVariantMap &params);
    void addDeviceReply(const QVariantMap &params);
    void removeDeviceReply(const QVariantMap &params);
    void savePluginConfigReply(const QVariantMap &params);
    void editDeviceReply(const QVariantMap &params);
    void reconfigureDeviceReply(const QVariantMap &params);
    void executeActionReply(const QVariantMap &params);
    void executeBrowserItemReply(const QVariantMap &params);
    void executeBrowserItemActionReply(const QVariantMap &params);
    void fetchingDataChanged();
    void notificationReceived(const QString &deviceId, const QString &eventTypeId, const QVariantList &params);

    void eventTriggered(const QString &deviceId, const QString &eventTypeId, const QVariantMap params);

private:
    Vendors *m_vendors;
    Plugins *m_plugins;
    Devices *m_devices;
    DeviceClasses *m_deviceClasses;

    bool m_fetchingData = false;

    int m_currentGetConfigIndex = 0;

    JsonRpcClient *m_jsonClient = nullptr;

    QHash<int, QPointer<BrowserItems> > m_browsingRequests;
    QHash<int, QPointer<BrowserItem> > m_browserDetailsRequests;



};

// TODO: Kinda shitty that Device Events are not sent from the Devices namespace...
class EventHandler: public JsonHandler {
    Q_OBJECT

public:
    EventHandler(QObject *parent = nullptr): JsonHandler(parent) {}
    QString nameSpace() const override {
        return "Events";
    }

signals:
    void eventReceived(const QVariantMap &event);

private:
    Q_INVOKABLE void notificationReceived(const QVariantMap &data) {
        emit eventReceived(data.value("params").toMap().value("event").toMap());
    }

};

#endif // DEVICEMANAGER_H
