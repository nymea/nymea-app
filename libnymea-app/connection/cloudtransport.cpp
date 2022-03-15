/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
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

#include "cloudtransport.h"

#include "awsclient.h"
#include "remoteproxyconnection.h"

#include <QUrlQuery>
#include <QHostInfo>
#include <QPointer>
#include <QCoreApplication>

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcCloud)

using namespace remoteproxyclient;

CloudTransport::CloudTransport(AWSClient *awsClient, QObject *parent):
    NymeaTransportInterface(parent),
    m_awsClient(awsClient)
{
    m_remoteproxyConnection = new RemoteProxyConnection(QUuid::createUuid(), qApp->applicationName(), this);

    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::remoteConnectionEstablished, this,[this]() {
        qCDebug(dcCloud) << "CloudTransport: Remote connection established.";
        emit connected();
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::disconnected, this,[this]() {
        qCDebug(dcCloud) << "CloudTransport: Disconnected.";
        emit disconnected();
    });

    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::stateChanged, this,[](RemoteProxyConnection::State state) {
        qCDebug(dcCloud) << "Proxy state changed:" << state;
    });

    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::ready, this,[this]() {
        qCDebug(dcCloud) << "Proxy ready. Authenticating channel.";
        m_remoteproxyConnection->authenticate(m_awsClient->idToken(), m_nonce);
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::dataReady, this, [this](const QByteArray &data) {
        emit dataReady(data);
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::errorOccurred, this, [] (QAbstractSocket::SocketError error) {
        qCDebug(dcCloud) << "Remote proxy Error:" << error;
//        emit NymeaTransportInterface::error(QAbstractSocket::ConnectionRefusedError);
    });
    QObject::connect(m_remoteproxyConnection, &RemoteProxyConnection::sslErrors, this, &CloudTransport::sslErrors);
}

bool CloudTransport::connect(const QUrl &url)
{
    if (!m_awsClient->isLoggedIn()) {
        qWarning() << "Not logged in to AWS, cannot connect";
        return false;
    }

    qCDebug(dcCloud) << "Connecting to" << url;
    m_url = url;

    m_nonce = QUuid::createUuid().toString();
    bool postResult = m_awsClient->postToMQTT(url.host(), m_nonce, QPointer<QObject>(this), [this](bool success) {
        if (success) {
            qCDebug(dcCloud) << "MQTT Post done. Connecting to remote proxy";
            m_remoteproxyConnection->connectServer(QUrl("wss://remoteproxy.nymea.io"));
        } else {
            qCDebug(dcCloud) << "Posting to MQTT failed";
            emit error(QAbstractSocket::HostNotFoundError);
        }
    });

    if (!postResult) {
        qWarning() << "Failed to post to MQTT. Cannot continue";
        return false;
    }

    return true;
}

QUrl CloudTransport::url() const
{
    return m_url;
}

void CloudTransport::disconnect()
{
    qCDebug(dcCloud) << "CloudTransport: Disconnecting from server.";
    m_remoteproxyConnection->disconnectServer();
}

NymeaTransportInterface::ConnectionState CloudTransport::connectionState() const
{
    switch (m_remoteproxyConnection->state()) {
    case RemoteProxyConnection::StateRemoteConnected:
        return NymeaTransportInterface::ConnectionStateConnected;
    case RemoteProxyConnection::StateInitializing:
    case RemoteProxyConnection::StateHostLookup:
    case RemoteProxyConnection::StateConnecting:
    case RemoteProxyConnection::StateConnected:
    case RemoteProxyConnection::StateAuthenticating:
    case RemoteProxyConnection::StateReady:
    case RemoteProxyConnection::StateAuthenticated:
        return NymeaTransportInterface::ConnectionStateConnecting;
    case RemoteProxyConnection::StateDisconnected:
    case RemoteProxyConnection::StateDiconnecting:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }
    return ConnectionStateDisconnected;
}

void CloudTransport::sendData(const QByteArray &data)
{
//    qCDebug(dcCloud) << "Cloud transport: Sending data:" << data;
    m_remoteproxyConnection->sendData(data);
}

void CloudTransport::ignoreSslErrors(const QList<QSslError> &errors)
{
    qCDebug(dcCloud) << "CloudTransport: Ignoring SSL errors" << errors;
    m_remoteproxyConnection->ignoreSslErrors(errors);
}

CloudTransportFactory::CloudTransportFactory()
{

}

NymeaTransportInterface *CloudTransportFactory::createTransport(QObject *parent) const
{    
    return new CloudTransport(AWSClient::instance(), parent);
}

QStringList CloudTransportFactory::supportedSchemes() const
{
    return {"cloud"};
}

