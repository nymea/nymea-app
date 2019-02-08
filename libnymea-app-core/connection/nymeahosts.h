/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of nymea:app.                                       *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NYMEAHOSTS_H
#define NYMEAHOSTS_H

#include <QAbstractListModel>
#include <QList>
#include <QBluetoothAddress>
#include <QSortFilterProxyModel>
#include "nymeahost.h"

class NymeaDiscovery;
class NymeaConnection;

class NymeaHosts : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum HostRole {
        UuidRole,
        NameRole,
        VersionRole
    };
    Q_ENUM(HostRole)

    explicit NymeaHosts(QObject *parent = nullptr);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addHost(NymeaHost *host);
    void removeHost(NymeaHost *host);
    Q_INVOKABLE NymeaHost* createHost(const QString &name, const QUrl &url, Connection::BearerType bearerType);

    Q_INVOKABLE NymeaHost *get(int index) const;
    Q_INVOKABLE NymeaHost *find(const QUuid &uuid);

    void clearModel();

signals:
    void hostAdded(NymeaHost* host);
    void hostRemoved(NymeaHost* host);
    void countChanged();
    void hostChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<NymeaHost*> m_hosts;
};

class NymeaHostsFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(NymeaDiscovery* discovery READ discovery WRITE setDiscovery NOTIFY discoveryChanged)
    Q_PROPERTY(NymeaConnection* nymeaConnection READ nymeaConnection WRITE setNymeaConnection NOTIFY nymeaConnectionChanged)
    Q_PROPERTY(bool showUnreachableBearers READ showUnreachableBearers WRITE setShowUnreachableBearers NOTIFY showUnreachableBearersChanged)

public:
    NymeaHostsFilterModel(QObject *parent = nullptr);

    NymeaDiscovery* discovery() const;
    void setDiscovery(NymeaDiscovery *discovery);

    NymeaConnection* nymeaConnection() const;
    void setNymeaConnection(NymeaConnection* nymeaConnection);

    bool showUnreachableBearers() const;
    void setShowUnreachableBearers(bool showUnreachableBearers);

    Q_INVOKABLE NymeaHost* get(int index) const;

signals:
    void countChanged();
    void discoveryChanged();
    void nymeaConnectionChanged();
    void showUnreachableBearersChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    NymeaDiscovery *m_nymeaDiscovery = nullptr;
    NymeaConnection *m_nymeaConnection = nullptr;

    bool m_showUneachableBearers = false;

};

#endif // NYMEAHOSTS_H
