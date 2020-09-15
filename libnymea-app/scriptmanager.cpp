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

#include "scriptmanager.h"

#include "types/script.h"
#include "types/scripts.h"

ScriptManager::ScriptManager(JsonRpcClient *jsonClient, QObject *parent):
    JsonHandler(parent),
    m_client(jsonClient)
{
    m_scripts = new Scripts(this);

    m_client->registerNotificationHandler(this, "onNotificationReceived");
}

void ScriptManager::init()
{
    m_scripts->clear();
    m_client->sendCommand("Scripts.GetScripts", QVariantMap(), this, "onScriptsFetched");
}

QString ScriptManager::nameSpace() const
{
    return "Scripts";
}

Scripts *ScriptManager::scripts() const
{
    return m_scripts;
}

int ScriptManager::addScript(const QString &name, const QString &content)
{
    QVariantMap params;
    params.insert("name", name);
    params.insert("content", content);
    return m_client->sendCommand("Scripts.AddScript", params, this, "onScriptAdded");
}

int ScriptManager::renameScript(const QUuid &id, const QString &name)
{
    QVariantMap params;
    params.insert("id", id);
    params.insert("name", name);
    return m_client->sendCommand("Scripts.EditScript", params, this, "onScriptRenamed");
}

int ScriptManager::editScript(const QUuid &id, const QString &content)
{
    QVariantMap params;
    params.insert("id", id);
    params.insert("content", content);
    return m_client->sendCommand("Scripts.EditScript", params, this, "onScriptEdited");
}

int ScriptManager::removeScript(const QUuid &id)
{
    QVariantMap params;
    params.insert("id", id);
    return m_client->sendCommand("Scripts.RemoveScript", params, this, "onScriptRemoved");
}

int ScriptManager::fetchScript(const QUuid &id)
{
    QVariantMap params;
    params.insert("id", id);
    return m_client->sendCommand("Scripts.GetScriptContent", params, this, "onScriptFetched");
}

void ScriptManager::onScriptsFetched(int /*commandId*/, const QVariantMap &params)
{
    foreach (const QVariant &variant, params.value("scripts").toList()) {
        QUuid id = variant.toMap().value("id").toUuid();
        Script *script = new Script(id);
        script->setName(variant.toMap().value("name").toString());
        m_scripts->addScript(script);
    }
}

void ScriptManager::onScriptFetched(int commandId, const QVariantMap &params)
{
    emit fetchScriptReply(commandId,
                       params.value("scriptError").toString(),
                       params.value("content").toString());
}

void ScriptManager::onScriptAdded(int commandId, const QVariantMap &params)
{
    emit addScriptReply(commandId,
                     params.value("scriptError").toString(),
                     params.value("script").toMap().value("id").toUuid(),
                     params.value("errors").toStringList());

}

void ScriptManager::onScriptEdited(int commandId, const QVariantMap &params)
{
    emit editScriptReply(commandId,
                      params.value("scriptError").toString(),
                      params.value("errors").toStringList());

}

void ScriptManager::onScriptRenamed(int commandId, const QVariantMap &params)
{
    emit renameScriptReply(commandId, params.value("scriptError").toString());
}

void ScriptManager::onScriptRemoved(int commandId, const QVariantMap &params)
{
    emit removeScriptReply(commandId, params.value("scriptError").toString());
}

void ScriptManager::onNotificationReceived(const QVariantMap &params)
{
    qDebug() << "noticication" << params.value("notification").toString();
    if (params.value("notification").toString() == "Scripts.ScriptLogMessage") {
        emit scriptMessage(params.value("params").toMap().value("scriptId").toUuid(),
                           params.value("params").toMap().value("type").toString(),
                           params.value("params").toMap().value("message").toString());
    }

    else if (params.value("notification").toString() == "Scripts.ScriptAdded") {
        QVariantMap scriptMap = params.value("params").toMap().value("script").toMap();
        Script *script = new Script(scriptMap.value("id").toUuid());
        script->setName(scriptMap.value("name").toString());
        m_scripts->addScript(script);
    }

    else if (params.value("notification").toString() == "Scripts.ScriptRemoved") {
        QUuid id = params.value("params").toMap().value("id").toUuid();
        m_scripts->removeScript(id);
    }

    else if (params.value("notification").toString() == "Scripts.ScriptChanged") {
        QUuid id = params.value("params").toMap().value("scriptId").toUuid();
        QString name = params.value("params").toMap().value("name").toString();
        m_scripts->getScript(id)->setName(name);
    }

    else {
        qWarning() << "Unhandled notification" << params.value("notification").toString();
    }
}
