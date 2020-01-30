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

#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>

#include "devicemanager.h"
#include "connection/nymeatransportinterface.h"
#include "jsonrpc/jsonrpcclient.h"
#include "wifisetup/bluetoothdiscovery.h"

class RuleManager;
class ScriptManager;
class LogManager;
class TagsManager;
class NymeaConfiguration;
class SystemController;
class NetworkManager;
class UsersManager;

class Engine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(NymeaConnection* connection READ connection CONSTANT)
    Q_PROPERTY(DeviceManager* deviceManager READ deviceManager CONSTANT)
    Q_PROPERTY(RuleManager* ruleManager READ ruleManager CONSTANT)
    Q_PROPERTY(ScriptManager* scriptManager READ scriptManager CONSTANT)
    Q_PROPERTY(TagsManager* tagsManager READ tagsManager CONSTANT)
    Q_PROPERTY(JsonRpcClient* jsonRpcClient READ jsonRpcClient CONSTANT)
    Q_PROPERTY(NymeaConfiguration* nymeaConfiguration READ nymeaConfiguration CONSTANT)
    Q_PROPERTY(SystemController* systemController READ systemController CONSTANT)
    Q_PROPERTY(UsersManager* usersManager READ usersManager CONSTANT)

public:
    explicit Engine(QObject *parent = nullptr);

    bool connected() const;
    QString connectedHost() const;

    NymeaConnection *connection() const;
    DeviceManager *deviceManager() const;
    RuleManager *ruleManager() const;
    ScriptManager *scriptManager() const;
    TagsManager *tagsManager() const;
    JsonRpcClient *jsonRpcClient() const;
    LogManager *logManager() const;
    NymeaConfiguration *nymeaConfiguration() const;
    SystemController *systemController() const;
    UsersManager *usersManager() const;

    Q_INVOKABLE void deployCertificate();

private:
    NymeaConnection *m_connection;
    JsonRpcClient *m_jsonRpcClient;
    DeviceManager *m_deviceManager;
    RuleManager *m_ruleManager;
    ScriptManager *m_scriptManager;
    LogManager *m_logManager;
    TagsManager *m_tagsManager;
    NymeaConfiguration *m_nymeaConfiguration;
    SystemController *m_systemController;
    UsersManager *m_usersManager;

private slots:
    void onConnectedChanged();
    void onDeviceManagerFetchingChanged();

};

#endif // ENGINE_H
