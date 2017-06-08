/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef JSONRPCCLIENT_H
#define JSONRPCCLIENT_H

#include <QObject>
#include <QVariantMap>

#include "devicehandler.h"
#include "actionhandler.h"
#include "eventhandler.h"
#include "logginghandler.h"
#include "networkmanagerhandler.h"

class JsonRpcReply;
class JsonHandler;
class Param;
class Params;

class JsonRpcClient : public QObject
{
    Q_OBJECT
public:
    explicit JsonRpcClient(QObject *parent = 0);

    // internal
    void getVendors();
    void getPlugins();
    void getDevices();
    void getDeviceClasses();

    // ui methods
    Q_INVOKABLE int addDevice(const QUuid &deviceClassId, const QVariantList &deviceParams);
    Q_INVOKABLE int addDiscoveredDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId);
    Q_INVOKABLE int pairDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId);
    Q_INVOKABLE int confirmPairing(const QUuid &pairingTransactionId, const QString &secret = QString());
    Q_INVOKABLE int removeDevice(const QUuid &deviceId);
    Q_INVOKABLE int discoverDevices(const QUuid &deviceClassId, const QVariantList &discoveryParams = QVariantList());
    Q_INVOKABLE int executeAction(const QUuid &deviceId, const QUuid &actionTypeId, const QVariantList &params = QVariantList());

private:
    int m_id;
    QHash<QString, JsonHandler *> m_handlers;
    QHash<int, JsonRpcReply *> m_replies;

    DeviceHandler *m_deviceHandler;
    ActionHandler *m_actionHandler;
    EventHandler *m_eventHandler;
    LoggingHandler *m_loggingHandler;
    NetworkManagerHandler *m_networkManagerHandler;

    JsonRpcReply *createReply(QString nameSpace, QString method, QVariantMap params = QVariantMap());

signals:
    void responseReceived(const int &commandId, const QVariantMap &response);

public slots:
    void dataReceived(const QVariantMap &data);

};


class JsonRpcReply : public QObject
{
    Q_OBJECT
public:
    explicit JsonRpcReply(int commandId, QString nameSpace, QString method, QVariantMap params = QVariantMap(), QObject *parent = 0);

    int commandId() const;
    QString nameSpace() const;
    QString method() const;
    QVariantMap params() const;
    QVariantMap requestMap();

private:
    int m_commandId;
    QString m_nameSpace;
    QString m_method;
    QVariantMap m_params;
};


#endif // JSONRPCCLIENT_H
