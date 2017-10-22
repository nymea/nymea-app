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

#ifndef DISCOVERYMODEL_H
#define DISCOVERYMODEL_H

#include <QAbstractListModel>
#include <QList>

#include "discoverydevice.h"

class DiscoveryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum DeviceRole {
        NameRole,
        HostAddressRole,
        WebSocketUrlRole,
        GuhRpcUrlRole,
        PortRole,
        VersionRole
    };

    explicit DiscoveryModel(QObject *parent = 0);

    QList<DiscoveryDevice> devices();

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addDevice(const DiscoveryDevice &device);

    Q_INVOKABLE QString get(int index, const QByteArray &role) const;
    bool contains(const QString &uuid) const;
    DiscoveryDevice find(const QHostAddress &address) const;

    void clearModel();

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<DiscoveryDevice> m_devices;
};

#endif // DISCOVERYMODEL_H
