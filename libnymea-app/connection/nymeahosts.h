// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NYMEAHOSTS_H
#define NYMEAHOSTS_H

#include <QAbstractListModel>
#include <QList>
#include <QBluetoothAddress>
#include <QSortFilterProxyModel>
#include "nymeahost.h"

class NymeaDiscovery;
class JsonRpcClient;

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
    Q_INVOKABLE NymeaHost* createLanHost(const QString &name, const QUrl &url);
    Q_INVOKABLE NymeaHost* createWanHost(const QString &name, const QUrl &url);
    Q_INVOKABLE NymeaHost* createCloudHost(const QString &name, const QUrl &url);
    NymeaHost* createHost(const QString &name, const QUrl &url, Connection::BearerType bearerType);

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
    QList<NymeaHost *> m_hosts;
};

class NymeaHostsFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(NymeaDiscovery* discovery READ discovery WRITE setDiscovery NOTIFY discoveryChanged)
    Q_PROPERTY(JsonRpcClient* jsonRpcClient READ jsonRpcClient WRITE setJsonRpcClient NOTIFY jsonRpcClientChanged)
    Q_PROPERTY(bool showUnreachableBearers READ showUnreachableBearers WRITE setShowUnreachableBearers NOTIFY showUnreachableBearersChanged)
    Q_PROPERTY(bool showUnreachableHosts READ showUnreachableHosts WRITE setShowUnreachableHosts NOTIFY showUnreachableHostsChanged)

public:
    NymeaHostsFilterModel(QObject *parent = nullptr);

    NymeaDiscovery *discovery() const;
    void setDiscovery(NymeaDiscovery *discovery);

    JsonRpcClient *jsonRpcClient() const;
    void setJsonRpcClient(JsonRpcClient* jsonRpcClient);

    bool showUnreachableBearers() const;
    void setShowUnreachableBearers(bool showUnreachableBearers);

    bool showUnreachableHosts() const;
    void setShowUnreachableHosts(bool showUnreachableHosts);

    Q_INVOKABLE NymeaHost* get(int index) const;

signals:
    void countChanged();
    void discoveryChanged();
    void jsonRpcClientChanged();
    void showUnreachableBearersChanged();
    void showUnreachableHostsChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    NymeaDiscovery *m_nymeaDiscovery = nullptr;
    JsonRpcClient *m_jsonRpcClient = nullptr;

    bool m_showUneachableBearers = false;
    bool m_showUneachableHosts = false;

};

#endif // NYMEAHOSTS_H
