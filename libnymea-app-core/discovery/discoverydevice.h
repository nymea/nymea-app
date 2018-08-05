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

class Connection: public QObject {
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url CONSTANT)
    Q_PROPERTY(BearerType bearerType READ bearerType CONSTANT)
    Q_PROPERTY(bool secure READ secure CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
public:
    enum BearerType {
        BearerTypeUnknown,
        BearerTypeWifi,
        BearerTypeEthernet,
        BearerTypeBluetooth,
        BearerTypeCloud
    };
    Q_ENUM(BearerType)

    Connection(const QUrl &url, BearerType bearerType, bool secure, const QString &displayName, QObject *parent = nullptr);

    QUrl url() const;
    BearerType bearerType() const;
    bool secure() const;
    QString displayName() const;

private:
    QUrl m_url;
    BearerType m_bearerType = BearerTypeUnknown;
    bool m_secure = false;
    QString m_displayName;
};

class Connections: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleUrl,
        RoleName,
        RoleBearerType,
        RoleSecure
    };
    Q_ENUM(Roles)
    Connections(QObject* parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;

    void addConnection(Connection *connection);

    Q_INVOKABLE Connection* find(const QUrl &url) const;
    Q_INVOKABLE Connection* get(int index) const;

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<Connection*> m_connections;

};

class DiscoveryDevice: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid uuid READ uuid CONSTANT)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(Connections* connections READ connections CONSTANT)

public:
    explicit DiscoveryDevice(QObject *parent = nullptr);

    QUuid uuid() const;
    void setUuid(const QUuid &uuid);

    QString name() const;
    void setName(const QString &name);

    QString version() const;
    void setVersion(const QString &version);

    Connections *connections() const;

signals:
    void nameChanged();
    void versionChanged();

private:
    QUuid m_uuid;
    QString m_name;
    QString m_version;
    Connections *m_connections = nullptr;
};

#endif // DISCOVERYDEVICE_H
