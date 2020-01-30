#ifndef USERSMANAGER_H
#define USERSMANAGER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"

class UsersManager: public JsonHandler
{
    Q_OBJECT
public:
    explicit UsersManager(JsonRpcClient *client, QObject *parent = nullptr);

    QString nameSpace() const override;

private slots:
    void notificationReceived(const QVariantMap &data);

private:
    JsonRpcClient *m_jsonRpcClient = nullptr;
};

#endif // USERSMANAGER_H
