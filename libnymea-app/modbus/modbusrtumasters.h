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

#ifndef MODBUSRTUMASTERS_H
#define MODBUSRTUMASTERS_H

#include <QObject>
#include <QAbstractListModel>

#include "modbusrtumaster.h"

class ModbusRtuMasters : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleUuid,
        RoleSerialPort,
        RoleBaudrate,
        RoleParity,
        RoleDataBits,
        RoleStopBits,
        RoleNumberOfRetries,
        RoleTimeout,
        RoleConnected
    };
    Q_ENUM(Roles)

    explicit ModbusRtuMasters(QObject *parent = nullptr);
    virtual ~ModbusRtuMasters() override = default;

    QList<ModbusRtuMaster *> modbusRtuMasters() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addModbusRtuMaster(ModbusRtuMaster *modbusRtuMaster);
    void removeModbusRtuMaster(const QUuid &modbusUuid);

    void clear();

    Q_INVOKABLE virtual ModbusRtuMaster *get(int index) const;
    Q_INVOKABLE ModbusRtuMaster *getModbusRtuMaster(const QUuid &modbusUuid) const;

signals:
    void countChanged();

private:
    QList<ModbusRtuMaster *> m_modbusRtuMasters;

};

#endif // MODBUSRTUMASTERS_H
