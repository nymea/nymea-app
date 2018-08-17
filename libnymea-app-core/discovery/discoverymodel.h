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

#ifndef DISCOVERYMODEL_H
#define DISCOVERYMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QBluetoothAddress>

class DiscoveryDevice;

class DiscoveryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum DeviceRole {
        DeviceTypeRole,
        UuidRole,
        NameRole,
        VersionRole
    };
    Q_ENUM(DeviceRole)

    explicit DiscoveryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addDevice(DiscoveryDevice *device);

    Q_INVOKABLE DiscoveryDevice *get(int index) const;
    Q_INVOKABLE DiscoveryDevice *find(const QUuid &uuid);

    void clearModel();

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<DiscoveryDevice *> m_devices;
};

#endif // DISCOVERYMODEL_H
