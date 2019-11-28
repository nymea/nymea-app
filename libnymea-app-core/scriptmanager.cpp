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

void ScriptManager::onScriptsFetched(const QVariantMap &params)
{
    foreach (const QVariant &variant, params.value("params").toMap().value("scripts").toList()) {
        QUuid id = variant.toMap().value("id").toUuid();
        Script *script = new Script(id);
        script->setName(variant.toMap().value("name").toString());
        m_scripts->addScript(script);
    }
}

void ScriptManager::onScriptFetched(const QVariantMap &params)
{
    emit fetchScriptReply(params.value("id").toInt(),
                       params.value("params").toMap().value("scriptError").toString(),
                       params.value("params").toMap().value("content").toString());
}

void ScriptManager::onScriptAdded(const QVariantMap &params)
{
    emit addScriptReply(params.value("id").toInt(),
                     params.value("params").toMap().value("scriptError").toString(),
                     params.value("params").toMap().value("script").toMap().value("id").toUuid(),
                     params.value("params").toMap().value("errors").toStringList());

}

void ScriptManager::onScriptEdited(const QVariantMap &params)
{
    emit editScriptReply(params.value("id").toInt(),
                      params.value("params").toMap().value("scriptError").toString(),
                      params.value("params").toMap().value("errors").toStringList());

}

void ScriptManager::onScriptRenamed(const QVariantMap &params)
{
    emit renameScriptReply(params.value("id").toInt(), params.value("params").toMap().value("scriptError").toString());
}

void ScriptManager::onScriptRemoved(const QVariantMap &params)
{
    emit removeScriptReply(params.value("id").toInt(), params.value("params").toMap().value("scriptError").toString());
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
        emit addScriptReply(params.value("id").toInt(),
                            params.value("params").toMap().value("scriptError").toString(),
                            params.value("params").toMap().value("scriptId").toUuid(),
                            params.value("params").toMap().value("errors").toStringList());
    }

    else if (params.value("notification").toString() == "Scripts.ScriptRemoved") {
        QUuid id = params.value("params").toMap().value("id").toUuid();
        m_scripts->removeScript(id);
        emit removeScriptReply(params.value("id").toInt(), params.value("params").toMap().value("scriptError").toString());
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
