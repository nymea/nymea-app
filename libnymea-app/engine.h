// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>

#include "thingmanager.h"
#include "connection/nymeatransportinterface.h"
#include "jsonrpc/jsonrpcclient.h"

#include "rulemanager.h"
#include "scriptmanager.h"
#include "logmanager.h"
#include "tagsmanager.h"
#include "configuration/nymeaconfiguration.h"
#include "system/systemcontroller.h"

class Engine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ThingManager* thingManager READ thingManager CONSTANT)
    Q_PROPERTY(RuleManager* ruleManager READ ruleManager CONSTANT)
    Q_PROPERTY(ScriptManager* scriptManager READ scriptManager CONSTANT)
    Q_PROPERTY(TagsManager* tagsManager READ tagsManager CONSTANT)
    Q_PROPERTY(JsonRpcClient* jsonRpcClient READ jsonRpcClient CONSTANT)
    Q_PROPERTY(NymeaConfiguration* nymeaConfiguration READ nymeaConfiguration CONSTANT)
    Q_PROPERTY(SystemController* systemController READ systemController CONSTANT)

public:
    explicit Engine(QObject *parent = nullptr);

    ThingManager *thingManager() const;
    RuleManager *ruleManager() const;
    ScriptManager *scriptManager() const;
    TagsManager *tagsManager() const;
    JsonRpcClient *jsonRpcClient() const;
    LogManager *logManager() const;
    NymeaConfiguration *nymeaConfiguration() const;
    SystemController *systemController() const;

private:
    JsonRpcClient *m_jsonRpcClient;
    ThingManager *m_thingManager;
    RuleManager *m_ruleManager;
    ScriptManager *m_scriptManager;
    LogManager *m_logManager;
    TagsManager *m_tagsManager;
    NymeaConfiguration *m_nymeaConfiguration;
    SystemController *m_systemController;

private slots:
    void onConnectedChanged();
    void onThingManagerFetchingChanged();

};

Q_DECLARE_METATYPE(Engine*)

#endif // ENGINE_H
