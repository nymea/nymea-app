/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app.                                      *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "jsonrpcclient.h"
#include "connection/nymeaconnection.h"
#include "types/param.h"
#include "types/params.h"

#include <QJsonDocument>
#include <QVariantMap>
#include <QDebug>
#include <QUuid>
#include <QSettings>
#include <QVersionNumber>
#include <QMetaEnum>
#include <QLocale>

JsonRpcClient::JsonRpcClient(NymeaConnection *connection, QObject *parent) :
    JsonHandler(parent),
    m_id(0),
    m_connection(connection)
{
    connect(m_connection, &NymeaConnection::connectedChanged, this, &JsonRpcClient::onInterfaceConnectedChanged);
    connect(m_connection, &NymeaConnection::dataAvailable, this, &JsonRpcClient::dataReceived);

    registerNotificationHandler(this, "notificationReceived");
}

QString JsonRpcClient::nameSpace() const
{
    return QStringLiteral("JSONRPC");
}

void JsonRpcClient::registerNotificationHandler(JsonHandler *handler, const QString &method)
{
    if (m_notificationHandlerMethods.contains(handler)) {
        qWarning() << "Notification handler" << handler << " already registered";
        return;
    }
    m_notificationHandlers.insert(handler->nameSpace(), handler);
    m_notificationHandlerMethods.insert(handler, method);
    setNotificationsEnabled();
}

void JsonRpcClient::unregisterNotificationHandler(JsonHandler *handler)
{
    m_notificationHandlers.remove(handler->nameSpace(), handler);
    m_notificationHandlerMethods.remove(handler);
    setNotificationsEnabled();
}

int JsonRpcClient::sendCommand(const QString &method, const QVariantMap &params, QObject *caller, const QString &callbackMethod)
{
    JsonRpcReply *reply = createReply(method, params, caller, callbackMethod);
    m_replies.insert(reply->commandId(), reply);
    sendRequest(reply->requestMap());
    return reply->commandId();
}

int JsonRpcClient::sendCommand(const QString &method, QObject *caller, const QString &callbackMethod)
{
    return sendCommand(method, QVariantMap(), caller, callbackMethod);
}

void JsonRpcClient::getCloudConnectionStatus()
{
    JsonRpcReply *reply = createReply("JSONRPC.IsCloudConnected", QVariantMap(), this, "isCloudConnectedReply");
    m_replies.insert(reply->commandId(), reply);
    sendRequest(reply->requestMap());
}

void JsonRpcClient::setNotificationsEnabledResponse(const QVariantMap &params)
{
    qDebug() << "Notifications enabled:" << params;

    if (!m_connected) {
        m_connected = true;
        emit connectedChanged(true);
    }
}

void JsonRpcClient::notificationReceived(const QVariantMap &data)
{
    qDebug() << "Notification received:" << data;
    if (data.value("notification").toString() == "JSONRPC.PushButtonAuthFinished") {
        qDebug() << "Push button auth finished.";
        if (data.value("params").toMap().value("transactionId").toInt() != m_pendingPushButtonTransaction) {
            qDebug() << "This push button transaction is not what we're waiting for...";
            return;
        }
        m_pendingPushButtonTransaction = -1;
        if (data.value("params").toMap().value("success").toBool()) {
            qDebug() << "Push button auth succeeded";
            m_token = data.value("params").toMap().value("token").toByteArray();
            QSettings settings;
            settings.beginGroup("jsonTokens");
            settings.setValue(m_serverUuid, m_token);
            settings.endGroup();
            emit authenticationRequiredChanged();

            setNotificationsEnabled();
        } else {
            emit pushButtonAuthFailed();
        }
        return;
    }

    if (data.value("notification").toString() == "JSONRPC.CloudConnectedChanged") {
        QMetaEnum connectionStateEnum = QMetaEnum::fromType<CloudConnectionState>();
        m_cloudConnectionState = static_cast<CloudConnectionState>(connectionStateEnum.keyToValue(data.value("params").toMap().value("connectionState").toByteArray().data()));
        emit cloudConnectionStateChanged();
        return;
    }

    qDebug() << "JsonRpcClient: Unhandled notification received" << data;
}

void JsonRpcClient::isCloudConnectedReply(const QVariantMap &data)
{
//    qDebug() << "Cloud is connected" << data;
    QMetaEnum connectionStateEnum = QMetaEnum::fromType<CloudConnectionState>();
    m_cloudConnectionState = static_cast<CloudConnectionState>(connectionStateEnum.keyToValue(data.value("params").toMap().value("connectionState").toByteArray().data()));
    emit cloudConnectionStateChanged();
}

void JsonRpcClient::setupRemoteAccessReply(const QVariantMap &data)
{
    qDebug() << "Setup Remote Access reply" << data;
}

void JsonRpcClient::deployCertificateReply(const QVariantMap &data)
{
    qDebug() << "deploy certificate reply:" << data;
}

void JsonRpcClient::getVersionsReply(const QVariantMap &data)
{
    m_serverQtVersion = data.value("params").toMap().value("qtVersion").toString();
    m_serverQtBuildVersion = data.value("params").toMap().value("qtBuildVersion").toString();
    if (!m_serverQtVersion.isEmpty()) {
        emit serverQtVersionChanged();
    }
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

bool JsonRpcClient::pushButtonAuthAvailable() const
{
    return m_pushButtonAuthAvailable;
}

JsonRpcClient::CloudConnectionState JsonRpcClient::cloudConnectionState() const
{
    return m_cloudConnectionState;
}

void JsonRpcClient::deployCertificate(const QByteArray &rootCA, const QByteArray &certificate, const QByteArray &publicKey, const QByteArray &privateKey, const QString &endpoint)
{
    QVariantMap params;
    params.insert("rootCA", rootCA);
    params.insert("certificatePEM", certificate);
    params.insert("publicKey", publicKey);
    params.insert("privateKey", privateKey);
    params.insert("endpoint", endpoint);

    sendCommand("JSONRPC.SetupCloudConnection", params, this, "deployCertificateReply");
}

QString JsonRpcClient::serverVersion() const
{
    return m_serverVersion;
}

QString JsonRpcClient::jsonRpcVersion() const
{
    return m_jsonRpcVersion.toString();
}

QString JsonRpcClient::serverUuid() const
{
    return m_serverUuid;
}

QString JsonRpcClient::serverQtVersion()
{
    if (!m_serverQtVersion.isEmpty()) {
        return m_serverQtVersion;
    }
    if (ensureServerVersion("4.0")) {
        sendCommand("JSONRPC.Version", QVariantMap(), this, "getVersionsReply");
    }
    return QString();
}

QString JsonRpcClient::serverQtBuildVersion()
{
    return m_serverQtBuildVersion;
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
    qDebug() << "Authenticating:" << username << password << deviceName;
    JsonRpcReply* reply = createReply("JSONRPC.Authenticate", params, this, "processAuthenticate");
    m_replies.insert(reply->commandId(), reply);
    m_connection->sendData(QJsonDocument::fromVariant(reply->requestMap()).toJson());
    return reply->commandId();
}

int JsonRpcClient::requestPushButtonAuth(const QString &deviceName)
{
    qDebug() << "Requesting push button auth for device:" << deviceName;
    QVariantMap params;
    params.insert("deviceName", deviceName);
    JsonRpcReply *reply = createReply("JSONRPC.RequestPushButtonAuth", params, this, "processRequestPushButtonAuth");
    m_replies.insert(reply->commandId(), reply);
    m_connection->sendData(QJsonDocument::fromVariant(reply->requestMap()).toJson());
    return reply->commandId();
}

void JsonRpcClient::setupRemoteAccess(const QString &idToken, const QString &userId)
{
    qDebug() << "Calling SetupRemoteAccess";
    QVariantMap params;
    params.insert("idToken", idToken);
    params.insert("userId", userId);
    sendCommand("JSONRPC.SetupRemoteAccess", params, this, "setupRemoteAccessReply");
}

bool JsonRpcClient::ensureServerVersion(const QString &jsonRpcVersion)
{
    return QVersionNumber(m_jsonRpcVersion) >= QVersionNumber::fromString(jsonRpcVersion);
}

void JsonRpcClient::processAuthenticate(const QVariantMap &data)
{
    if (data.value("status").toString() == "success" && data.value("params").toMap().value("success").toBool()) {
        qDebug() << "authentication successful";
        m_token = data.value("params").toMap().value("token").toByteArray();
        QSettings settings;
        settings.beginGroup("jsonTokens");
        settings.setValue(m_serverUuid, m_token);
        settings.endGroup();
        emit authenticationRequiredChanged();

        setNotificationsEnabled();
    } else {
        qWarning() << "Authentication failed" << data;
        emit authenticationFailed();
    }
}

void JsonRpcClient::processCreateUser(const QVariantMap &data)
{
    qDebug() << "create user response:" << data;
    if (data.value("status").toString() == "success" && data.value("params").toMap().value("error").toString() == "UserErrorNoError") {
        emit createUserSucceeded();
        m_initialSetupRequired = false;
        emit initialSetupRequiredChanged();
    } else {
        qDebug() << "Emitting create user failed";
        emit createUserFailed(data.value("params").toMap().value("error").toString());
    }
}

void JsonRpcClient::processRequestPushButtonAuth(const QVariantMap &data)
{
    qDebug() << "requestPushButtonAuth response" << data;
    if (data.value("status").toString() == "success" && data.value("params").toMap().value("success").toBool()) {
        m_pendingPushButtonTransaction = data.value("params").toMap().value("transactionId").toInt();
    } else {
        emit pushButtonAuthFailed();
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

void JsonRpcClient::setNotificationsEnabled()
{
    QStringList namespaces;
    foreach (const QString &nameSpace, m_notificationHandlers.keys()) {
        namespaces.append(nameSpace);
    }

    if (!m_connection->connected()) {
        return;
    }

    QVariantMap params;

    if (ensureServerVersion("3.1")) {
        params.insert("namespaces", namespaces);
    } else {
        params.insert("enabled", namespaces.count() > 0);
    }
    JsonRpcReply *reply = createReply("JSONRPC.SetNotificationStatus", params, this, "setNotificationsEnabledResponse");
    m_replies.insert(reply->commandId(), reply);
    sendRequest(reply->requestMap());
}

void JsonRpcClient::sendRequest(const QVariantMap &request)
{
    QVariantMap newRequest = request;
    newRequest.insert("token", m_token);
//    qDebug() << "Sending request" << qUtf8Printable(QJsonDocument::fromVariant(newRequest).toJson());
    m_connection->sendData(QJsonDocument::fromVariant(newRequest).toJson(QJsonDocument::Compact) + "\n");
}

void JsonRpcClient::onInterfaceConnectedChanged(bool connected)
{

    if (!connected) {
        qDebug() << "JsonRpcClient: Transport disconnected.";
        m_initialSetupRequired = false;
        m_authenticationRequired = false;
        m_serverQtVersion.clear();
        m_serverQtBuildVersion.clear();
        if (m_connected) {
            m_connected = false;
            emit connectedChanged(false);
        }
    } else {
        qDebug() << "JsonRpcClient: Transport connected. Starting handshake.";
        // Clear anything that might be left in the buffer from a previous connection.
        m_receiveBuffer.clear();
        QVariantMap params;
        params.insert("locale", QLocale().name());
        sendCommand("JSONRPC.Hello", params, this, "helloReply");
    }
}

void JsonRpcClient::dataReceived(const QByteArray &data)
{
//    qDebug() << "JsonRpcClient: received data:" << qUtf8Printable(data);
    m_receiveBuffer.append(data);

    int splitIndex = m_receiveBuffer.indexOf("}\n{") + 1;
    if (splitIndex <= 0) {
        splitIndex = m_receiveBuffer.length();
    }
    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(m_receiveBuffer.left(splitIndex), &error);
    if (error.error != QJsonParseError::NoError) {
//        qWarning() << "Could not parse json data from nymea" << m_receiveBuffer.left(splitIndex) << error.errorString();
        return;
    }
//    qDebug() << "received response" << qUtf8Printable(jsonDoc.toJson(QJsonDocument::Indented));
    m_receiveBuffer = m_receiveBuffer.right(m_receiveBuffer.length() - splitIndex - 1);
    if (!m_receiveBuffer.isEmpty()) {
        staticMetaObject.invokeMethod(this, "dataReceived", Qt::QueuedConnection, Q_ARG(QByteArray, QByteArray()));
    }

    QVariantMap dataMap = jsonDoc.toVariant().toMap();

    // check if this is a notification
    if (dataMap.contains("notification")) {
//        qDebug() << "Incoming notification:" << jsonDoc.toJson();
        QStringList notification = dataMap.value("notification").toString().split(".");
        QString nameSpace = notification.first();
        foreach (JsonHandler *handler, m_notificationHandlers.values(nameSpace)) {
            QMetaObject::invokeMethod(handler, m_notificationHandlerMethods.value(handler).toLatin1().data(), Q_ARG(QVariantMap, dataMap));
        }
        return;
    }

    // check if this is a reply to a request
    int commandId = dataMap.value("id").toInt();
    JsonRpcReply *reply = m_replies.take(commandId);
    if (reply) {
        reply->deleteLater();
//        qDebug() << QString("JsonRpc: got response for %1.%2: %3").arg(reply->nameSpace(), reply->method(), QString::fromUtf8(jsonDoc.toJson(QJsonDocument::Indented))) << reply->callback() << reply->callback();

        if (dataMap.value("status").toString() == "unauthorized") {
            qWarning() << "Something's off with the token";
            m_authenticationRequired = true;
            m_token.clear();
            QSettings settings;
            settings.beginGroup("jsonTokens");
            settings.setValue(m_serverUuid, m_token);
            settings.endGroup();
            emit authenticationRequiredChanged();
        }

        if (!reply->caller().isNull() && !reply->callback().isEmpty()) {
            QMetaObject::invokeMethod(reply->caller(), reply->callback().toLatin1().data(), Q_ARG(QVariantMap, dataMap));
        }

        emit responseReceived(reply->commandId(), dataMap.value("params").toMap());
        return;
    }
}

void JsonRpcClient::helloReply(const QVariantMap &params)
{
    if (params.value("status").toString() == "error") {
        qWarning() << "Hello call failed. Trying again without locale";
        m_id = 0;
        sendCommand("JSONRPC.Hello", QVariantMap(), this, "helloReply");
    } else {
        QVariantMap dataMap = params.value("params").toMap();
        m_initialSetupRequired = dataMap.value("initialSetupRequired").toBool();
        m_authenticationRequired = dataMap.value("authenticationRequired").toBool();
        m_pushButtonAuthAvailable = dataMap.value("pushButtonAuthAvailable").toBool();
        emit pushButtonAuthAvailableChanged();

        m_serverUuid = dataMap.value("uuid").toString();
        m_serverVersion = dataMap.value("version").toString();

        QString protoVersionString = dataMap.value("protocol version").toString();
        if (!protoVersionString.contains('.')) {
            protoVersionString.prepend("0.");
        }

        m_jsonRpcVersion = QVersionNumber::fromString(protoVersionString);

        qDebug() << "Handshake reply:" << "Protocol version:" << protoVersionString << "InitRequired:" << m_initialSetupRequired << "AuthRequired:" << m_authenticationRequired << "PushButtonAvailable:" << m_pushButtonAuthAvailable;;

        QVersionNumber minimumRequiredVersion = QVersionNumber(1, 0);
        if (m_jsonRpcVersion < minimumRequiredVersion) {
            qWarning() << "Nymea core doesn't support minimum required version. Required:" << minimumRequiredVersion << "Found:" << m_jsonRpcVersion;
            m_connection->disconnect();
            emit invalidProtocolVersion(m_jsonRpcVersion.toString(), minimumRequiredVersion.toString());
            return;
        }

        emit handshakeReceived();

        if (m_connection->currentHost()->uuid().isNull()) {
            qDebug() << "Updating Server UUID in connection:" << m_connection->currentHost()->uuid().toString() << "->" << m_serverUuid;
            m_connection->currentHost()->setUuid(m_serverUuid);
        }

        if (m_initialSetupRequired) {
            emit initialSetupRequiredChanged();
            return;
        }

        if (m_authenticationRequired) {
            QSettings settings;
            settings.beginGroup("jsonTokens");
            m_token = settings.value(m_serverUuid).toByteArray();
            settings.endGroup();
            emit authenticationRequiredChanged();

            if (m_token.isEmpty()) {
                return;
            }
        }

        setNotificationsEnabled();
        getCloudConnectionStatus();

    }
}

JsonRpcReply::JsonRpcReply(int commandId, QString nameSpace, QString method, QVariantMap params, QPointer<QObject> caller, const QString &callback):
    m_commandId(commandId),
    m_nameSpace(nameSpace),
    m_method(method),
    m_params(params),
    m_caller(caller),
    m_callback(callback)
{
}

JsonRpcReply::~JsonRpcReply()
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

QPointer<QObject> JsonRpcReply::caller() const
{
    return m_caller;
}

QString JsonRpcReply::callback() const
{
    return m_callback;
}
