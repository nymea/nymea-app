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

#include "engine.h"

#include "tcpsocketinterface.h"
#include "rulemanager.h"
#include "logmanager.h"
#include "tagsmanager.h"
#include "basicconfiguration.h"
#include "awsclient.h"

Engine* Engine::s_instance = nullptr;

Engine *Engine::instance()
{
    if (!s_instance)
        s_instance = new Engine();

    return s_instance;
}

DeviceManager *Engine::deviceManager() const
{
    return m_deviceManager;
}

RuleManager *Engine::ruleManager() const
{
    return m_ruleManager;
}

TagsManager *Engine::tagsManager() const
{
    return m_tagsManager;
}

JsonRpcClient *Engine::jsonRpcClient() const
{
    return m_jsonRpcClient;
}

LogManager *Engine::logManager() const
{
    return m_logManager;
}

BasicConfiguration *Engine::basicConfiguration() const
{
    return m_basicConfiguration;
}

BluetoothDiscovery *Engine::bluetoothDiscovery() const
{
    return m_bluetoothDiscovery;
}

AWSClient *Engine::awsClient() const
{
    return m_aws;
}

NymeaConnection *Engine::connection() const
{
    return m_connection;
}

Engine::Engine(QObject *parent) :
    QObject(parent),
    m_connection(new NymeaConnection(this)),
    m_jsonRpcClient(new JsonRpcClient(m_connection, this)),
    m_deviceManager(new DeviceManager(m_jsonRpcClient, this)),
    m_ruleManager(new RuleManager(m_jsonRpcClient, this)),
    m_logManager(new LogManager(m_jsonRpcClient, this)),
    m_tagsManager(new TagsManager(m_jsonRpcClient, this)),
    m_basicConfiguration(new BasicConfiguration(m_jsonRpcClient, this)),
    m_bluetoothDiscovery(new BluetoothDiscovery(this)),
    m_aws(new AWSClient(this))
{
    connect(m_jsonRpcClient, &JsonRpcClient::connectedChanged, this, &Engine::onConnectedChanged);
    connect(m_jsonRpcClient, &JsonRpcClient::authenticationRequiredChanged, this, &Engine::onConnectedChanged);

    connect(m_deviceManager, &DeviceManager::fetchingDataChanged, this, &Engine::onDeviceManagerFetchingChanged);
}

void Engine::onConnectedChanged()
{
    qDebug() << "Engine: connected changed:" << m_jsonRpcClient->connected();
    m_deviceManager->clear();
    m_ruleManager->clear();
    if (m_jsonRpcClient->connected()) {
        qDebug() << "Engine: inital setup required:" << m_jsonRpcClient->initialSetupRequired() << "auth required:" << m_jsonRpcClient->authenticationRequired();
        if (!m_jsonRpcClient->initialSetupRequired() && !m_jsonRpcClient->authenticationRequired()) {
            m_deviceManager->init();
            m_ruleManager->init();
            m_basicConfiguration->init();
        }
    }
}

void Engine::onDeviceManagerFetchingChanged()
{
    if (!m_deviceManager->fetchingData()) {
        if (m_jsonRpcClient->ensureServerVersion("1.7")) {
            m_tagsManager->init();
        }
    }
}
