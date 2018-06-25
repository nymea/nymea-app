/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2018 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                               *
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

#ifndef NETWORKMANAGERCONTROLER_H
#define NETWORKMANAGERCONTROLER_H

#include <QObject>
#include <QBluetoothDeviceInfo>

#include "wirelesssetupmanager.h"

class NetworkManagerControler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(WirelessSetupManager *manager READ manager NOTIFY managerChanged)

public:
    explicit NetworkManagerControler(QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);

    QString address() const;
    void setAddress(const QString &address);

    WirelessSetupManager *manager();

    Q_INVOKABLE void connectDevice();

private:
    QString m_name;
    QString m_address;

    WirelessSetupManager *m_wirelessSetupManager = nullptr;

signals:
    void managerChanged();
    void nameChanged();
    void addressChanged();

};

#endif // NETWORKMANAGERCONTROLER_H
