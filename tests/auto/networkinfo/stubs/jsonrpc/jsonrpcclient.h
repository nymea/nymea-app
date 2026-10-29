// SPDX-License-Identifier: GPL-3.0-or-later
// Test stub replacing libnymea-app/jsonrpc/jsonrpcclient.h for tst_networkinfo
#ifndef JSONRPCCLIENT_H
#define JSONRPCCLIENT_H

#include <QObject>
#include <QPointer>
#include <QVariantMap>

class JsonRpcClient : public QObject
{
    Q_OBJECT
public:
    struct Request {
        int id;
        QString method;
        QPointer<QObject> caller;
        QString callback;
    };

    explicit JsonRpcClient(QObject *parent = nullptr) : QObject(parent) {}

    bool connected() const { return m_connected; }
    void setConnected(bool connected) { m_connected = connected; emit connectedChanged(connected); }

    void registerNotificationHandler(QObject *handler, const QString &nameSpace, const QString &method) { m_handler = handler; m_nameSpace = nameSpace; m_handlerMethod = method; }
    void unregisterNotificationHandler(QObject *handler) { if (m_handler == handler) m_handler = nullptr; }

    int sendCommand(const QString &method, const QVariantMap &params, QObject *caller = nullptr, const QString &callbackMethod = QString())
    {
        Q_UNUSED(params)
        m_requests.append({++m_id, method, caller, callbackMethod});
        return m_id;
    }

    // Test helpers
    QList<Request> m_requests;
    QPointer<QObject> m_handler;
    QString m_nameSpace;
    QString m_handlerMethod;

    void reply(const Request &request, const QVariantMap &params)
    {
        QMetaObject::invokeMethod(request.caller, request.callback.toLatin1().constData(), Q_ARG(int, request.id), Q_ARG(QVariantMap, params));
    }

    void notify(const QString &notification, const QVariantMap &params)
    {
        QVariantMap data {{"notification", notification}, {"params", params}};
        QMetaObject::invokeMethod(m_handler, m_handlerMethod.toLatin1().constData(), Q_ARG(QVariantMap, data));
    }

signals:
    void connectedChanged(bool connected);

private:
    bool m_connected = false;
    int m_id = 0;
};

#endif // JSONRPCCLIENT_H
