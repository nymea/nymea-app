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

#include "zigbeemanager.h"

#include "jsonrpc/jsonrpcclient.h"
#include "zigbee/zigbeeadapter.h"
#include "zigbee/zigbeeadapters.h"
#include "zigbee/zigbeenetwork.h"
#include "zigbee/zigbeenetworks.h"

ZigbeeManager::ZigbeeManager(JsonRpcClient *client, QObject *parent) :
    JsonHandler(parent),
    m_client(client),
    m_adapters(new ZigbeeAdapters(this)),
    m_networks(new ZigbeeNetworks(this))
{
    client->registerNotificationHandler(this, "notificationReceived");
}

ZigbeeManager::~ZigbeeManager()
{

}

QString ZigbeeManager::nameSpace() const
{
    return "Zigbee";
}

ZigbeeAdapters *ZigbeeManager::adapters() const
{
    return m_adapters;
}

ZigbeeNetworks *ZigbeeManager::networks() const
{
    return m_networks;
}

void ZigbeeManager::init()
{
    qDebug() << "Zigbee init...";
    m_adapters->clear();
    m_client->sendCommand("Zigbee.GetAdapters", this, "getAdaptersResponse");
    m_client->sendCommand("Zigbee.GetNetworks", this, "getNetworksResponse");
}

void ZigbeeManager::getAdaptersResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Zigbee get adapters response" << commandId << params;
    m_adapters->clear();
    foreach (const QVariant &adapterVariant, params.value("adapters").toList()) {
        QVariantMap adapterMap = adapterVariant.toMap();
        ZigbeeAdapter *adapter = unpackAdapter(adapterMap);
        qDebug() << "Zigbee adapter added" << adapter->description() << adapter->systemLocation();
        m_adapters->addAdapter(adapter);
    }
}

void ZigbeeManager::getNetworksResponse(int commandId, const QVariantMap &params)
{
    qDebug() << "Zigbee get networks response" << commandId << params;
    m_adapters->clear();
    foreach (const QVariant &networkVariant, params.value("zigbeeNetworks").toList()) {
        QVariantMap networkMap = networkVariant.toMap();
        ZigbeeNetwork *network = unpackNetwork(networkMap);
        qDebug() << "Zigbee network added" << network->networkUuid().toString() << network->serialPort() << network->macAddress();
        m_networks->addNetwork(network);
    }
}

void ZigbeeManager::notificationReceived(const QVariantMap &notification)
{
    QString notificationString = notification.value("notification").toString();
    if (notificationString == "Zigbee.AdapterAdded") {
        QVariantMap adapterMap = notification.value("params").toMap().value("adapter").toMap();
        m_adapters->addAdapter(unpackAdapter(adapterMap));
        return;
    }

    if (notificationString == "Zigbee.AdapterRemoved") {
        QVariantMap adapterMap = notification.value("params").toMap().value("adapter").toMap();
        m_adapters->removeAdapter(adapterMap.value("systemLocation").toString());
        return;
    }

    if (notificationString == "Zigbee.NetworkAdded") {
        QVariantMap networkMap = notification.value("params").toMap().value("zigbeeNetwork").toMap();
        m_networks->addNetwork(unpackNetwork(networkMap));
        return;
    }

    if (notificationString == "Zigbee.NetworkRemoved") {
        QUuid networkUuid = notification.value("params").toMap().value("zigbeeNetwork").toUuid();
        m_networks->removeNetwork(networkUuid);
        return;
    }

    if (notificationString == "Zigbee.NetworkChanged") {
        QVariantMap networkMap = notification.value("params").toMap().value("zigbeeNetwork").toMap();
        QUuid networkUuid = networkMap.value("networkUuid").toUuid();
        ZigbeeNetwork *network = m_networks->getNetwork(networkUuid);
        if (!network) {
            qWarning() << "Could not find network for changed notification";
            return;
        }
        fillNetworkData(network, networkMap);
        return;
    }

    qDebug() << "Unhandled Zigbee notification" << notificationString << notification;
}

ZigbeeAdapter *ZigbeeManager::unpackAdapter(const QVariantMap &adapterMap)
{
    ZigbeeAdapter *adapter = new ZigbeeAdapter(m_adapters);
    adapter->setName(adapterMap.value("name").toString());
    adapter->setDescription(adapterMap.value("description").toString());
    adapter->setSystemLocation(adapterMap.value("systemLocation").toString());
    adapter->setHardwareRecognized(adapterMap.value("hardwareRecognized").toBool());
    adapter->setBackendType(ZigbeeAdapter::stringToZigbeeBackendType(adapterMap.value("backendType").toString()));
    adapter->setBaudRate(adapterMap.value("baudRate").toUInt());
    return adapter;
}

ZigbeeNetwork *ZigbeeManager::unpackNetwork(const QVariantMap &networkMap)
{
    ZigbeeNetwork *network = new ZigbeeNetwork(m_networks);
    fillNetworkData(network, networkMap);
    return network;
}

void ZigbeeManager::fillNetworkData(ZigbeeNetwork *network, const QVariantMap &networkMap)
{
    network->setNetworkUuid(networkMap.value("networkUuid").toUuid());
    network->setSerialPort(networkMap.value("serialPort").toString());
    network->setBaudRate(networkMap.value("baudRate").toUInt());
    network->setMacAddress(networkMap.value("macAddress").toString());
    network->setFirmwareVersion(networkMap.value("firmwareVersion").toString());
    network->setPanId(networkMap.value("panId").toUInt());
    network->setChannel(networkMap.value("channel").toUInt());
    network->setChannelMask(networkMap.value("channelMask").toUInt());
    network->setPermitJoiningEnabled(networkMap.value("permitJoiningEnabled").toBool());
    network->setPermitJoiningDuration(networkMap.value("permitJoiningDuration").toUInt());
    network->setPermitJoiningRemaining(networkMap.value("permitJoiningRemaining").toUInt());
    network->setBackendType(ZigbeeAdapter::stringToZigbeeBackendType(networkMap.value("backendType").toString()));
    network->setNetworkState(ZigbeeNetwork::stringToZigbeeNetworkState(networkMap.value("networkState").toString()));
}

