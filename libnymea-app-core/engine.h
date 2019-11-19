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

private slots:
    void onConnectedChanged();
    void onDeviceManagerFetchingChanged();

};

#endif // ENGINE_H
