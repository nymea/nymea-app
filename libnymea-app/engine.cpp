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

#include "engine.h"

#include "rulemanager.h"
#include "scriptmanager.h"
#include "logmanager.h"
#include "tagsmanager.h"
#include "configuration/nymeaconfiguration.h"
#include "system/systemcontroller.h"
#include "configuration/networkmanager.h"

Engine::Engine(QObject *parent) :
    QObject(parent),
    m_jsonRpcClient(new JsonRpcClient(this)),
    m_thingManager(new ThingManager(m_jsonRpcClient, this)),
    m_ruleManager(new RuleManager(m_jsonRpcClient, this)),
    m_scriptManager(new ScriptManager(m_jsonRpcClient, this)),
    m_logManager(new LogManager(m_jsonRpcClient, this)),
    m_tagsManager(new TagsManager(m_jsonRpcClient, this)),
    m_nymeaConfiguration(new NymeaConfiguration(m_jsonRpcClient, this)),
    m_systemController(new SystemController(m_jsonRpcClient, this))
{

    connect(m_jsonRpcClient, &JsonRpcClient::connectedChanged, this, &Engine::onConnectedChanged);

    connect(m_thingManager, &ThingManager::fetchingDataChanged, this, &Engine::onThingManagerFetchingChanged);

    connect(m_jsonRpcClient, &JsonRpcClient::connectedChanged, this, [this]() {
        qDebug() << "JSONRpc connected changed:" << m_jsonRpcClient->connected() << "AWS status:" << AWSClient::instance()->awsDevices()->rowCount();
        if (m_jsonRpcClient->connected() && m_jsonRpcClient->cloudConnectionState() == JsonRpcClient::CloudConnectionStateConnected) {
            if (AWSClient::instance()->awsDevices()->getDevice(m_jsonRpcClient->serverUuid().toString()) == nullptr) {
                m_jsonRpcClient->setupRemoteAccess(AWSClient::instance()->idToken(), AWSClient::instance()->userId());
            }
        }
    });
    connect(m_jsonRpcClient, &JsonRpcClient::cloudConnectionStateChanged, this, [this](){
        if (m_jsonRpcClient->connected() && m_jsonRpcClient->cloudConnectionState() == JsonRpcClient::CloudConnectionStateConnected) {
            if (AWSClient::instance()->awsDevices()->getDevice(m_jsonRpcClient->serverUuid().toString()) == nullptr) {
                m_jsonRpcClient->setupRemoteAccess(AWSClient::instance()->idToken(), AWSClient::instance()->userId());
            }
        }
    });
}

ThingManager *Engine::thingManager() const
{
    return m_thingManager;
}

RuleManager *Engine::ruleManager() const
{
    return m_ruleManager;
}

ScriptManager *Engine::scriptManager() const
{
    return m_scriptManager;
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

NymeaConfiguration *Engine::nymeaConfiguration() const
{
    return m_nymeaConfiguration;
}

SystemController *Engine::systemController() const
{
    return m_systemController;
}

void Engine::deployCertificate()
{
    if (!m_jsonRpcClient->connected()) {
        qWarning() << "JSONRPC not connected. Cannot deploy certificate";
        return;
    }
    if (!AWSClient::instance()->isLoggedIn()) {
        qWarning() << "Not logged in at AWS. Cannot deploy certificate";
        return;
    }
    AWSClient::instance()->fetchCertificate(m_jsonRpcClient->serverUuid().toString(), [this](const QByteArray &rootCA, const QByteArray &certificate, const QByteArray &publicKey, const QByteArray &privateKey, const QString &endpoint){
        qDebug() << "Certificate received" << certificate << publicKey << privateKey;
        m_jsonRpcClient->deployCertificate(rootCA, certificate, publicKey, privateKey, endpoint);
    });
}

void Engine::onConnectedChanged()
{
    qDebug() << "Engine: connected changed:" << m_jsonRpcClient->connected();
    m_thingManager->clear();
    m_ruleManager->clear();
    m_tagsManager->clear();
    if (m_jsonRpcClient->connected()) {
        qDebug() << "Engine: inital setup required:" << m_jsonRpcClient->initialSetupRequired() << "auth required:" << m_jsonRpcClient->authenticationRequired();
        if (!m_jsonRpcClient->initialSetupRequired() && !m_jsonRpcClient->authenticationRequired()) {
            m_thingManager->init();
        }
    }
}

void Engine::onThingManagerFetchingChanged()
{
    if (!m_thingManager->fetchingData()) {
        m_tagsManager->init();
        m_ruleManager->init();
        m_scriptManager->init();
        m_nymeaConfiguration->init();
        m_systemController->init();
    }
}
