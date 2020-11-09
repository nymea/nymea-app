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

#ifndef ZIGBEEMANAGER_H
#define ZIGBEEMANAGER_H

#include <QObject>
#include "zigbeeadapter.h"
#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;
class ZigbeeAdapters;
class ZigbeeNetwork;
class ZigbeeNetworks;

class ZigbeeManager : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(ZigbeeAdapters *adapters READ adapters CONSTANT)
    Q_PROPERTY(ZigbeeNetworks *networks READ networks CONSTANT)

public:
    explicit ZigbeeManager(JsonRpcClient* client, QObject *parent = nullptr);
    ~ZigbeeManager();

    QString nameSpace() const override;

    ZigbeeAdapters *adapters() const;
    ZigbeeNetworks *networks() const;

    Q_INVOKABLE void addNetwork(const QString &serialPort, uint baudRate, ZigbeeAdapter::ZigbeeBackendType backendType);
    Q_INVOKABLE void removeNetwork(const QUuid &networkUuid);
    Q_INVOKABLE void setPermitJoin(const QUuid &networkUuid, uint duration = 120);
    Q_INVOKABLE void factoryResetNetwork(const QUuid &networkUuid);

    void init();

signals:

private:
    Q_INVOKABLE void getAdaptersResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getNetworksResponse(int commandId, const QVariantMap &params);

    Q_INVOKABLE void addNetworkResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeNetworkResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setPermitJoinResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void factoryResetNetworkResponse(int commandId, const QVariantMap &params);


    Q_INVOKABLE void notificationReceived(const QVariantMap &notification);

private:
    JsonRpcClient* m_client = nullptr;
    ZigbeeAdapters *m_adapters = nullptr;
    ZigbeeNetworks *m_networks = nullptr;

    ZigbeeAdapter *unpackAdapter(const QVariantMap &adapterMap);
    ZigbeeNetwork *unpackNetwork(const QVariantMap &networkMap);
    void fillNetworkData(ZigbeeNetwork *network, const QVariantMap &networkMap);

};

#endif // ZIGBEEMANAGER_H
