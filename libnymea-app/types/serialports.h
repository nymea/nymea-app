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

#ifndef SERIALPORTS_H
#define SERIALPORTS_H

#include <QObject>
#include <QAbstractListModel>

#include "serialport.h"

class SerialPorts : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleSystemLocation,
        RoleManufacturer,
        RoleDescription,
        RoleSerialNumber
    };
    Q_ENUM(Roles)

    explicit SerialPorts(QObject *parent = nullptr);
    virtual ~SerialPorts() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addSerialPort(SerialPort *serialPort);
    void removeSerialPort(const QString &systemLocation);

    void clear();

    Q_INVOKABLE SerialPort *find(const QString &systemLocation) const;
    Q_INVOKABLE virtual SerialPort *get(int index) const;

signals:
    void countChanged();

protected:
    QList<SerialPort *> m_serialPorts;
};

#endif // SERIALPORTS_H
