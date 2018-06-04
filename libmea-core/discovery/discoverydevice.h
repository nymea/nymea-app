/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Michael Zanetti <michael.zanetti@guh.io>            *
 *                                                                         *
 *  This file is part of mea.                                              *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify            *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,                 *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.            *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef DISCOVERYDEVICE_H
#define DISCOVERYDEVICE_H

#include <QObject>
#include <QUuid>
#include <QUrl>
#include <QHostAddress>
#include <QObject>
#include <QAbstractListModel>

class PortConfig: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int port READ port CONSTANT)
    Q_PROPERTY(Protocol protocol READ protocol NOTIFY protocolChanged)
    Q_PROPERTY(bool sslEnabled READ sslEnabled NOTIFY sslEnabledChanged)
public:
    enum Protocol {
        ProtocolNymeaRpc,
        ProtocolWebSocket
    };
    Q_ENUM(Protocol)
    PortConfig(int port, QObject *parent = nullptr);

    int port() const;

    Protocol protocol() const;
    void setProtocol(Protocol protocol);

    bool sslEnabled() const;
    void setSslEnabled(bool sslEnabled);

signals:
    void protocolChanged();
    void sslEnabledChanged();

private:
    int m_port = -1;
    Protocol m_protocol = ProtocolNymeaRpc;
    bool m_sslEnabled = false;
};

class PortConfigs: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RolePort,
        RoleProtocol,
        RoleSSLEnabled
    };
    Q_ENUM(Roles)
    PortConfigs(QObject* parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;

    PortConfig* find(int port);
    void insert(PortConfig* portConfig);

    Q_INVOKABLE PortConfig *get(int index) const;

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<PortConfig*> m_portConfigs;

};

class DiscoveryDevice: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid uuid READ uuid CONSTANT)
    Q_PROPERTY(QString hostAddress READ hostAddressString NOTIFY hostAddressChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(PortConfigs* portConfigs READ portConfigs CONSTANT)

public:
    explicit DiscoveryDevice(QObject *parent = nullptr);

    QUuid uuid() const;
    void setUuid(const QUuid &uuid);

    QHostAddress hostAddress() const;
    QString hostAddressString() const;
    void setHostAddress(const QHostAddress &hostAddress);

    QString name() const;
    void setName(const QString &name);

    QString version() const;
    void setVersion(const QString &version);

    PortConfigs *portConfigs() const;

    Q_INVOKABLE QString toUrl(int portConfigIndex);

signals:
    void nameChanged();
    void hostAddressChanged();
    void versionChanged();

private:
    QUuid m_uuid;
    QHostAddress m_hostAddress;
    QString m_name;
    QString m_version;
    PortConfigs *m_portConfigs = nullptr;
};

#endif // DISCOVERYDEVICE_H
