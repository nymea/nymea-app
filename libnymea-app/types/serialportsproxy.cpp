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

#include "serialportsproxy.h"

SerialPortsProxy::SerialPortsProxy(QObject *parent) : QSortFilterProxyModel(parent)
{

}

SerialPorts *SerialPortsProxy::serialPorts() const
{
    return m_serialPorts;
}

void SerialPortsProxy::setSerialPorts(SerialPorts *serialPorts)
{
    if (m_serialPorts == serialPorts)
        return;

    setSourceModel(serialPorts);
    m_serialPorts = serialPorts;
    emit serialPortsChanged();

    connect(m_serialPorts, &SerialPorts::countChanged, this, [this](){
        emit countChanged();
    });
    connect(m_serialPorts, &SerialPorts::countChanged, this, [this]() {
        sort(0, Qt::DescendingOrder);
    });

    setSortRole(SerialPorts::RoleSystemLocation);
    sort(0, Qt::DescendingOrder);
    emit countChanged();
}

SerialPort *SerialPortsProxy::get(int index) const
{
    if (index >= 0 && index < m_serialPorts->rowCount()) {
        return m_serialPorts->get(mapToSource(this->index(index, 0)).row());
    }
    return nullptr;
}

QString SerialPortsProxy::systemLocationFilter() const
{
    return m_systemLocationFilter;
}

void SerialPortsProxy::setSystemLocationFilter(const QString &systemLocationFilter)
{
    if (m_systemLocationFilter != systemLocationFilter) {
        m_systemLocationFilter = systemLocationFilter;
        emit systemLocationFilterChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool SerialPortsProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    if (!m_serialPorts) {
        return false;
    }

    if (!m_systemLocationFilter.isEmpty()) {
        SerialPort *serialPort = m_serialPorts->get(sourceRow);
        if (serialPort->systemLocation() != m_systemLocationFilter) {
            return false;
        }
    }
    return true;
}

