/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Michael Zanetti <michael.zanetti@guh.io>            *
 *                                                                         *
 *  This file is part of nymea:app.                                              *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify            *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,                 *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.            *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef DISCOVERYDEVICE_H
#define DISCOVERYDEVICE_H

#include <QObject>
#include <QUuid>
#include <QUrl>
#include <QHostAddress>
#include <QBluetoothAddress>
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
    Q_PROPERTY(DeviceType deviceType READ deviceType CONSTANT)
    Q_PROPERTY(QUuid uuid READ uuid CONSTANT)
    Q_PROPERTY(QString hostAddress READ hostAddressString NOTIFY hostAddressChanged)
    Q_PROPERTY(QString bluetoothAddress READ bluetoothAddressString NOTIFY bluetoothAddressChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(PortConfigs* portConfigs READ portConfigs CONSTANT)

public:
    enum DeviceType {
        DeviceTypeNetwork,
        DeviceTypeBluetooth
    };
    Q_ENUM(DeviceType)

    explicit DiscoveryDevice(DeviceType deviceType, QObject *parent = nullptr);

    DeviceType deviceType() const;

    QUuid uuid() const;
    void setUuid(const QUuid &uuid);

    QHostAddress hostAddress() const;
    QString hostAddressString() const;
    void setHostAddress(const QHostAddress &hostAddress);

    QBluetoothAddress bluetoothAddress() const;
    QString bluetoothAddressString() const;
    void setBluetoothAddress(const QBluetoothAddress &bluetoothAddress);

    QString name() const;
    void setName(const QString &name);

    QString version() const;
    void setVersion(const QString &version);

    PortConfigs *portConfigs() const;

    Q_INVOKABLE QString toUrl(int portConfigIndex);
    Q_INVOKABLE QString toUrl(const QString &hostAddress);

signals:
    void nameChanged();
    void hostAddressChanged();
    void bluetoothAddressChanged();
    void versionChanged();

private:
    DeviceType m_deviceType = DeviceTypeNetwork;
    QUuid m_uuid;
    QHostAddress m_hostAddress;
    QBluetoothAddress m_bluetoothAddress;
    QString m_name;
    QString m_version;
    PortConfigs *m_portConfigs = nullptr;
};

#endif // DISCOVERYDEVICE_H
