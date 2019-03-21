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

#ifndef NYMEAHOST_H
#define NYMEAHOST_H

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
    Q_PROPERTY(QString hostAddress READ hostAddress CONSTANT)
    Q_PROPERTY(BearerType bearerType READ bearerType CONSTANT)
    Q_PROPERTY(bool secure READ secure CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)
    Q_PROPERTY(int priority READ priority NOTIFY priorityChanged)

public:
    enum BearerType {
        BearerTypeNone = 0x00,
        BearerTypeLan = 0x01,
        BearerTypeWan = 0x02,
        BearerTypeCloud = 0x04,
        BearerTypeBluetooth = 0x08,
        BearerTypeUnknown = 0xFF,
        BearerTypeAll = 0xFF
    };
    Q_ENUM(BearerType)
    Q_DECLARE_FLAGS(BearerTypes, BearerType)

    Connection(const QUrl &url, BearerType bearerType, bool secure, const QString &displayName, QObject *parent = nullptr);
    ~Connection();

    QUrl url() const;
    QString hostAddress() const;
    BearerType bearerType() const;
    bool secure() const;
    QString displayName() const;
    bool online() const;
    void setOnline(bool online);
    int priority() const;

signals:
    void onlineChanged();
    void priorityChanged();

private:
    QUrl m_url;
    BearerType m_bearerType = BearerTypeNone;
    bool m_secure = false;
    QString m_displayName;
    bool m_online = false;
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
        RoleSecure,
        RoleOnline
    };
    Q_ENUM(Roles)
    Connections(QObject* parent = nullptr);
    ~Connections() override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;

    void addConnection(Connection *connection);
    void removeConnection(Connection *connection);
    void removeConnection(int index);

    Q_INVOKABLE Connection* find(const QUrl &url) const;
    Q_INVOKABLE Connection* get(int index) const;
    Q_INVOKABLE Connection* bestMatch(Connection::BearerTypes bearerTypes = Connection::BearerTypeAll) const;

signals:
    void countChanged();
    void connectionAdded(Connection *connection);
    void connectionRemoved(Connection *connection);

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<Connection*> m_connections;
};
Q_DECLARE_OPERATORS_FOR_FLAGS(Connection::BearerTypes)

class NymeaHost: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid uuid READ uuid CONSTANT)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(Connections* connections READ connections CONSTANT)

public:
    explicit NymeaHost(QObject *parent = nullptr);
    ~NymeaHost();

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
    void connectionChanged();

private:
    QUuid m_uuid;
    QString m_name;
    QString m_version;
    Connections *m_connections = nullptr;
};

#endif // NYMEAHOST_H
