/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of guh-ubuntu.                                       *
 *                                                                         *
 *  guh-ubuntu is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-ubuntu is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-ubuntu. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef GUHHOSTS_H
#define GUHHOSTS_H

#include <QAbstractListModel>

#include "guhhost.h"

class GuhHosts : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ConnectionRole {
        NameRole = Qt::DisplayRole,
        HostAddressRole,
        WebSocketUrlRole
    };

    explicit GuhHosts(QObject *parent = 0);

    Q_INVOKABLE GuhHost *get(const QString &webSocketUrl);
    QList<GuhHost*> hosts();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addHost(const QString &name, const QString &hostAddress, const QString &webSocketUrl);
    Q_INVOKABLE void removeHost(GuhHost *host);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<GuhHost*> m_hosts;

};

#endif // GuhHosts_H
