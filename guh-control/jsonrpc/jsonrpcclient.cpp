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
#include "guhconnection.h"
#include "types/param.h"
#include "types/params.h"

#include <QJsonDocument>
#include <QVariantMap>
#include <QDebug>
#include <QUuid>
#include <QSettings>
#include <QVersionNumber>

JsonRpcClient::JsonRpcClient(GuhConnection *connection, QObject *parent) :
    JsonHandler(parent),
    m_id(0),
    m_connection(connection)
{
    connect(m_connection, &GuhConnection::connectedChanged, this, &JsonRpcClient::onInterfaceConnectedChanged);
    connect(m_connection, &GuhConnection::dataAvailable, this, &JsonRpcClient::dataReceived);
}

QString JsonRpcClient::nameSpace() const
{
    return QStringLiteral("JSONRPC");
}

void JsonRpcClient::registerNotificationHandler(JsonHandler *handler, const QString &method)
{
    if (m_notificationHandlers.contains(handler->nameSpace())) {
        qWarning() << "Already have a notification handler for" << handler->nameSpace();
        return;
    }
    m_notificationHandlers.insert(handler->nameSpace(), qMakePair<JsonHandler*, QString>(handler, method));
}

void JsonRpcClient::sendCommand(const QString &method, const QVariantMap &params, QObject *caller, const QString &callbackMethod)
{
    JsonRpcReply *reply = createReply(method, params, caller, callbackMethod);
    m_replies.insert(reply->commandId(), reply);
    sendRequest(reply->requestMap());

}

void JsonRpcClient::sendCommand(const QString &method, QObject *caller, const QString &callbackMethod)
{
    return sendCommand(method, QVariantMap(), caller, callbackMethod);
}

void JsonRpcClient::setNotificationsEnabled(bool enabled)
{
    QVariantMap params;
    params.insert("notificationsEnabled", enabled);
    JsonRpcReply *reply = createReply("JSONRPC.SetNotificationsEnabled", params, this, "setNotificationsEnabledResponse");
    m_replies.insert(reply->commandId(), reply);
    sendRequest(reply->requestMap());
}

void JsonRpcClient::setNotificationsEnabledResponse(const QVariantMap &params)
{
    qDebug() << "Notifications enabled:" << params;
}

bool JsonRpcClient::connected() const
{
    return m_connected;
}

bool JsonRpcClient::initialSetupRequired() const
{
    return m_initialSetupRequired;
}

bool JsonRpcClient::authenticationRequired() const
{
    return m_authenticationRequired && m_token.isEmpty();
}

int JsonRpcClient::createUser(const QString &username, const QString &password)
{
    QVariantMap params;
    params.insert("username", username);
    params.insert("password", password);
    JsonRpcReply* reply = createReply("JSONRPC.CreateUser", params, this, "processCreateUser");
    m_replies.insert(reply->commandId(), reply);
    m_connection->sendData(QJsonDocument::fromVariant(reply->requestMap()).toJson());
    return reply->commandId();
}

int JsonRpcClient::authenticate(const QString &username, const QString &password, const QString &deviceName)
{
    QVariantMap params;
    params.insert("username", username);
    params.insert("password", password);
    params.insert("deviceName", deviceName);
    JsonRpcReply* reply = createReply("JSONRPC.Authenticate", params, this, "processAuthenticate");
    m_replies.insert(reply->commandId(), reply);
    m_connection->sendData(QJsonDocument::fromVariant(reply->requestMap()).toJson());
    return reply->commandId();
}


void JsonRpcClient::processAuthenticate(const QVariantMap &data)
{
    qDebug() << "authenticate response" << data;
    if (data.value("status").toString() == "success" && data.value("params").toMap().value("success").toBool()) {
        m_token = data.value("params").toMap().value("token").toByteArray();
        QSettings settings;
        settings.beginGroup("jsonTokens");
        settings.setValue(m_serverUuid, m_token);
        settings.endGroup();
        emit authenticationRequiredChanged();

        setNotificationsEnabled(true);
    }
}

void JsonRpcClient::processCreateUser(const QVariantMap &data)
{
    qDebug() << "create user response:" << data;
    if (data.value("status").toString() == "success" && data.value("params").toMap().value("error").toString() == "UserErrorNoError") {
        m_initialSetupRequired = false;
        emit initialSetupRequiredChanged();
    }
}

JsonRpcReply *JsonRpcClient::createReply(const QString &method, const QVariantMap &params, QObject* caller, const QString &callback)
{
    QStringList callParts = method.split('.');
    if (callParts.count() != 2) {
        qWarning() << "Invalid method. Must be Namespace.Method";
        return nullptr;
    }
    m_id++;
    return new JsonRpcReply(m_id, callParts.first(), callParts.last(), params, caller, callback);
}

void JsonRpcClient::sendRequest(const QVariantMap &request)
{
    QVariantMap newRequest = request;
    newRequest.insert("token", m_token);
    qDebug() << "Sending request" << QJsonDocument::fromVariant(newRequest).toJson();
    m_connection->sendData(QJsonDocument::fromVariant(newRequest).toJson());
}

void JsonRpcClient::onInterfaceConnectedChanged(bool connected)
{
    if (!connected) {
        m_initialSetupRequired = false;
        m_authenticationRequired = false;
        if (m_connected) {
            m_connected = false;
            emit connectedChanged(false);
        }
    }
}

void JsonRpcClient::dataReceived(const QByteArray &data)
{
    m_receiveBuffer.append(data);

    int splitIndex = m_receiveBuffer.indexOf("}\n{") + 1;
    if (splitIndex <= 0) {
        splitIndex = m_receiveBuffer.length();
    }
    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(m_receiveBuffer.left(splitIndex), &error);
    if (error.error != QJsonParseError::NoError) {
 //       qWarning() << "Could not parse json data from guh" << data << error.errorString();
        return;
    }
//    qDebug() << "received response" << m_receiveBuffer.left(splitIndex);
    m_receiveBuffer = m_receiveBuffer.right(m_receiveBuffer.length() - splitIndex - 1);
    if (!m_receiveBuffer.isEmpty()) {
        staticMetaObject.invokeMethod(this, "dataReceived", Qt::QueuedConnection, Q_ARG(QByteArray, QByteArray()));
    }

    QVariantMap dataMap = jsonDoc.toVariant().toMap();


    // Check if this is the initial handshake
    if (dataMap.value("id").toInt() == 0) {
        m_initialSetupRequired = dataMap.value("initialSetupRequired").toBool();
        m_authenticationRequired = dataMap.value("authenticationRequired").toBool();
        m_serverUuid = dataMap.value("uuid").toString();

        QString protoVersionString = dataMap.value("protocol version").toString();
        if (!protoVersionString.contains('.')) {
            protoVersionString.prepend("0.");
        }

        if (m_initialSetupRequired) {
            emit initialSetupRequiredChanged();
        } else if (m_authenticationRequired) {
            QSettings settings;
            settings.beginGroup("jsonTokens");
            m_token = settings.value(m_serverUuid).toByteArray();
            settings.endGroup();
            emit authenticationRequiredChanged();

            if (!m_token.isEmpty()) {
                setNotificationsEnabled(true);
            }
        }

        m_connected = true;
        emit connectedChanged(true);

        QVersionNumber minimumRequiredVersion = QVersionNumber(1, 0);
        QVersionNumber protocolVersion = QVersionNumber::fromString(protoVersionString);
        if (protocolVersion < minimumRequiredVersion) {
            m_connection->disconnect();
            emit invalidProtocolVersion(protocolVersion.toString(), minimumRequiredVersion.toString());
        }
    }

    // check if this is a reply to a request
    int commandId = dataMap.value("id").toInt();
    JsonRpcReply *reply = m_replies.take(commandId);
    if (reply) {
//        qDebug() << QString("JsonRpc: got response for %1.%2: %3").arg(reply->nameSpace(), reply->method(), QString::fromUtf8(jsonDoc.toJson(QJsonDocument::Indented))) << reply->callback() << reply->callback();

        if (reply->caller() != nullptr && !reply->callback().isEmpty()) {
            QMetaObject::invokeMethod(reply->caller(), reply->callback().toLatin1().data(), Q_ARG(QVariantMap, dataMap));
        }

        emit responseReceived(reply->commandId(), dataMap.value("params").toMap());
        return;
    }

    // check if this is a notification
    if (dataMap.contains("notification")) {
        QStringList notification = dataMap.value("notification").toString().split(".");
        QString nameSpace = notification.first();
        JsonHandler *handler = m_notificationHandlers.value(nameSpace).first;

        if (!handler) {
//            qWarning() << "JsonRpc: handler not implemented:" << nameSpace;
            return;
        }

//        qDebug() << "Incoming notification:" << jsonDoc.toJson();
        QMetaObject::invokeMethod(handler, m_notificationHandlers.value(nameSpace).second.toLatin1().data(), Q_ARG(QVariantMap, dataMap));
    }
}

JsonRpcReply::JsonRpcReply(int commandId, QString nameSpace, QString method, QVariantMap params, QObject *caller, const QString &callback):
    QObject(caller),
    m_commandId(commandId),
    m_nameSpace(nameSpace),
    m_method(method),
    m_params(params),
    m_caller(caller),
    m_callback(callback)
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

QObject* JsonRpcReply::caller() const
{
    return m_caller;
}

QString JsonRpcReply::callback() const
{
    return m_callback;
}
