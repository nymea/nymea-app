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

#ifndef TCPSOCKETTRANSPORT_H
#define TCPSOCKETTRANSPORT_H

#include "nymeatransportinterface.h"

#include <QObject>
#include <QSslSocket>
#include <QTcpSocket>
#include <QUrl>

class TcpSocketTransportFactory: public NymeaTransportInterfaceFactory
{
public:
    NymeaTransportInterface* createTransport(QObject *parent = nullptr) const override;
    QStringList supportedSchemes() const override;
};

class TcpSocketTransport: public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit TcpSocketTransport(QObject *parent = nullptr);

    bool connect(const QUrl &url) override;
    QUrl url() const override;
    ConnectionState connectionState() const override;
    void disconnect() override;
    void sendData(const QByteArray &data) override;
    void ignoreSslErrors(const QList<QSslError> &errors) override;
    bool isEncrypted() const override;
    QSslCertificate serverCertificate() const override;

private slots:
    void onConnected();
    void onEncrypted();
    void socketReadyRead();
    void onSocketStateChanged(const QAbstractSocket::SocketState &state);

private:
#ifndef QT_NO_SSL
    QSslSocket m_socket;
#else
    QTcpSocket m_socket;
#endif
    QUrl m_url;
};

#endif // TCPSOCKETTRANSPROT_H
