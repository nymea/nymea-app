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

int ScriptManager::addScript(const QString &content)
{
    QVariantMap params;
    params.insert("name", "Test");
    params.insert("content", content);
    return m_client->sendCommand("Scripts.AddScript", params, this, "onScriptAdded");
}

int ScriptManager::editScript(const QUuid &id, const QString &content)
{
    QVariantMap params;
    params.insert("id", id);
    params.insert("content", content);
    qDebug() << "Calling EditScript" << content;
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
    qDebug() << "scripts fetched" << params;
    foreach (const QVariant &variant, params.value("params").toMap().value("scripts").toList()) {
        qDebug() << "script" << variant.toMap().value("id").toUuid();
        QUuid id = variant.toMap().value("id").toUuid();
        Script *script = new Script(id);
        script->setName(variant.toMap().value("name").toString());
        m_scripts->addScript(script);
        qDebug() << "Script added";
    }
}

void ScriptManager::onScriptFetched(const QVariantMap &params)
{
    qDebug() << "Script fetched" << params;
    emit scriptFetched(params.value("id").toInt(),
                       params.value("params").toMap().value("scriptError").toString(),
                       params.value("params").toMap().value("content").toString());
}

void ScriptManager::onScriptAdded(const QVariantMap &params)
{
    qDebug() << "Script added" << params;
    emit scriptAdded(params.value("id").toInt(),
                     params.value("params").toMap().value("scriptError").toString(),
                     params.value("params").toMap().value("script").toMap().value("id").toUuid(),
                     params.value("params").toMap().value("errors").toStringList());

}

void ScriptManager::onScriptEdited(const QVariantMap &params)
{
    qDebug() << "Script edited" << params;
//    emit scriptAdded(params.value("id").toInt(), params.value("script").toMap().value("id").toUuid());
    emit scriptEdited(params.value("id").toInt(),
                      params.value("params").toMap().value("scriptError").toString(),
                      params.value("params").toMap().value("errors").toStringList());

}

void ScriptManager::onScriptRemoved(const QVariantMap &params)
{
    emit scriptRemoved(params.value("id").toInt(), params.value("params").toMap().value("scriptError").toString());
}

void ScriptManager::onNotificationReceived(const QVariantMap &params)
{
    qDebug() << "noticication" << params;
    if (params.value("notification").toString() == "Scripts.ScriptLogMessage") {
        emit scriptMessage(params.value("params").toMap().value("scriptId").toUuid(),
                           params.value("params").toMap().value("type").toString(),
                           params.value("params").toMap().value("message").toString());
    }
}
