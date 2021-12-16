/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "tunnelproxytransport.h"

#include <QCoreApplication>

using namespace remoteproxyclient;

TunnelProxyTransport::TunnelProxyTransport(QObject *parent) :
    NymeaTransportInterface(parent)
{
    m_remoteConnection = new TunnelProxyRemoteConnection(QUuid::createUuid(), qApp->applicationName(), this);
    QObject::connect(m_remoteConnection, &TunnelProxyRemoteConnection::stateChanged, this, &TunnelProxyTransport::onRemoteConnectionStateChanged);
    QObject::connect(m_remoteConnection, &TunnelProxyRemoteConnection::remoteConnectedChanged, this, &TunnelProxyTransport::onRemoteConnectedChanged);
    QObject::connect(m_remoteConnection, &TunnelProxyRemoteConnection::dataReady, this, &TunnelProxyTransport::dataReady);
    QObject::connect(m_remoteConnection, &TunnelProxyRemoteConnection::errorOccurred, this, &TunnelProxyTransport::onRemoteConnectionErrorOccurred);
    QObject::connect(m_remoteConnection, &TunnelProxyRemoteConnection::sslErrors, this, [=](const QList<QSslError> &errors){
        qWarning() << "Remote tunnel proxy server SSL errors occurred:";
        foreach (const QSslError &sslError, errors) {
            qWarning() << "  --> " << sslError.errorString();
        }
    });

}

bool TunnelProxyTransport::connect(const QUrl &url)
{

    m_url = url;

    // FIXME: get nymea uuid from URL somehow...

    //QUrl("ssl://dev-remoteproxy.nymea.io:2213");

    //m_remoteConnection->connectServer()

    return false;
}

QUrl TunnelProxyTransport::url() const
{
    return m_url;
}

NymeaTransportInterface::ConnectionState TunnelProxyTransport::connectionState() const
{
    switch (m_remoteConnection->state()) {
    case TunnelProxyRemoteConnection::StateRemoteConnected:
        return NymeaTransportInterface::ConnectionStateConnected;
    case TunnelProxyRemoteConnection::StateConnecting:
    case TunnelProxyRemoteConnection::StateHostLookup:
    case TunnelProxyRemoteConnection::StateConnected:
    case TunnelProxyRemoteConnection::StateInitializing:
    case TunnelProxyRemoteConnection::StateRegister:
        return NymeaTransportInterface::ConnectionStateConnecting;
    case TunnelProxyRemoteConnection::StateDiconnecting:
    case TunnelProxyRemoteConnection::StateDisconnected:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }
}

void TunnelProxyTransport::disconnect()
{
    m_remoteConnection->disconnectServer();
}

void TunnelProxyTransport::sendData(const QByteArray &data)
{
    m_remoteConnection->sendData(data);
}

void TunnelProxyTransport::ignoreSslErrors(const QList<QSslError> &errors)
{
    // FIXME: once the tunnel connection implements SSL connection trought the tunnel proxy, we need to implement this
    Q_UNUSED(errors)
}

bool TunnelProxyTransport::isEncrypted() const
{
    return false;
}

QSslCertificate TunnelProxyTransport::serverCertificate() const
{
    // FIXME: once the tunnel connection implements SSL connection trought the tunnel proxy, we need to implement this
    return QSslCertificate();
}

void TunnelProxyTransport::onRemoteConnectionStateChanged(remoteproxyclient::TunnelProxyRemoteConnection::State state)
{
    qCritical() << "FIXME TODO! remoteConnectionStateChanged";
}

void TunnelProxyTransport::onRemoteConnectedChanged(bool remoteConnected)
{
    qDebug() << "Tunnel proxy remote connection" << (remoteConnected ? "connected" : "disconnected");
}

void TunnelProxyTransport::onRemoteConnectionErrorOccurred(QAbstractSocket::SocketError error)
{
    qWarning() << "Tunnel proxy socket error occurred" << error;
}

NymeaTransportInterface *TunnelProxyTransportFactory::createTransport(QObject *parent) const
{
    return new TunnelProxyTransport(parent);
}

QStringList TunnelProxyTransportFactory::supportedSchemes() const
{
    return { "tunnel" };
}
