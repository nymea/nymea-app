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

#ifndef TUNNELPROXYTRANSPORT_H
#define TUNNELPROXYTRANSPORT_H

#include <QUrl>
#include <QObject>

#include "nymeatransportinterface.h"
#include "tunnelproxy/tunnelproxyremoteconnection.h"

class TunnelProxyTransportFactory: public NymeaTransportInterfaceFactory
{
public:
    NymeaTransportInterface* createTransport(QObject *parent = nullptr) const override;
    QStringList supportedSchemes() const override;
};


class TunnelProxyTransport : public NymeaTransportInterface
{
    Q_OBJECT
public:
    explicit TunnelProxyTransport(QObject *parent = nullptr);

    bool connect(const QUrl &url) override;
    QUrl url() const override;
    ConnectionState connectionState() const override;
    void disconnect() override;
    void sendData(const QByteArray &data) override;
    void ignoreSslErrors(const QList<QSslError> &errors) override;

    bool isEncrypted() const override;
    QSslCertificate serverCertificate() const override;

private slots:
    void onRemoteConnectionStateChanged(remoteproxyclient::TunnelProxyRemoteConnection::State state);
    void onRemoteConnectionErrorOccurred(QAbstractSocket::SocketError error);

private:
    QUrl m_url;
    remoteproxyclient::TunnelProxyRemoteConnection *m_remoteConnection = nullptr;

};

#endif // TUNNELPROXYTRANSPORT_H
