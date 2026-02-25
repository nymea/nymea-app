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

#ifndef SERIALPORTSPROXY_H
#define SERIALPORTSPROXY_H

#include <QObject>
#include <QSortFilterProxyModel>

#include "serialports.h"

class SerialPortsProxy : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(SerialPorts* serialPorts READ serialPorts WRITE setSerialPorts NOTIFY serialPortsChanged)
    Q_PROPERTY(QString systemLocationFilter READ systemLocationFilter WRITE setSystemLocationFilter NOTIFY systemLocationFilterChanged)

public:
    explicit SerialPortsProxy(QObject *parent = nullptr);

    SerialPorts *serialPorts() const;
    void setSerialPorts(SerialPorts *serialPorts);

    Q_INVOKABLE SerialPort* get(int index) const;

    QString systemLocationFilter() const;
    void setSystemLocationFilter(const QString &systemLocationFilter);

signals:
    void serialPortsChanged();
    void countChanged();
    void systemLocationFilterChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    SerialPorts *m_serialPorts = nullptr;

    QString m_systemLocationFilter;

};

#endif // SERIALPORTSPROXY_H
