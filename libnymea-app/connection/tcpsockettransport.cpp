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

#include "tcpsockettransport.h"

#include <QUrl>
#include <QSslConfiguration>

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcTcpTransport, "TcpTransport")

TcpSocketTransport::TcpSocketTransport(QObject *parent) : NymeaTransportInterface(parent)
{
    QObject::connect(&m_socket, &QSslSocket::connected, this, &TcpSocketTransport::onConnected);
    QObject::connect(&m_socket, &QSslSocket::encrypted, this, &TcpSocketTransport::onEncrypted);
    typedef void (QSslSocket:: *sslErrorsSignal)(const QList<QSslError> &);
    QObject::connect(&m_socket, static_cast<sslErrorsSignal>(&QSslSocket::sslErrors), this, &TcpSocketTransport::sslErrors);
    QObject::connect(&m_socket, &QSslSocket::readyRead, this, &TcpSocketTransport::socketReadyRead);
    typedef void (QSslSocket:: *errorSignal)(QAbstractSocket::SocketError);
    QObject::connect(&m_socket, static_cast<errorSignal>(&QSslSocket::error), this, &TcpSocketTransport::error);
    QObject::connect(&m_socket, &QSslSocket::stateChanged, this, &TcpSocketTransport::onSocketStateChanged);

}

void TcpSocketTransport::sendData(const QByteArray &data)
{
    qint64 ret = m_socket.write(data);
    if (ret != data.length()) {
        qWarning() << "Error writing data to socket.";
    }
}

void TcpSocketTransport::ignoreSslErrors(const QList<QSslError> &errors)
{
    m_socket.ignoreSslErrors(errors);
}

bool TcpSocketTransport::isEncrypted() const
{
    return m_socket.isEncrypted();
}

QSslCertificate TcpSocketTransport::serverCertificate() const
{
    return m_socket.peerCertificate();
}

void TcpSocketTransport::onConnected()
{
    if (m_url.scheme() == "nymea") {
        qCDebug(dcTcpTransport()) << "TCP socket connected";
        emit connected();
    }
}

void TcpSocketTransport::onEncrypted()
{
    qDebug() << "TCP socket encrypted";
    emit connected();
}

bool TcpSocketTransport::connect(const QUrl &url)
{
    m_url = url;
    if (url.scheme() == "nymeas") {
        qCDebug(dcTcpTransport()) << "TCP socket connecting to" << url.host() << url.port();
        m_socket.connectToHostEncrypted(url.host(), static_cast<quint16>(url.port()));
        return true;
    } else if (url.scheme() == "nymea") {
        m_socket.connectToHost(url.host(), static_cast<quint16>(url.port()));
        return true;
    }
    qCWarning(dcTcpTransport()) << "TCP socket: Unsupported scheme";
    return false;
}

QUrl TcpSocketTransport::url() const
{
    return m_url;
}

NymeaTransportInterface::ConnectionState TcpSocketTransport::connectionState() const
{
    switch (m_socket.state()) {
    case QAbstractSocket::ConnectedState:
        return NymeaTransportInterface::ConnectionStateConnected;
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::HostLookupState:
        return NymeaTransportInterface::ConnectionStateConnecting;
    default:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }
}

void TcpSocketTransport::disconnect()
{
    qCDebug(dcTcpTransport()) << "closing socket";
    m_socket.disconnectFromHost();
    m_socket.close();
    // QTcpSocket might endlessly wait for a timeout if we call connectToHost() for an IP which isn't
    // reable at all (e.g. has disappeared from the network). Closing the socket is not enough, we need
    // abort the exiting connection attempts too.
    m_socket.abort();
}

void TcpSocketTransport::socketReadyRead()
{
    QByteArray data = m_socket.readAll();
    emit dataReady(data);
}

void TcpSocketTransport::onSocketStateChanged(const QAbstractSocket::SocketState &state)
{
    qCDebug(dcTcpTransport()) << "Socket state changed -->" << state;
    if (state == QAbstractSocket::UnconnectedState) {
        emit disconnected();
    }
}

NymeaTransportInterface *TcpSocketTransportFactory::createTransport(QObject *parent) const
{
    return new TcpSocketTransport(parent);
}

QStringList TcpSocketTransportFactory::supportedSchemes() const
{
    return {"nymea", "nymeas"};
}
