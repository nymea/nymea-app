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

#ifndef NYMEAHOST_H
#define NYMEAHOST_H

#include <QObject>
#include <QUuid>
#include <QUrl>
#include <QHostAddress>
#include <QBluetoothAddress>
#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>

class Connection: public QObject {
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url CONSTANT)
    Q_PROPERTY(QString hostAddress READ hostAddress CONSTANT)
    Q_PROPERTY(int port READ port CONSTANT)
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
        BearerTypeLoopback = 0x10,
        BearerTypeUnknown = 0xFF,
        BearerTypeAll = 0xFF
    };
    Q_ENUM(BearerType)
    Q_DECLARE_FLAGS(BearerTypes, BearerType)

    Connection(const QUrl &url, BearerType bearerType, bool secure, const QString &displayName, QObject *parent = nullptr);
    ~Connection();

    QUrl url() const;
    QString hostAddress() const;
    int port() const;
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
    QDateTime m_lastSeen;
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
    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)

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

    bool online() const;

signals:
    void nameChanged();
    void versionChanged();
    void connectionChanged();
    void onlineChanged();

private:
    void syncOnlineState();

private:
    QUuid m_uuid;
    QString m_name;
    QString m_version;
    Connections *m_connections = nullptr;
    bool m_online = false;
};

#endif // NYMEAHOST_H
