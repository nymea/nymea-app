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

#include "jsonrpcclient.h"
#include "engine.h"
#include "types/param.h"
#include "types/params.h"

#include <QJsonDocument>
#include <QVariantMap>
#include <QDebug>

JsonRpcClient::JsonRpcClient(QObject *parent) :
    QObject(parent),
    m_id(0)
{
    m_deviceHandler = new DeviceHandler(this);
    m_actionHandler = new ActionHandler(this);
    m_eventHandler = new EventHandler(this);
    m_loggingHandler = new LoggingHandler(this);
    m_networkManagerHandler = new NetworkManagerHandler(this);

    m_handlers.insert(m_deviceHandler->nameSpace(), m_deviceHandler);
    m_handlers.insert(m_actionHandler->nameSpace(), m_actionHandler);
    m_handlers.insert(m_eventHandler->nameSpace(), m_eventHandler);
    m_handlers.insert(m_loggingHandler->nameSpace(), m_loggingHandler);
    m_handlers.insert(m_networkManagerHandler->nameSpace(), m_networkManagerHandler);
}

void JsonRpcClient::getVendors()
{
    qDebug() << "JsonRpc: get vendors";
    JsonRpcReply *reply = createReply("Devices", "GetSupportedVendors");
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
}

void JsonRpcClient::getPlugins()
{
    qDebug() << "JsonRpc: get plugins";
    JsonRpcReply *reply = createReply("Devices", "GetPlugins");
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
}

void JsonRpcClient::getDevices()
{
    qDebug() << "JsonRpc: get devices";
    JsonRpcReply *reply = createReply("Devices", "GetConfiguredDevices");
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
}

void JsonRpcClient::getDeviceClasses()
{
    qDebug() << "JsonRpc: get device classes";
    JsonRpcReply *reply = createReply("Devices", "GetSupportedDevices");
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
}

int JsonRpcClient::addDevice(const QUuid &deviceClassId, const QVariantList &deviceParams)
{
    qDebug() << "JsonRpc: add device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("deviceParams", deviceParams);
    JsonRpcReply *reply = createReply("Devices", "AddConfiguredDevice", params);
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
    return reply->commandId();
}

int JsonRpcClient::addDiscoveredDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId)
{
    qDebug() << "JsonRpc: add discovered device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("deviceDescriptorId", deviceDescriptorId.toString());
    JsonRpcReply *reply = createReply("Devices", "AddConfiguredDevice", params);
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
    return reply->commandId();
}

int JsonRpcClient::pairDevice(const QUuid &deviceClassId, const QUuid &deviceDescriptorId)
{
    qDebug() << "JsonRpc: pair device " << deviceClassId.toString();
    QVariantMap params;
    params.insert("name", "name");
    params.insert("deviceClassId", deviceClassId.toString());
    params.insert("deviceDescriptorId", deviceDescriptorId.toString());
    JsonRpcReply *reply = createReply("Devices", "PairDevice", params);
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
    return reply->commandId();
}

int JsonRpcClient::confirmPairing(const QUuid &pairingTransactionId, const QString &secret)
{
    qDebug() << "JsonRpc: confirm pairing" << pairingTransactionId.toString();
    QVariantMap params;
    params.insert("pairingTransactionId", pairingTransactionId.toString());
    params.insert("secret", secret);
    JsonRpcReply *reply = createReply("Devices", "ConfirmPairing", params);
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
    return reply->commandId();
}

int JsonRpcClient::removeDevice(const QUuid &deviceId)
{
    qDebug() << "JsonRpc: delete device" << deviceId.toString();
    QVariantMap params;
    params.insert("deviceId", deviceId.toString());
    JsonRpcReply *reply = createReply("Devices", "RemoveConfiguredDevice", params);
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
    return reply->commandId();
}

int JsonRpcClient::discoverDevices(const QUuid &deviceClassId, const QVariantList &discoveryParams)
{
    qDebug() << "JsonRpc: discover devices " << deviceClassId.toString();
    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    if (!discoveryParams.isEmpty()) {
        params.insert("discoveryParams", discoveryParams);
    }

    JsonRpcReply *reply = createReply("Devices", "GetDiscoveredDevices", params);
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
    return reply->commandId();
}

int JsonRpcClient::executeAction(const QUuid &deviceId, const QUuid &actionTypeId, const QVariantList &params)
{
    qDebug() << "JsonRpc: execute action " << deviceId.toString() << actionTypeId.toString() << params;
    QVariantMap p;
    p.insert("deviceId", deviceId.toString());
    p.insert("actionTypeId", actionTypeId.toString());
    if (!params.isEmpty()) {
        p.insert("params", params);
    }

    JsonRpcReply *reply = createReply("Actions", "ExecuteAction", p);
    m_replies.insert(reply->commandId(), reply);
    Engine::instance()->interface()->sendRequest(reply->requestMap());
    return reply->commandId();
}

JsonRpcReply *JsonRpcClient::createReply(QString nameSpace, QString method, QVariantMap params)
{
    m_id++;
    return new JsonRpcReply(m_id, nameSpace, method, params, this);
}

void JsonRpcClient::dataReceived(const QVariantMap &data)
{
    int commandId = data.value("id").toInt();
    JsonRpcReply *reply = m_replies.take(commandId);

    // check if this is a reply to a request
    if (reply) {
        qDebug() << "JsonRpc: got response for" << QString("%1.%2").arg(reply->nameSpace(), reply->method());
        JsonHandler *handler = m_handlers.value(reply->nameSpace());

        if (!QMetaObject::invokeMethod(handler, QString("process" + reply->method()).toLatin1().data(), Q_ARG(QVariantMap, data)))
            qWarning() << "JsonRpc: method not implemented:" << reply->method();

        emit responseReceived(reply->commandId(), data.value("params").toMap());
        return;
    }

    // check if this is a notification
    if (data.contains("notification")) {
        QStringList notification = data.value("notification").toString().split(".");
        QString nameSpace = notification.first();
        QString method = notification.last();
        JsonHandler *handler = m_handlers.value(nameSpace);

        if (!handler) {
            qWarning() << "JsonRpc: handler not implemented:" << nameSpace;
            return;
        }

        if (!QMetaObject::invokeMethod(handler, QString("process" + method).toLatin1().data(), Q_ARG(QVariantMap, data)))
            qWarning() << "method not implemented";

    }
}

JsonRpcReply::JsonRpcReply(int commandId, QString nameSpace, QString method, QVariantMap params, QObject *parent):
    QObject(parent),
    m_commandId(commandId),
    m_nameSpace(nameSpace),
    m_method(method),
    m_params(params)
{
}

int JsonRpcReply::commandId() const
{
    return m_commandId;
}

QString JsonRpcReply::nameSpace() const
{
    return m_nameSpace;
}

QString JsonRpcReply::method() const
{
    return m_method;
}

QVariantMap JsonRpcReply::params() const
{
    return m_params;
}

QVariantMap JsonRpcReply::requestMap()
{
    QVariantMap request;
    request.insert("id", m_commandId);
    request.insert("method", m_nameSpace + "." + m_method);
    if (!m_params.isEmpty())
        request.insert("params", m_params);

    return request;
}
