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

#include "websockettransport.h"

#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QSettings>

WebsocketTransport::WebsocketTransport(QObject *parent) :
    NymeaTransportInterface(parent)
{
    m_socket = new QWebSocket(QCoreApplication::applicationName(), QWebSocketProtocol::VersionLatest, this);

    QObject::connect(m_socket, &QWebSocket::connected, this, &WebsocketTransport::connected);
    QObject::connect(m_socket, &QWebSocket::disconnected, this, &WebsocketTransport::disconnected);
    typedef void (QWebSocket:: *errorSignal)(QAbstractSocket::SocketError);
    QObject::connect(m_socket, static_cast<errorSignal>(&QWebSocket::error), this, &WebsocketTransport::error);
    QObject::connect(m_socket, &QWebSocket::textMessageReceived, this, &WebsocketTransport::onTextMessageReceived);

#ifndef QT_NO_SSL
    typedef void (QWebSocket:: *sslErrorsSignal)(const QList<QSslError> &);
    QObject::connect(m_socket, static_cast<sslErrorsSignal>(&QWebSocket::sslErrors),this, &WebsocketTransport::sslErrors);
#endif
}

bool WebsocketTransport::connect(const QUrl &url)
{
    m_url = url;
    m_socket->open(QUrl(url));
    return true;
}

QUrl WebsocketTransport::url() const
{
    return m_url;
}

NymeaTransportInterface::ConnectionState WebsocketTransport::connectionState() const
{
    switch (m_socket->state()) {
    case QAbstractSocket::ConnectedState:
        return NymeaTransportInterface::ConnectionStateConnected;
    case QAbstractSocket::ConnectingState:
    case QAbstractSocket::HostLookupState:
        return NymeaTransportInterface::ConnectionStateConnecting;
    default:
        return NymeaTransportInterface::ConnectionStateDisconnected;
    }

}

void WebsocketTransport::disconnect()
{
    m_socket->close();
    m_socket->abort();
}

void WebsocketTransport::sendData(const QByteArray &data)
{
    m_socket->sendTextMessage(QString::fromUtf8(data));
}

void WebsocketTransport::ignoreSslErrors(const QList<QSslError> &errors)
{
    // FIXME: We really should provide the exact errors here, like we do on other transports,
    // however, for some reason I just fail to connect to any wss:// socket if I specify the
    // errors. It would only continue if calling it without errors parameter...

//    m_socket->ignoreSslErrors(errors);

    Q_UNUSED(errors)
#ifndef QT_NO_SSL
    m_socket->ignoreSslErrors();
#endif
}

bool WebsocketTransport::isEncrypted() const
{
#ifndef QT_NO_SSL
    return !m_socket->sslConfiguration().isNull();
#else
    return false;
#endif
}

QSslCertificate WebsocketTransport::serverCertificate() const
{
#ifndef QT_NO_SSL
    return m_socket->sslConfiguration().peerCertificate();
#else
    return QSslCertificate();
#endif
}

void WebsocketTransport::onTextMessageReceived(const QString &data)
{
    emit dataReady(data.toUtf8());
}

NymeaTransportInterface *WebsocketTransportFactory::createTransport(QObject *parent) const
{
    return new WebsocketTransport(parent);
}

QStringList WebsocketTransportFactory::supportedSchemes() const
{
    return {"ws", "wss"};
}
