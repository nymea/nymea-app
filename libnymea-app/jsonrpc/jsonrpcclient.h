// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NYMEAJSONRPCCLIENT_H
#define NYMEAJSONRPCCLIENT_H

#include <QObject>
#include <QPointer>
#include <QVariantMap>
#include <QVersionNumber>

#include "connection/nymeaconnection.h"
#include "types/userinfo.h"

class JsonRpcReply;
class Param;
class Params;

class JsonRpcClient : public QObject
{
    Q_OBJECT
public:
    // Bounded failure reason for AuthenticateWithToken, shared with the redemption
    // controller in work package 02 task 4. "Cancelled" is never emitted by this class -
    // it is reserved for the controller's own user-initiated abort path.
    enum class AuthenticateWithTokenReason {
        NoError,
        Unsupported,
        InvalidOrExpired,
        Transport,
        Cancelled,
        Protocol
    };
    Q_ENUM(AuthenticateWithTokenReason)
private:
    Q_PROPERTY(NymeaConnection::BearerTypes availableBearerTypes READ availableBearerTypes NOTIFY availableBearerTypesChanged)
    Q_PROPERTY(NymeaConnection::ConnectionStatus connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(NymeaHost *currentHost READ currentHost NOTIFY currentHostChanged)
    Q_PROPERTY(Connection *currentConnection READ currentConnection NOTIFY currentConnectionChanged)
    Q_PROPERTY(bool initialSetupRequired READ initialSetupRequired NOTIFY initialSetupRequiredChanged)
    Q_PROPERTY(bool authenticationRequired READ authenticationRequired NOTIFY authenticationRequiredChanged)
    Q_PROPERTY(bool pushButtonAuthAvailable READ pushButtonAuthAvailable NOTIFY pushButtonAuthAvailableChanged)
    Q_PROPERTY(bool authenticated READ authenticated NOTIFY authenticatedChanged)
    Q_PROPERTY(bool invitationApiAvailable READ invitationApiAvailable NOTIFY invitationApiAvailableChanged)
    Q_PROPERTY(QString serverVersion READ serverVersion NOTIFY handshakeReceived)
    Q_PROPERTY(QString jsonRpcVersion READ jsonRpcVersion NOTIFY handshakeReceived)
    Q_PROPERTY(QUuid serverUuid READ serverUuid NOTIFY handshakeReceived)
    Q_PROPERTY(QString serverName READ serverName NOTIFY serverNameChanged)
    Q_PROPERTY(QString serverQtVersion READ serverQtVersion NOTIFY serverQtVersionChanged)
    Q_PROPERTY(QString serverQtBuildVersion READ serverQtBuildVersion NOTIFY serverQtVersionChanged)
    Q_PROPERTY(QVariantMap certificateIssuerInfo READ certificateIssuerInfo NOTIFY currentConnectionChanged)
    Q_PROPERTY(QVariantMap experiences READ experiences NOTIFY currentConnectionChanged)
    Q_PROPERTY(UserInfo::PermissionScopes permissions READ permissions NOTIFY permissionsChanged)

public:
    explicit JsonRpcClient(QObject *parent = nullptr);

    void registerNotificationHandler(QObject *handler, const QString &nameSpace, const QString &method);
    void unregisterNotificationHandler(QObject *handler);

    int sendCommand(const QString &method, const QVariantMap &params, QObject *caller = nullptr, const QString &callbackMethod = QString());
    int sendCommand(const QString &method, QObject *caller = nullptr, const QString &callbackMethod = QString());

    NymeaConnection::BearerTypes availableBearerTypes() const;
    NymeaConnection::ConnectionStatus connectionStatus() const;
    bool connected() const;
    NymeaHost *currentHost() const;
    Connection *currentConnection() const;
    QVariantMap certificateIssuerInfo() const;
    bool initialSetupRequired() const;
    bool authenticationRequired() const;
    bool pushButtonAuthAvailable() const;
    bool authenticated() const;
    // True only for protocol >= 10.3 (within the supported major range already enforced
    // by invalidMaximumVersion) and an explicitly Boolean Hello.invitationsAvailable ==
    // true. Missing/malformed/false fails closed. Distinct from and stricter than
    // 00-token-lifecycle.md's last-seen/expiry display, which needs no such gate.
    bool invitationApiAvailable() const;
    QHash<QString, QString> cacheHashes() const;
    // Note: This does not reflect the actual permission scopes of the user but is translated to effective permissions
    // That, is, if the user has the admin permission, all of the other scopes will be set too even if they might not be explicitly set
    UserInfo::PermissionScopes permissions() const;

    QString serverVersion() const;
    QString jsonRpcVersion() const;
    QUuid serverUuid() const;
    QString serverName() const;
    QString serverQtVersion();
    QString serverQtBuildVersion();
    QVariantMap experiences() const;

    // ui methods
    Q_INVOKABLE void connectToHost(NymeaHost *host, Connection *connection = nullptr);
    Q_INVOKABLE void disconnectFromHost();
    Q_INVOKABLE void acceptCertificate(const QUuid &serverUuid, const QByteArray &pem);
    Q_INVOKABLE bool tokenExists(const QString &serverUuid) const;
    Q_INVOKABLE void addToken(const QString &serverUuid, const QByteArray &token);

    Q_INVOKABLE bool ensureServerVersion(const QString &jsonRpcVersion);

    Q_INVOKABLE int createUser(const QString &username, const QString &password, const QString &displayName, const QString &email);
    Q_INVOKABLE int authenticate(const QString &username, const QString &password, const QString &deviceName);
    Q_INVOKABLE int requestPushButtonAuth(const QString &deviceName);

    // Redeems a one-time invitation token for a regular client token. Refuses locally
    // (no request sent, no secret transmitted) and returns -1 if invitationApiAvailable
    // is false or the sanitized device name fails local validation. Result arrives via
    // authenticateWithTokenFinished, never via authenticatedChanged/authenticationFailed,
    // so a stale reply can never be mistaken for completing a newer invitation.
    Q_INVOKABLE int authenticateWithToken(const QByteArray &oneTimeToken, const QString &deviceName);

    // Shared by authenticate(), requestPushButtonAuth() and authenticateWithToken(): strips
    // NUL and Unicode control/format characters, trims whitespace, and truncates only at a
    // UTF-8 code-point boundary to at most 40 bytes. Falls back to "nymea-app" if the result
    // is empty. Exposed statically so it stays independently unit-testable.
    static QString sanitizeDeviceName(const QString &label);

    // True for JSON-RPC methods whose reply carries a bearer secret (a regular client
    // token or a one-time invitation token): Authenticate, AuthenticateWithToken,
    // RequestPushButtonAuth, and Users.CreateInvitation. Consulted before ever writing a
    // reply to the plaintext disk cache, independent of whatever cache hash the server
    // advertises for it. Public and static so it stays independently unit-testable.
    static bool isSecretBearingMethod(const QString &fullMethod);

    // Returns a copy of data with a top-level "token" and/or "params.token" value masked.
    // Covers every shape logged here: outgoing requests (top-level token = the bearer
    // sent with the request; params.token = a method-specific secret such as the one-time
    // invitation token on AuthenticateWithToken), replies and notifications (params.token
    // = a returned regular or one-time token). Safe to call even when neither key exists.
    static QVariantMap redactSensitiveFields(const QVariantMap &data);
    // Convenience wrapper returning ready-to-print redacted JSON for the qCDebug/qCWarning
    // call sites that log a full payload.
    static QByteArray redactedJson(const QVariantMap &data);

signals:
    void availableBearerTypesChanged();
    void connectionStatusChanged();
    void connectedChanged(bool connected);
    void currentHostChanged();
    void currentConnectionChanged();
    void handshakeReceived();
    void newSslCertificate();
    void verifyConnectionCertificate(const QString &serverUuid, const QVariantMap &issuerInfo, const QByteArray &pem);
    void initialSetupRequiredChanged();
    void authenticationRequiredChanged();
    void pushButtonAuthAvailableChanged();
    void authenticatedChanged();
    void invitationApiAvailableChanged();
    void tokenChanged();
    void invalidMinimumVersion(const QString &actualVersion, const QString &minVersion);
    void invalidMaximumVersion(const QString &actualVersion, const QString &maxVersion);
    void invalidServerUuid(const QUuid &uuid);
    void authenticationFailed();
    void pushButtonAuthFailed();
    void createUserSucceeded();
    void createUserFailed(const QString &error);
    void serverQtVersionChanged();
    void serverNameChanged();
    void permissionsChanged();

    // Command-correlated so a stale reply can never complete a newer invitation. reason
    // is AuthenticateWithTokenReason::NoError on success.
    void authenticateWithTokenFinished(int commandId, bool success, JsonRpcClient::AuthenticateWithTokenReason reason);

    void responseReceived(const int &commandId, const QVariantMap &response);

private slots:
    void onInterfaceConnectedChanged(bool connected);
    void dataReceived(const QByteArray &data);

    void helloReply(int commandId, const QVariantMap &params);

private:
    int m_id;
    // < namespace, method> >
    QHash<QObject *, QString> m_notificationHandlerMethods;
    QMultiHash<QString, QObject *> m_notificationHandlers;
    QHash<int, JsonRpcReply *> m_replies;
    NymeaConnection *m_connection = nullptr;

    JsonRpcReply *createReply(const QString &method, const QVariantMap &params, QObject *caller, const QString &callback);

    bool m_connected = false;
    bool m_initialSetupRequired = false;
    bool m_authenticationRequired = false;
    bool m_pushButtonAuthAvailable = false;
    bool m_authenticated = false;
    bool m_invitationApiAvailable = false;
    int m_pendingPushButtonTransaction = -1;
    QUuid m_serverUuid;
    QVersionNumber m_jsonRpcVersion;
    QString m_serverVersion;
    QString m_serverQtVersion;
    QString m_serverQtBuildVersion;
    QByteArray m_token;
    QByteArray m_receiveBuffer;
    QHash<QString, QString> m_cacheHashes;
    QVariantMap m_experiences;
    UserInfo::PermissionScopes m_permissionScopes = UserInfo::PermissionScopeNone;
    QString m_username;

    void setNotificationsEnabled();

    // json handler
    Q_INVOKABLE void processAuthenticate(int commandId, const QVariantMap &data);
    Q_INVOKABLE void processAuthenticateWithToken(int commandId, const QVariantMap &data);
    Q_INVOKABLE void processCreateUser(int commandId, const QVariantMap &data);
    Q_INVOKABLE void processRequestPushButtonAuth(int commandId, const QVariantMap &data);

    Q_INVOKABLE void setNotificationsEnabledResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);
    Q_INVOKABLE void getVersionsReply(int commandId, const QVariantMap &data);

    void sendRequest(const QVariantMap &request);

    bool loadPem(const QUuid &serverUud, QByteArray &pem);
    bool storePem(const QUuid &serverUuid, const QByteArray &pem);
};

class JsonRpcReply : public QObject
{
    Q_OBJECT
public:
    explicit JsonRpcReply(
        int commandId, QString nameSpace, QString method, QVariantMap params = QVariantMap(), QPointer<QObject> caller = QPointer<QObject>(), const QString &callback = QString());
    ~JsonRpcReply();

    int commandId() const;
    QString nameSpace() const;
    QString method() const;
    QVariantMap params() const;
    QVariantMap requestMap();

    QPointer<QObject> caller() const;
    QString callback() const;

private:
    int m_commandId;
    QString m_nameSpace;
    QString m_method;
    QVariantMap m_params;

    QPointer<QObject> m_caller;
    QString m_callback;
};

#endif // NYMEAJSONRPCCLIENT_H
