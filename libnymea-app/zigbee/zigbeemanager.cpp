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
#include "zigbee/zigbeeadapters.h"

ZigbeeManager::ZigbeeManager(JsonRpcClient *client, QObject *parent) :
    JsonHandler(parent),
    m_client(client),
    m_adapters(new ZigbeeAdapters(this))
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

void ZigbeeManager::init()
{
    qDebug() << "Zigbee init...";
    m_adapters->clear();
    m_client->sendCommand("Zigbee.GetAdapters", this, "getAdaptersResponse");
}

void ZigbeeManager::getAdaptersResponse(const QVariantMap &params)
{
    qDebug() << "Get adapters response" << params;
    m_adapters->clear();
    foreach (const QVariant &adapterVariant, params.value("params").toMap().value("adapters").toList()) {
        QVariantMap adapterMap = adapterVariant.toMap();
        ZigbeeAdapter *adapter = new ZigbeeAdapter(m_adapters);
        adapter->setName(adapterMap.value("name").toString());
        adapter->setDescription(adapterMap.value("description").toString());
        adapter->setSystemLocation(adapterMap.value("systemLocation").toString());
        adapter->setBackendType(ZigbeeAdapter::stringToZigbeeBackendType(adapterMap.value("backendType").toString()));
        adapter->setBaudRate(adapterMap.value("baudRate").toUInt());
        qDebug() << "Zigbee adapter added" << adapter->description() << adapter->systemLocation();
        m_adapters->addAdapter(adapter);
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

    qDebug() << "Unhandled Zigbee notification" << notificationString << notification;
}

ZigbeeAdapter *ZigbeeManager::unpackAdapter(const QVariantMap &adapterMap)
{
    ZigbeeAdapter *adapter = new ZigbeeAdapter(m_adapters);
    adapter->setName(adapterMap.value("name").toString());
    adapter->setDescription(adapterMap.value("description").toString());
    adapter->setSystemLocation(adapterMap.value("systemLocation").toString());
    adapter->setBackendType(ZigbeeAdapter::stringToZigbeeBackendType(adapterMap.value("backendType").toString()));
    adapter->setBaudRate(adapterMap.value("baudRate").toUInt());
    return adapter;
}

