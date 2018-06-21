/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea                                               *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef WIRELESSACCESSPOINTS_H
#define WIRELESSACCESSPOINTS_H

#include <QObject>
#include <QAbstractListModel>

#include "wirelessaccesspoint.h"

class WirelessAccesspoints : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum BluetoothDeviceInfoRole {
        WirelessAccesspointRoleSsid = Qt::DisplayRole,
        WirelessAccesspointRoleMacAddress,
        WirelessAccesspointRoleSignalStrength,
        WirelessAccesspointRoleProtected,
        WirelessAccesspointRoleSelectedNetwork
    };

    explicit WirelessAccesspoints(QObject *parent = 0);

    QList<WirelessAccessPoint *> wirelessAccessPoints();
    void setWirelessAccessPoints(QList<WirelessAccessPoint *> wirelessAccessPoints);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    Q_INVOKABLE int count() const;
    Q_INVOKABLE WirelessAccessPoint *get(const QString &ssid) const;

    void clearModel();

    Q_INVOKABLE void setSelectedNetwork(const QString &ssid, const QString &macAdderss);

    static bool signalStrengthLessThan(const WirelessAccessPoint *a, const WirelessAccessPoint *b);

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<WirelessAccessPoint *> m_wirelessAccessPoints;


};

#endif // WIRELESSACCESSPOINTS_H
