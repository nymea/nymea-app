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

#include "websocketinterface.h"
#include "engine.h"

#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QSettings>

WebsocketInterface::WebsocketInterface(QObject *parent) :
    GuhInterface(parent)
{
    m_socket = new QWebSocket(QGuiApplication::applicationName(), QWebSocketProtocol::Version13, this);

    connect(m_socket, SIGNAL(connected()), this, SLOT(onConnected()));
    connect(m_socket, SIGNAL(disconnected()), this, SLOT(onDisconnected()));
    connect(m_socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onError(QAbstractSocket::SocketError)));
    connect(m_socket, SIGNAL(textMessageReceived(QString)), this, SLOT(onTextMessageReceived(QString)));
}

void WebsocketInterface::sendData(const QByteArray &data)
{
    m_socket->sendTextMessage(QString::fromUtf8(data));
}

void WebsocketInterface::sendRequest(const QVariantMap &request)
{
    sendData(QJsonDocument::fromVariant(request).toJson(QJsonDocument::Compact));
}

void WebsocketInterface::setUrl(const QString &url)
{
    m_urlString = url;
    emit urlChanged();
}

QString WebsocketInterface::url() const
{
    return m_urlString;
}

void WebsocketInterface::enable()
{
    if (connected())
        disable();

    qDebug() << "Connecting to" << QUrl(m_urlString).toString();
    m_socket->open(QUrl(m_urlString));
    emit connecting();
}

void WebsocketInterface::disable()
{
    m_socket->close();
}

void WebsocketInterface::onConnected()
{
    qDebug() << "Connected to" << m_urlString;

    QSettings settings;
    qDebug() << "Save last connection" << settings.fileName();
    settings.beginGroup("Connections");
    settings.setValue("webSocketUrl", m_urlString);
    settings.endGroup();

    setConnected(true);

    //Engine::instance()->connections()->addConnection("guhIO", m_socket->peerAddress().toString(), m_urlString);
}

void WebsocketInterface::onDisconnected()
{
    qDebug() << "Disconnected from" << m_urlString << ": reason:" << m_socket->closeReason();
    setConnected(false);
}

void WebsocketInterface::onTextMessageReceived(const QString &data)
{
    QJsonParseError error;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data.toUtf8(), &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Could not parse json data from guh" << data << error.errorString();
        return;
    }

    emit dataReady(jsonDoc.toVariant().toMap());
}

void WebsocketInterface::onError(QAbstractSocket::SocketError error)
{
    qWarning() << "Websocket error:" << error << m_socket->errorString();
    emit websocketError(m_socket->errorString());
    emit connectionFailed();
}
