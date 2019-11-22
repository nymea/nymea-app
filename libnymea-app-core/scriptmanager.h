#ifndef SCRIPTMANAGER_H
#define SCRIPTMANAGER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"

class Scripts;

class ScriptManager : public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(Scripts* scripts READ scripts CONSTANT)

public:
    explicit ScriptManager(JsonRpcClient* jsonClient, QObject *parent = nullptr);

    void init();

    QString nameSpace() const override;

    Scripts *scripts() const;

public slots:
    int addScript(const QString &content);
    int editScript(const QUuid &id, const QString &content);
    int removeScript(const QUuid &id);
    int fetchScript(const QUuid &id);

signals:
    void scriptAdded(int id, const QString &scriptError, const QUuid &scriptId, const QStringList &errors);
    void scriptEdited(int id, const QString &scriptError, const QStringList &errors);
    void scriptRemoved(int id, const QString &scriptError);
    void scriptFetched(int id, const QString &scriptError, const QString &content);

    void scriptMessage(const QUuid &scriptId, const QString &type, const QString &message);

private slots:
    void onScriptsFetched(const QVariantMap &params);
    void onScriptFetched(const QVariantMap &params);
    void onScriptAdded(const QVariantMap &params);
    void onScriptEdited(const QVariantMap &params);
    void onScriptRemoved(const QVariantMap &params);

    void onNotificationReceived(const QVariantMap &params);
private:
    JsonRpcClient* m_client = nullptr;
    Scripts *m_scripts = nullptr;
};

#endif // SCRIPTMANAGER_H
