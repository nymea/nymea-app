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

#ifndef SERVERCONFIGURATION_H
#define SERVERCONFIGURATION_H

#include <QObject>
#include <QHostAddress>
#include <QUuid>

class ServerConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool authenticationEnabled READ authenticationEnabled WRITE setAuthenticationEnabled NOTIFY authenticationEnabledChanged)
    Q_PROPERTY(bool sslEnabled READ sslEnabled WRITE setSslEnabled NOTIFY sslEnabledChanged)

public:
    explicit ServerConfiguration(const QString &id, const QHostAddress &address = QHostAddress(), int port = 0, bool authEnabled = false, bool sslEnabled = false, QObject *parent = nullptr);

    QString id() const;

    QString address() const;
    void setAddress(const QString &address);

    int port() const;
    void setPort(int port);

    bool authenticationEnabled() const;
    void setAuthenticationEnabled(bool authenticationEnabled);

    bool sslEnabled() const;
    void setSslEnabled(bool sslEnabled);

    Q_INVOKABLE virtual ServerConfiguration* clone() const;

signals:
    void addressChanged();
    void portChanged();
    void authenticationEnabledChanged();
    void sslEnabledChanged();

private:
    QString m_id;
    QHostAddress m_hostAddress;
    int m_port;
    bool m_authEnabled;
    bool m_sslEnabled;
};

class WebServerConfiguration: public ServerConfiguration
{
    Q_OBJECT
    Q_PROPERTY(QString publicFolder READ publicFolder WRITE setPublicFolder NOTIFY publicFolderChanged)
public:
    explicit WebServerConfiguration(const QString &id, const QHostAddress &address = QHostAddress(), int port = 0, bool authEnabled = false, bool sslEnabled = false, QObject *parent = nullptr)
        : ServerConfiguration(id, address, port, authEnabled, sslEnabled, parent) {}

    QString publicFolder() const;
    void setPublicFolder(const QString &publicFolder);

    Q_INVOKABLE ServerConfiguration* clone() const override;

signals:
    void publicFolderChanged();

private:
    QString m_publicFolder;
};

#endif // SERVERCONFIGURATION_H
