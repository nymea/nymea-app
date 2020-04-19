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

#ifndef NYMEATRANSPORTINTERFACE_H
#define NYMEATRANSPORTINTERFACE_H

#include <QObject>
#include <QSslCertificate>
#include <QHostAddress>

class NymeaTransportInterface;

class NymeaTransportInterfaceFactory
{
public:
    virtual ~NymeaTransportInterfaceFactory() = default;
    virtual NymeaTransportInterface* createTransport(QObject* parent = nullptr) const = 0;

    virtual QStringList supportedSchemes() const = 0;
};

class NymeaTransportInterface : public QObject
{
    Q_OBJECT
public:
    enum ConnectionState {
        ConnectionStateDisconnected,
        ConnectionStateConnecting,
        ConnectionStateConnected
    };
    Q_ENUM(ConnectionState)

    explicit NymeaTransportInterface(QObject *parent = nullptr);
    virtual ~NymeaTransportInterface() = default;

    virtual bool connect(const QUrl &url) = 0;
    virtual QUrl url() const = 0;
    virtual void disconnect() = 0;
    virtual ConnectionState connectionState() const = 0;
    virtual void sendData(const QByteArray &data) = 0;
    virtual void ignoreSslErrors(const QList<QSslError> &errors) { Q_UNUSED(errors) }
    virtual bool isEncrypted() const { return false; }
    virtual QSslCertificate serverCertificate() const { return QSslCertificate(); }

signals:
    void connected();
    void disconnected();
    void error(QAbstractSocket::SocketError error);
    void sslErrors(const QList<QSslError> &errors);
    void dataReady(const QByteArray &data);
};

#endif // NYMEATRANSPORTINTERFACE_H
