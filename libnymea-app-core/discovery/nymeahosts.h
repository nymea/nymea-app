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

class NymeaHost;

class NymeaHosts : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ConnectionRole {
        NameRole = Qt::DisplayRole,
        HostAddressRole,
        WebSocketUrlRole
    };

    explicit NymeaHosts(QObject *parent = 0);

    Q_INVOKABLE NymeaHost *get(const QString &webSocketUrl);
    QList<NymeaHost*> hosts();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addHost(const QString &name, const QString &hostAddress, const QString &webSocketUrl);
    Q_INVOKABLE void removeHost(NymeaHost *host);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<NymeaHost*> m_hosts;

};

#endif // NYMEAHOSTS_H
