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

#ifndef NYMEACONNECTION_H
#define NYMEACONNECTION_H

#include <QObject>
#include <QHash>
#include <QSslError>
#include <QAbstractSocket>
#include <QUrl>
//#include <QNetworkConfigurationManager>
#include <QTimer>

#include "nymeahost.h"

class NymeaTransportInterface;
class NymeaTransportInterfaceFactory;
class NetworkReachabilityMonitor;

class NymeaConnection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(NymeaHost *currentHost READ currentHost WRITE setCurrentHost NOTIFY currentHostChanged)
    Q_PROPERTY(Connection *currentConnection  READ currentConnection NOTIFY currentConnectionChanged)
    Q_PROPERTY(NymeaConnection::BearerTypes availableBearerTypes READ availableBearerTypes NOTIFY availableBearerTypesChanged)
    Q_PROPERTY(ConnectionStatus connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)

public:
    enum BearerType {
        BearerTypeNone = 0x0,
        BearerTypeEthernet = 0x1,
        BearerTypeWiFi = 0x2,
        BearerTypeMobileData = 0x4,
        BearerTypeBluetooth = 0x8,
        BearerTypeAll = 0xF
    };
    Q_ENUM(BearerType)
    Q_DECLARE_FLAGS(BearerTypes, BearerType)
    Q_FLAG(BearerTypes)

    enum ConnectionStatus {
        ConnectionStatusUnconnected,
        ConnectionStatusConnecting,
        ConnectionStatusNoBearerAvailable,
        ConnectionStatusBearerFailed,
        ConnectionStatusHostNotFound,
        ConnectionStatusConnectionRefused,
        ConnectionStatusRemoteHostClosed,
        ConnectionStatusTimeout,
        ConnectionStatusSslError,
        ConnectionStatusSslUntrusted,
        ConnectionStatusUnknownError,
        ConnectionStatusConnected
    };
    Q_ENUM(ConnectionStatus)
    explicit NymeaConnection(QObject *parent = nullptr);
    ~NymeaConnection();

    void registerTransport(NymeaTransportInterfaceFactory *transportFactory);

    Q_INVOKABLE void connectToHost(NymeaHost* nymeaHost, Connection *connection = nullptr);
    Q_INVOKABLE void disconnectFromHost();

    bool isEncrypted() const;
    QSslCertificate sslCertificate() const;

    NymeaConnection::BearerTypes availableBearerTypes() const;

    bool connected();
    ConnectionStatus connectionStatus() const;

    NymeaHost *currentHost() const;
    void setCurrentHost(NymeaHost *host);

    Connection *currentConnection() const;

    void sendData(const QByteArray &data);

signals:
    void availableBearerTypesChanged();
    void verifyConnectionCertificate(const QString &url, const QStringList &issuerInfo, const QByteArray &fingerprint, const QByteArray &pem);
    void currentHostChanged();
    void connectedChanged(bool connected);
    void connectionStatusChanged();
    void currentConnectionChanged();
    void dataAvailable(const QByteArray &data);

private slots:
    void onSslErrors(const QList<QSslError> &errors);
    void onError(QAbstractSocket::SocketError error);
    void onConnected();
    void onDisconnected();
    void onDataAvailable(const QByteArray &data);

    void onAvailableBearerTypesUpdated();
    void hostConnectionsUpdated();
private:
    void connectInternal(NymeaHost *host);
    bool connectInternal(Connection *connection);

    bool isConnectionBearerAvailable(Connection::BearerType connectionBearerType) const;

private:
    ConnectionStatus m_connectionStatus = ConnectionStatusUnconnected;
//    QNetworkConfigurationManager *m_networkConfigManager = nullptr;
    NymeaConnection::BearerTypes m_availableBearerTypes = BearerTypeNone;

    QHash<QString, NymeaTransportInterfaceFactory *> m_transportFactories;
    QHash<NymeaTransportInterface *, Connection *> m_transportCandidates;
    NymeaTransportInterface *m_currentTransport = nullptr;
    NymeaHost *m_currentHost = nullptr;
    Connection *m_preferredConnection = nullptr;

    QTimer m_reconnectTimer;

#ifdef Q_OS_IOS
    NymeaConnection::BearerType m_usedBearerType;
#endif
};

#endif // NYMEACONNECTION_H
