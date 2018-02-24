#ifndef LOGMANAGER_H
#define LOGMANAGER_H

#include <QObject>

#include "jsonrpc/jsonhandler.h"

class JsonRpcClient;

class LogManager : public JsonHandler
{
    Q_OBJECT
public:
    explicit LogManager(JsonRpcClient *jsonClient, QObject *parent = nullptr);

    QString nameSpace() const override;

signals:
    void logEntryReceived(const QVariantMap &data);

private:
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);

private:
    JsonRpcClient *m_client = nullptr;
};

#endif // LOGMANAGER_H
